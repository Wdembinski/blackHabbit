require 'active_support/concern'


module Crawl
  extend ActiveSupport::Concern
  require 'net/http'
  require 'uri'
  require 'json'
    Standard_Categories={"Ip Address" => 1, "URL"=>2,"Email"=>3,"Uncategorized"=>4,"Inactive"=>5, "Bit Message"=>6,"Connection Failed"=>7,"Active"=>8,"SSL Connection Failure"=>9}
    VALID_EMAIL_REGEX = /(\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z)/i
    VALID_BM_REGEX = /(BM-(?:(?![IlO0])[A-Za-z0-9]){32,34})/i #bit message
    $white_list=[]
    $black_list=[]

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
   
    def http_post_request(post_body)
      # http    = Net::HTTP.new(@uri.host, @uri.port)
      request = Net::HTTP::Get.new(@uri.request_uri)
      # request.basic_auth @uri.user, @uri.password
      # request.content_type = 'application/json'
      request.body = post_body
      http.request(request).body
    end
   
    class Curl_Machine_Error < RuntimeError; end
  end





    def flatten(enumerable,bool=false) #Flattens enumerables recursively. Uses Set if bool is true - removes dups
    bool ? result=Set.new : result=[]
    bomb=Proc.new do |x| 
      if respond_to? :each #Just returns what ever was passed in an array, worst case scenario.
        x.flatten.each(&bomb)
      else
        bool ? result.add(x) : result.push(x)
      end
    end
     enumerable.each(&bomb)
    begin
      result.to_a
    rescue NoMethodError
      result
    end
  end

  def commit_white_list
    puts $white_list
    $white_list.each do |whiteListEntry|
      g=PossibleAddress.where(address: whiteListEntry[:addressObj].address)
      g.each do |addressObj|
        begin
          if whiteListEntry[:categories].class==Array
              whiteListEntry[:categories].each do |cat|
              addressObj.category_memberships.create(possible_address_category_id:cat)
            end
          else whiteListEntry[:categories].class==Fixnum
            addressObj.category_memberships.create(possible_address_category_id:whiteListEntry[:categories])
          end

          ### Some of the objects in this list may have had links found when we scraped them. God willing.
          ### If there is a better way of doing this I would love to do it!
          addressObj.update(links: whiteListEntry[:links]) if whiteListEntry[:links]
          addressObj.update(categorized: true)
        end
      end
    end
    $white_list.clear
  end
  


  def commit_black_list
    $black_list.each do |obj|
      PossibleAddress.delete_all(address:obj[:address])
    end
    $black_list.clear
  end


  def clean_possible_address(string)
    string.gsub(/[\s\,\"\'\}\{]/,"")
  end

  def is_email?(string)
    flatten(string.scan(VALID_EMAIL_REGEX)).compact.count > 0 ? true:false
  end

  def is_bit_message?(string)
    flatten(string.scan(VALID_BM_REGEX)).compact.count > 0 ? true:false
  end

  def curl_address(string) #####TODO: ADD LOGIC TO FIX UP THE URL!!!! If it doesnt contain http/https add/edit so it does and curl!
    
    the_Ping_Machine=Curl::Easy.new(clean_possible_address(string))
    the_Ping_Machine.connect_timeout=5
    # the_Ping_Machine.on_success {process_page_content(the_Ping_Machine.body_str)}# 2xx
    # the_Ping_Machine.on_redirect {puts "REDIRCTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz!"}#3xx
    # the_Ping_Machine.on_missing {puts "MISSING%%%%%%%%%%%%%%%%%%%%%%%%"}#4xx
    # the_Ping_Machine.on_failure {puts "FAILURE!!!!!!!!!!!!!!!!!"}#5xx
    # the_Ping_Machine.on_complete {puts "YERS"} #
    the_Ping_Machine.perform
    return the_Ping_Machine
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
      the_Ping_Machine=curl_address(addressObj["address"])
      if the_Ping_Machine.body_str.length > 4 #brackets=empty + 2. Totally arbitrary
        scrape_and_categorize(addressObj)
      end
    rescue Curl::Err::TimeoutError
      if addressObj.regex_match=="ip_6" || addressObj.regex_match=="ip_4"
        $white_list.push({addressObj:addressObj,categories:[Standard_Categories['Inactive'],Standard_Categories['Ip Address']]})
      elsif addressObj.regex_match=="url_or_email"
        $white_list.push({addressObj:addressObj,categories:[Standard_Categories['Inactive'],Standard_Categories['URL']]})
      elsif addressObj.regex_match=="bit_message"
        $white_list.push({addressObj:addressObj,categories:[Standard_Categories['Bit Message']]})
        else
        $white_list.push({addressObj:addressObj,categories:[Standard_Categories['Inactive'],Standard_Categories['Uncategorized']]})
      end
    rescue Curl::Err::GotNothingError
      $white_list.push({addressObj:addressObj,categories:[Standard_Categories['Inactive'],Standard_Categories['Uncategorized']]})
    rescue Curl::Err::ConnectionFailedError
      $white_list.push({addressObj:addressObj,categories:[Standard_Categories['Inactive'],Standard_Categories['Connection Failed']]})
    rescue Curl::Err::SSLConnectError,Curl::Err::SSLPeerCertificateError
      $white_list.push({addressObj:addressObj,categories:[Standard_Categories['Inactive'],Standard_Categories['SSL Connection Failure']]})
    rescue Curl::Err::MalformedURLError,Curl::Err::HostResolutionError,Curl::Err::UnsupportedProtocolError
      $black_list.push(addressObj)
    end
  end


end