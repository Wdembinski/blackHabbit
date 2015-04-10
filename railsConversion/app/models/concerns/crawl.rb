require 'active_support/concern'

# A. NmcChainEntry.tag_possible_addresses
# └── nmc_entry
#     ├── is_json?
#     │   ├── key_analysis - Currently just checks if the key indicates a possible name-server indication
#     │   │   └── possible_name_server?
#     │   │       └─Tag_as_name_server
#     │   └── scan_for_possible_addresses -> log as "PossibleAddress" tbl: 'possible_addresses' w/ category guess
#     └── not_json
#         └── convert_to_string + clean_string **Sometimes comes in the form of an '[array]'
#             └── scan_for_possible_addresses -> log as "PossibleAddress" tbl: 'possible_addresses' w/ category guess
#
# Summary - If json value, checks to see if the keys of the json/hash suggests the a value is a name server entry
#           and otherwise scans values for possible addresses -> tag with initial category
#         
#         - If not json, converts to string and scans values for possible addreses -> tag with initial category
# 
# B. PossibleAddress.investigate_addreses
#    └── PossibleAddress.where(category: "Name Server") #array of many PossibleAddress
#        └── Cycle Possible cominations to pair with Name Server
#            ├─ 0. Corresponding nmc 'value' appended with a .bit suffix
#            ├──1. Possible prefixes ["","http",https]
#            ├──2. Possible suffixes ["",".net",".com"]
#            │
#            └Ultimately cycles something like the cycle bellow and logs any hrefs/links in the response body
#
#             prefixes.each do |pref|
#               suffixes.each do |suf|
#                 ping_with_ns("#{pref}#{possibleNameCoinVal}#{suf}")#with the other pref/suffixes
#               end
#             end
# 



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
              #                                        }





    VALID_EMAIL_REGEX = /(\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z)/i
    VALID_BM_REGEX = /(BM-(?:(?![IlO0])[A-Za-z0-9]){32,34})/i #bit message
    $white_list=[]
    $black_list=[]





  def commit_white_list
    $white_list.each {|x| x.save}
    # $white_list.clear
  end
  


  def commit_black_list
    $black_list.each {x.delete}
    # $black_list.clear
  end

  def clean_possible_curl_address(string)
    string.gsub(/[\s\,\"\'\}\{]/,"")
  end


  def is_json?(string) #return json hash if true false if not, kinda wonky but I like it atm.
    begin
      JSON.parse(string)
    rescue JSON::ParserError
      false
    end
  end
 



  # def investigate_addresses(addressObj)
  #   inactive=Address.where(name:)
  #   active=Address.where(name:)
  #   Address.find_by_sql("select distinct addresses.value from nmc_chain_entries inner join nmc_addresses on nmc_chain_entries.id=nmc_addresses.nmc_chain_entry_id inner join addresses on addresses.id=nmc_addresses.address_id inner join address_tags on addresses.id=address_tags.address_id where tag_id != 6 and tag_id != 9 and tag_id != 10 and nmc_addresses.nmc_chain_entry_id=#{x.nmc_chain_entry_id}").find_batches do |batch|
  #     batch.each do |addrObj|
  #       begin
  #         the_Ping_Machine.perform
  #       rescue Curl::Err::TimeoutError => e
  #         $white_list.push(AddressTag.new(tag_id:Tag.where()))
  #       rescue Curl::Err::GotNothingError => e
  #         puts e.message
  #       rescue Curl::Err::ConnectionFailedError, Curl::Err::RecvError => e
  #         puts e.message
  #       rescue Curl::Err::SSLConnectError,Curl::Err::HostResolutionError,Curl::Err::SSLPeerCertificateError,Curl::Err::SSLCACertificateError => e
  #         puts e.message
  #       rescue Curl::Err::MalformedURLError,Curl::Err::UnsupportedProtocolError => e
  #         $black_list.push(addrObj)
  #       end
  #     end
  #   end
  # end



  def name_server_cycle
    character_BlackList=?@
    entry_BlackList=[""]
    Address.joins(:address_tags,:tags).where('tags.title=?','Name Server').find_in_batches do |batch|
      batch.each do |ns_addressObj|
        if ns_addressObj.value.include? character_BlackList || entry_BlackList.any? {|x| x==ns_addressObj.value}
          $black_list.push(ns_addressObj)
        else
          nmcObj=NmcChainEntry.joins(:nmc_addresses).where("address_id=?",ns_addressObj.id).take#try to use the value as the domain as intended by nmc - use d/something as the domain name but with the suffix .bit
          # nmcObj=NmcChainEntry.joins(:nmc_addresses).where("address_id=?",ns_addressObj.id).take.link["name"].gsub(/d\//,"") #try to use the value as the domain as intended by nmc - use d/something as the domain name but with the suffix .bit
          list_of_nmc_addresses=NmcAddress.where(address_id: ns_addressObj.id) #dont need to worry about batching yet I dont think
          list_of_nmc_addresses.each do |x|
            combo_batch=[nmcObj] #starts with the namecoin val as the first entry to try with the name server
            combo_batch.push Address.find_by_sql("select distinct addresses from nmc_chain_entries inner join nmc_addresses on nmc_chain_entries.id=nmc_addresses.nmc_chain_entry_id inner join addresses on addresses.id=nmc_addresses.address_id inner join address_tags on addresses.id=address_tags.address_id where tag_id != 6 and tag_id != 9 and tag_id != 10 and nmc_addresses.nmc_chain_entry_id=#{x.nmc_chain_entry_id}")#excludes email addresses, bit messages, and other name server addresses
            run_name_server_batch(ns_addressObj,combo_batch.flatten!)
          end
        end
      end
    commit_white_list 
    # commit_black_list 
    end
  end

  def run_name_server_batch(ns_addressObj,combo_batch)
    attempted_combos=[]
    prefixes=["","http://","https://"]
    suffixes=["",".",".com.",".net.",".bit","."]
    combo_batch.each do |obj|








      if obj.is_a? NmcChainEntry
      next if attempted_combos.any? {|x| x=="#{ns_addressObj.value}#{pref}#{nmcName}#{suf}"}
        nmcName=obj.link["name"].gsub(/d\//,"") 
        prefixes.each do |pref|
        next if nmcName.start_with? pref # avoid unnecessary queries, check out end_with?
        # next if obj.link["name"][0..pref.length] == pref # avoid unnecessary queries, check out end_with?
          suffixes.each do |suf|
          next if  nmcName.end_with? suf || attempted_combos.any? {|x| x == "#{ns_addressObj.value}#{pref}#{combo}#{suf}"}
          # avoid unnecessary queries 
          # next if  obj.link["name"][-suf.length..-1] == suf || attempted_combos.any? {|x| x == "#{ns_addressObj.value}#{pref}#{combo}#{suf}"}# avoid unnecessary queries 
            puts "Attempting to access:----curl 'Host:#{ns_addressObj.value} #{pref}#{nmcName}#{suf}'"
            result=curl_address("#{pref}#{nmcName}#{suf}",ns_addressObj)
            attempted_combos.push("#{ns_addressObj.value}#{pref}#{nmcName}#{suf}")
            if result.is_a? NilClass #returns nil if the connection
              next
            else
                o=Address.new(value:"Host: #{ns_addressObj.value} Address: #{pref}#{nmcName}#{suf}")
                links = scrape_for_links result.body_str
              unless o.exists? #TODO: Check if the sql runs the "if exists" variant
                o.save
                $white_list.push(AddressTag.new(tag_id:12,address_id:o.id))
                if links.emptY?
                  next
                else
                  links.each {|link| white_list.push(Hyperlink.new(link:link,address_id:o.id)) }
                end
              else
                next

              end
            end
          end
        end
      else
      next if attempted_combos.any? {|x| x=="#{ns_addressObj.value}#{pref}#{obj.value}#{suf}"}
        prefixes.each do |pref|
        next if obj.value[0..pref.length] == pref # avoid unnecessary queries 
          suffixes.each do |suf|
          next if  obj.value[-suf.length..-1] == suf || attempted_combos.any? {|x| x == "#{ns_addressObj.value}#{pref}#{obj.value}#{suf}"}# avoid unnecessary queries 
            puts "Attempting to access:----curl 'Host:#{ns_addressObj.value} #{pref}#{obj.value}#{suf}'"
            result=curl_address("#{pref}#{obj.value}#{suf}",ns_addressObj)
            attempted_combos.push("#{ns_addressObj.value}#{pref}#{obj.value}#{suf}")
            if result.is_a? NilClass
              next
            else
              o=Address.new(address:"Host: #{ns_addressObj.value} Address: #{pref}#{obj.value}#{suf}",ns_address_id: ns_addressObj.id)
              o.save
              $white_list.push(AddressTag.new(tag_id:12,address_id:o.id))
              links = scrape_for_links result.body_str
              if links.emptY?
                next
              else
                links.each {|link| white_list.push(Hyperlink.new(link:link,address_id:o.id)) }
              end
            end
          end
        end
      end
    end
  end

  def curl_address(addrString,nsAddrObj=nil) #

    the_Ping_Machine=Curl::Easy.new(clean_possible_curl_address(addrString))
    the_Ping_Machine.timeout=5
    if nsAddrObj
      the_Ping_Machine.headers["Host"] = nsAddrObj.value
    end
    # the_Ping_Machine
    the_Ping_Machine.perform
    the_Ping_Machine
  end

  def clean_possible_curl_address(string)
    string.gsub(/[\s\,\"\'\}\{]/,"") #technically urls are allowed to have space as long as they are enclosed with spaces according to the most recent RFC
  end

  def scrape_for_links(xml_page) #xml is like violence.
    page = Nokogiri::HTML(xml_page)
    links= page.css('a') + page.css('A')
    hrefs = links.map {|link| link.attribute('href').to_s}.uniq.sort.delete_if {|href| href.empty?}
    hrefs
  end


end

