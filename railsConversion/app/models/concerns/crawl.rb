require 'active_support/concern'
module Crawl
  extend ActiveSupport::Concern
  require 'net/http'
  require 'uri'
  require 'json'
      Standard_Tags={ #would it be 'better' to load the data objs? instead of just having the raw id values.
                         "Inactive"=>1,
                    "Uncategorized"=>2,
                "Connection Failed"=>3,
                           "Active"=>4,
           "SSL Connection Failure"=>5,
                      "Name Server"=>6,
                             "ip_4"=>7,
                             "ip_6"=>8,
                      "Bit Message"=>9,
                            "Email"=>10,
                              "URL"=>11,
  "Name Server:Address Combination"=>12
                    }
  
#                         Standard_Tags={
#                        "Inactive"=> Tag.where(title:"Inactive"),
#                   "Uncategorized"=> Tag.where(title:"Uncategorized"),
#               "Connection Failed"=> Tag.where(title:"Connection Failed"),
#                          "Active"=> Tag.where(title:"Active"),
#          "SSL Connection Failure"=> Tag.where(title:"SSL Connection Failure"),
#                     "Name Server"=> Tag.where(title:"Name Server"),
#                            "ip_4"=> Tag.where(title:"ip_4"),
#                            "ip_6"=> Tag.where(title:"ip_6"),
#                     "Bit Message"=> Tag.where(title:"Bit Message"),
#                           "Email"=> Tag.where(title:"Email"),
#                             "URL"=> Tag.where(title:"URL"),
# "Name Server:Address Combination"=> Tag.where(title:"Name Server:Address Combination")
#
  class Address_Crawl_Cycle
    def initialize
      @db_batch=DB_Batch.new
      @entry_BlackList=[]
      @character_BlackList=?@
      @attempted_combos=[]
    end

    def investigate_addresses
      simple_cycle
      name_server_cycle
    end

    def simple_cycle #excludes email addresses & bit messages & name servers for now
      Address.joins(:address_tags,:tags).where("address_tags.tag_id !=9 and address_tags.tag_id != 10 and address_tags.tag_id !=6").find_in_batches do |batch|#Returns ip addresses and urls, by exlcuding bit messages,email addresses, and name servers.
        batch.each do |addrObj|
          addrObj.tags.each {|x| puts x.title}
          puts addrObj.value
          crawler=Crawler.new(addrObj) #returns DB_batch of links or black listed/malformed addresses
          results=crawler.perform
          @db_batch.add results
        end
        @db_batch.commit_white_list #saves/deletes
        @db_batch.commit_black_list #saves/deletes
      end
    end

    def black_listed?(addrObj)
      if addrObj.value.include?@character_BlackList || @entry_BlackList.any? {|x| x==addrObj.value}
        true
      else
        false
      end
    end

    def name_server_cycle #build batch

      batch = Address.joins(:address_tags,:tags).where('tags.title=?','Name Server').uniq
      # Address.joins(:address_tags,:tags).where('tags.title=?','Name Server').uniq.find_in_batches do |batch|
        batch.each do |ns_addressObj|
          if black_listed?(ns_addressObj)
            @db_batch.black_list(ns_addressObj)
          else
            combo_batch=[]
            list_of_nmc_addresses=Set.new
            nmcObj=NmcChainEntry.joins(:nmc_addresses).where("address_id=?",ns_addressObj.id).first#try to use the value as the domain as intended by nmc - use d/something as the domain name but with the suffix .bit
            combo_batch.push Address.new(value:nmcObj.link["name"].gsub(/\A\s?d\//,"")) #starts with the namecoin val as the first entry to try with the name server
            NmcAddress.where(address_id: ns_addressObj.id).uniq.each {|q| list_of_nmc_addresses.add? q} #dont need to worry about batching yet I dont think
            list_of_nmc_addresses.each do |x|
              cousins=ns_addressObj.cousins_in_nmc(x.nmc_chain_entry_id,{"exclude"=>[6,9,10]}) #exlcudes name server addresses, emails, and bitmessages
              cousins.each do |cousin| #cant get cousins sql to stop reutrning dups? this is a workaround
                unless combo_batch.any? {|obj| obj.value==cousin.value}
                  combo_batch.push cousin
                end
              end
            end
            run_ns_addr_batch(ns_addressObj,combo_batch.flatten)
          end
        end
      # @db_batch.commit_white_list
      # @db_batch.commit_black_list
    end

    def run_ns_addr_batch(ns_addressObj,combo_batch)
      puts "==============================="
      puts ns_addressObj.value
      puts "*******************************"
      combo_batch.each {|x| puts x.value}
      puts "*******************************"

      prefixes=["","https://"]
      suffixes=["",".com",".net",".bit","."] #com and net arent needed probs
      combo_batch.each do |addrObj|
      # catch(:next_addrObj) do
        next if @attempted_combos.any? {|x| x=="#{ns_addressObj.value}#{addrObj.value}"}
          prefixes.each do |pref|
          next if addrObj.value.start_with? pref # avoid unnecessary queries
            suffixes.each do |suf|
            next if  addrObj.value.end_with? suf
              if @attempted_combos.any? {|x| x == "#{ns_addressObj.value}#{pref}#{addrObj.value}#{suf}"} #avoid unnecessary queries,
                # throw :next_addrObj
              end
              puts "Attempting to access:----curl 'Host:#{ns_addressObj.value} #{pref}#{addrObj.value}#{suf}'"
              new_addrObj=Address.new(value:"#{pref}#{addrObj.value}#{suf}")
              crawler=Crawler.new(new_addrObj,{"Header"=>{"Host"=>ns_addressObj}}) #If there is a ns_addrObj provided in the header options under "host:" it will only return new Addresses if they yield links when curling
              @attempted_combos.push("#{ns_addressObj.value}#{pref}#{addrObj.value}#{suf}")
              @db_batch.add crawler.perform #returns a DB_Batch object 
            end
          end
        end
      # end
    end
  end




  class Crawler 
    def initialize(addrObj,options={})
      @results=Crawl::DB_Batch.new
      @options=options
      @addrObj=addrObj
      @the_Ping_Machine=Curl::Easy.new(clean_possible_curl_address addrObj.value)
      @addrObj_exists=Address.exists? addrObj.id
    end

    def perform
      curl_address
      @results
    end

    def scrape_for_links(xml_page) #xml is like violence.
      page = Nokogiri::HTML(xml_page)
      links= page.css('a') + page.css('A')
      hrefs = links.map {|link| link.attribute('href').to_s}.uniq.sort.delete_if {|href| href.empty?}
      hrefs
    end

    def clean_possible_curl_address(string)
      string.gsub(/[\s\,\"\'\}\{]/,"") #technically urls are allowed to have space as long as they are enclosed with spaces according to the most recent RFC
    end

    def curl_address
      # @the_Ping_Machine.verbose=true
      @the_Ping_Machine.timeout=5
      if @options["Header"]
        @options["Header"].each {|key,val| @the_Ping_Machine.headers[key] = val}
      end
      # the_Ping_Machine
      # the_Ping_Machine.on_success {puts "success"}# 2xx
      # the_Ping_Machine.on_redirect {puts "REDIRCTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz!"}#3xx
      # the_Ping_Machine.on_missing {puts "MISSING%%%%%%%%%%%%%%%%%%%%%%%%"}#4xx
      # the_Ping_Machine.on_failure {puts "FAILURE!!!!!!!!!!!!!!!!!"}#5xx
      # the_Ping_Machine.on_complete {puts "Complete"} 
      begin
        @the_Ping_Machine.perform
      rescue Curl::Err::TimeoutError,Curl::Err::ConnectionFailedError, Curl::Err::RecvError
        if @addrObj_exists
          [Standard_Tags["Inactive"],Standard_Tags["Connection Failed"]].each {|tagId| @results.white_list( @addrObj.tag(tagId)) }
        end
      rescue Curl::Err::GotNothingError, Curl::Err::RecvError
        if @addrObj_exist
          [Standard_Tags["Inactive"]].each {|tagId| @results.white_list( @addrObj.tag(tagId)) }
        end
      rescue Curl::Err::SSLConnectError,Curl::Err::HostResolutionError,Curl::Err::SSLPeerCertificateError,Curl::Err::SSLCACertificateError
        if @addrObj_exist
          [Standard_Tags["SSL Connection Failure"],Standard_Tags["Connection Failed"]].each {|tagId| @results.white_list( @addrObj.tag(tagId)) }
        end
      rescue Curl::Err::MalformedURLError,Curl::Err::UnsupportedProtocolError
        if @addrObj_exist
          @results.black_list(@addrObj)
        end
      end

      unless @the_Ping_Machine.is_a? NilClass
          links = scrape_for_links(@the_Ping_Machine.body_str)
        if @addrObj_exists
          links.each {|link| @results.white_list(Hyperlink.new(link:link,address_id:@addrObj.id))}
        else
          @addrObj.save
          links.each {|link| @results.white_list(Hyperlink.new(link:link,address_id:@addrObj.id))}
        end
      end
    end
  end

  class DB_Batch
    def initialize
      @white_list=[]
      @black_list=[]
    end
    def add(db_batch)
      white_list db_batch.white_list
      black_list db_batch.black_list
    end

    def empty?
      if @white_list.count > 0 || @white_list.count > 0
        false
      else
        true
      end
    end
    def white_list(addrObj=nil)
      unless addrObj.is_a? NilClass
        @white_list.push(addrObj)
        @white_list.flatten!
      else
        @white_list
      end
    end

    def black_list(addrObj=nil)
      unless addrObj.is_a? NilClass
        @black_list.push(addrObj)
        @black_list.flatten!
      else
        @black_list
      end
    end

    def commit_white_list
      @white_list.each {|x| x.save}
      # white_list.clear
    end

    def commit_black_list
      @black_list.each {x.delete_all} #is it bad to do this here? should only be one record (theyre unique)
      # black_list.clear
    end
  end
end

