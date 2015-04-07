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
    Standard_Categories={"Inactive"=>5,"Uncategorized"=>6,"Connection Failed"=>7,"Active"=>8,"SSL Connection Failure"=>9,"Name Server"=>10}
    VALID_EMAIL_REGEX = /(\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z)/i
    VALID_BM_REGEX = /(BM-(?:(?![IlO0])[A-Za-z0-9]){32,34})/i #bit message
    $white_list=[]
    $black_list=[]





  def commit_white_list
    # puts $white_list
    # $white_list.each do |whiteListEntry|
    #   g=PossibleAddress.where(address: whiteListEntry[:addressObj].address)
    #   g.each do |addressObj|
    #     begin
    #       if whiteListEntry[:categories].class==Array
    #           whiteListEntry[:categories].each do |cat|
    #           addressObj.category_memberships.create(possible_address_category_id:cat)
    #         end
    #       else whiteListEntry[:categories].class==Fixnum
    #         addressObj.category_memberships.create(possible_address_category_id:whiteListEntry[:categories])
    #       end

    #       ### Some of the objects in this list may have had links found when we scraped them. God willing.
    #       ### If there is a better way of doing this I would love to do it!
    #       addressObj.update(links: whiteListEntry[:links]) if whiteListEntry[:links]
    #       addressObj.update(categorized: true)
    #     end
    #   end
    # end
    # $white_list.clear
  end
  


  def commit_black_list
    # $black_list.each do |obj|
    #   PossibleAddress.delete_all(address:obj[:address])
    # end
    # $black_list.clear
  end

  def clean_possible_curl_address(string)
    string.gsub(/[\s\,\"\'\}\{]/,"")
  end


  def is_json?(string)
    begin
      JSON.parse(string)
    rescue JSON::ParserError
      false
    end
  end
 


  def scrape_and_categorize(addressObj)
    links=scrape_for_links(addressObj["address"])
    if addressObj.regex_match=="ip_6" || addressObj.regex_match=="ip_4"
      $white_list.push({addressObj: addressObj,categories:[Standard_Categories['Active'],Standard_Categories['Ip Address']],links: links })
    else addressObj.regex_match=="url_or_email"
      $white_list.push({addressObj: addressObj,categories:[Standard_Categories['Active'],Standard_Categories['URL']],links: links })
    end
  end


  def scrape_for_links(xml_page) #xml is like violence.
    page = Nokogiri::HTML(xml_page)
    links= page.css('a') + page.css('A')
    hrefs = links.map {|link| link.attribute('href').to_s.uniq.sort.delete_if {|href| href.empty?}}
    return hrefs
  end

  def whiteList_or_blackList(addressObj)
    begin
      if addressObj.regex_match == "ip_6"
        the_Ping_Machine=curl_address("http://[#{addressObj['address']}]/")
      else
        the_Ping_Machine=curl_address(addressObj['address'])
      end
      if the_Ping_Machine.body_str.length > 4 #brackets=empty + 2. Totally arbitrary
        scrape_and_categorize(addressObj)
      end
    rescue Curl::Err::TimeoutError
      if addressObj.regex_match=="ip_6" || addressObj.regex_match=="ip_4"
        $white_list.push({addressObj:addressObj,categories:[Standard_Categories['Inactive']]})
      elsif addressObj.regex_match=="url_or_email"
        $white_list.push({addressObj:addressObj,categories:[Standard_Categories['Inactive']]})
      elsif addressObj.regex_match=="bit_message"
        # $white_list.push({addressObj:addressObj,categories:[]})
      else
        $white_list.push({addressObj:addressObj,categories:[Standard_Categories['Inactive'],Standard_Categories['Uncategorized']]})
      end
    rescue Curl::Err::GotNothingError
      $white_list.push({addressObj:addressObj,categories:[Standard_Categories['Inactive'],Standard_Categories['Uncategorized']]})
    rescue Curl::Err::ConnectionFailedError, Curl::Err::RecvError
      $white_list.push({addressObj:addressObj,categories:[Standard_Categories['Inactive'],Standard_Categories['Connection Failed']]})
    rescue Curl::Err::SSLConnectError,Curl::Err::SSLPeerCertificateError,Curl::Err::SSLCACertificateError
      $white_list.push({addressObj:addressObj,categories:[Standard_Categories['Inactive'],Standard_Categories['SSL Connection Failure']]})
    rescue Curl::Err::MalformedURLError,Curl::Err::HostResolutionError,Curl::Err::UnsupportedProtocolError
      $black_list.push(addressObj)
    end
  end








  def name_server_cycle
     Address.joins(:address_tags,:tags).where('tags.title=?','Name Server').uniq.find_in_batches do |batch|
      puts batch.count
      batch.each {|x| puts "#{x.value},#{batch.index x}" }
      batch.each do |addressObj|
        puts "=========================================================="
        puts addressObj.value
        puts "=========================================================="
        list_of_chain_entries=NmcAddress.where(address_id: addressObj.id)
        list_of_chain_entries.each do |x|
          list_of_combos=Address.joins(:nmc_addresses).where('nmc_addresses.nmc_chain_entry_id=?',x.nmc_chain_entry_id)
          list_of_combos.each {|o| puts o.value }

        end

      end 
    end
   # commit_white_list
  end









  
#     def name_server_cycle
#      Address.joins(:address_tags,:tags).where('tags.title=?','Name Server').find_in_batches do |batch|
#      # Address.where(regex_match:"name_server",categorized:false).find_in_batches do |batch|
#       batch.each do |addressObj|

# # This is where we need to take an address tagged with Name Server and cycle the addresses associated with this 'name server address'


#         address_list=Address.joins(nmc_addresses:,:nmc_chain_entries).where('nmc_chain_entries.id=?',addressObj: addressObj.id)
#         prefixes=["","http://","https://"]
#         suffixes=["",".",".com.",".net.",".bit"]
#         host=addressObj.address
#         possibleNameCoinVal=NmcChainEntry.find(addressObj.nmc_chain_entry_id).link["name"].gsub(/d\//,"")
#         # puts addressObj.address
#         address_list.each do |addressObj|
#           prefixes.each do |pref|
#             suffixes.each do |suf| 
#               puts "Attempting to access: #{pref}#{possibleNameCoinVal}#{suf}"
#               ping_with_ns("#{pref}#{possibleNameCoinVal}#{suf}",host,addressObj)#with the other pref/suffixes
#             end
#           end
#         end
        
#         address_list.each do |addressObj|
#           prefixes.each do |pref|
#             next if  addressObj.address[0..pref.length] == pref
#             suffixes.each do |suf|
#               next if  addressObj.address[-suf.length..-1] == suf
#               puts "Attempting to access: #{pref}#{possibleNameCoinVal}#{suf}"
#               ping_with_ns("#{pref}#{addressObj.address}#{suf}",host,addressObj)#with the other pref/suffixes
#             end
#           end
#         end
#       end
#     end
#     commit_white_list
#   end











  def ping_with_ns(string,host,addressObj)
    begin
      ping_result = curl_address(string,host)
    rescue Curl::Err::TimeoutError => e
      puts e.message
    rescue Curl::Err::GotNothingError => e
      puts e.message
    rescue Curl::Err::ConnectionFailedError, Curl::Err::RecvError => e
      puts e.message
    rescue Curl::Err::SSLConnectError,Curl::Err::SSLPeerCertificateError,Curl::Err::SSLCACertificateError => e
      puts e.message
    rescue Curl::Err::MalformedURLError,Curl::Err::HostResolutionError,Curl::Err::UnsupportedProtocolError => e
      puts e.message, string,host
    end
    begin
      links=scrape_for_links(ping_result.body_str)
      if links.count > 0 
        $white_list.push({addressObj:addressObj,link: links,categories:[Standard_Categories['Name Server']]})
      else
        return
      end
    rescue NoMethodError => e
      puts e.message
    end
  end


  def curl_address(string,name_server=nil) #####TODO: ADD LOGIC TO FIX UP THE URL!!!! If it doesnt contain http/https add/edit so it does and curl!
    
    the_Ping_Machine=Curl::Easy.new(clean_possible_curl_address(string))
    the_Ping_Machine.connect_timeout=5
    if name_server
      the_Ping_Machine.headers["Host"] = name_server
    end
    # the_Ping_Machine.on_success {process_page_content(the_Ping_Machine.body_str)}# 2xx
    # the_Ping_Machine.on_redirect {puts "REDIRCTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz!"}#3xx
    # the_Ping_Machine.on_missing {puts "MISSING%%%%%%%%%%%%%%%%%%%%%%%%"}#4xx
    # the_Ping_Machine.on_failure {puts "FAILURE!!!!!!!!!!!!!!!!!"}#5xx
    # the_Ping_Machine.on_complete {puts "YERS"} #
    the_Ping_Machine.perform
    return the_Ping_Machine
  end

  class Curl_Machine
    def initialize(service_url)
      @uri = URI.parse(service_url)
    end
   
    def method_missing(name, *args)
      post_body = { 'method' => name, 'params' => args, 'id' => 'jsonrpc' }.to_json
      # resp = JSON.parse( http_post_request(post_body) )
      raise Curl_Machine_Error, resp['error'] if resp['error']
      resp['result']
    end
   
    def http_post_request(post_body) #why did I make this? totally forgot
      # http    = Net::HTTP.new(@uri.host, @uri.port)
      request = Net::HTTP::Get.new(@uri.request_uri)
      # request.basic_auth @uri.user, @uri.password
      # request.content_type = 'application/json'
      request.body = post_body
      http.request(request).body
    end
   
    class Curl_Machine_Error < RuntimeError; end
  end



end


          # batch.delete_if {|x| x["address"] ==  addressObj["address"]}
