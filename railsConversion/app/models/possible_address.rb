class PossibleAddress < ActiveRecord::Base
	belongs_to :nmc_chain_links
	has_many :category_memberships,dependent: :destroy
	has_many :categories, through: :category_memberships, source: :possible_address_category
	include Crawl
	Standard_Categories={"Ip Address" => 1, "URL"=>2,"Email"=>3,"Uncategorized"=>4,"Inactive"=>5, "Bit Message"=>6,"Connection Failed"=>7,"Active"=>8,"SSL Connection Failure"=>9}
	VALID_EMAIL_REGEX = /(\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z)/i
	VALID_BM_REGEX = /(BM-(?:(?![IlO0])[A-Za-z0-9]){32,34})/i #bit message
  $white_list=[]
  $black_list=[]

	def self.flatten(enumerable,bool=false) #Flattens enumerables recursively. Uses Set if bool is true - removes dups
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





  def self.commit_white_list
  	$white_list.each do |whiteListEntry|
  		g=PossibleAddress.where(address: whiteListEntry[:address].address)
  		g.each do |addressObj|
	  		if whiteListEntry[:categories].class==Array
	  				whiteListEntry[:categories].each do |cat|
	  				addressObj.category_memberships.create(possible_address_category_id:cat)
	  			end
	  		else whiteListEntry[:categories].class==Fixnum
	  			addressObj.category_memberships.create(possible_address_category_id:whiteListEntry[:categories])
	  		end
	  	end
  	end
  	$white_list.clear
  end
  


  def self.commit_black_list
  	$black_list.each do |x|
  		PossibleAddress.delete_all(address:x[:address])
  	end
  	$black_list.clear
  end


  def self.clean_possible_address(string)
		string.gsub(/[\s\,\"\'\}\{]/,"")
  end

	def self.is_email?(string)
		flatten(string.scan(VALID_EMAIL_REGEX)).compact.count > 0 ? true:false
	end

	def self.is_bit_message?(string)
		flatten(string.scan(VALID_BM_REGEX)).compact.count > 0 ? true:false
	end

	def self.curl_address(string)
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


	def self.scrape_and_categorize(addressObj)
		links=scrape_for_links(addressObj["address"])
		PossibleAddress.where(address: addressObj["address"]).each {|x| x.update(links: links, categorized:true)}
	end

  def self.scrape_for_links(xml_page) #xml is like violence.
  	page = Nokogiri::HTML(xml_page)
  	links= page.css('a')
 	  hrefs = links.map {|link| link.attribute('href').to_s.uniq.sort.delete_if {|href| href.empty?}}
 	  return hrefs
 	end








	def self.whiteList_or_blackList(addressObj)
		begin
			the_Ping_Machine=curl_address(addressObj["address"])
			if the_Ping_Machine.body_str.length > 0
				scrape_and_categorize(addressObj)
			end
		rescue Curl::Err::TimeoutError
			if addressObj.regex_match=="ip_6" || addressObj.regex_match=="ip_4"
				$white_list.push({address:addressObj,categories:['Inactive','Ip Address']})
			elsif addressObj.regex_match=="url_or_email"
				$white_list.push({address:addressObj,categories:[Standard_Categories['Inactive'],Standard_Categories['URL']]})
			else
				$white_list.push({address:addressObj,categories:[Standard_Categories['Inactive'],Standard_Categories['Uncategorized']]})
			end
		rescue Curl::Err::ConnectionFailedError
			$white_list.push({address:addressObj,categories:[Standard_Categories['Inactive'],Standard_Categories['Connection Failed']]})
		rescue Curl::Err::SSLConnectError
			$white_list.push({address:addressObj,categories:[Standard_Categories['Inactive'],Standard_Categories['SSL Connection Failure']]})
		rescue Curl::Err::MalformedURLError,Curl::Err::HostResolutionError
			$black_list.push({address:addressObj["address"]})
		end
	end









	def self.investigate_addresses

		PossibleAddress.where('categorized IS NULL OR categorized = ?', false).find_in_batches do |batch|
		# PossibleAddress.find_in_batches do |batch|

			batch.each do |addressObj|
				if is_email?(clean_possible_address(addressObj["address"])) #email addressses are almost 100% accurate on first go through
					
					$white_list.push({address:addressObj,categories:Standard_Categories["Email"]})
	        batch.delete_if {|x| x["address"] ==  addressObj["address"]}

				elsif is_bit_message?(clean_possible_address(addressObj["address"]))
					$white_list.push({address:addressObj,categories:Standard_Categories["Bit Message"]})
					batch.delete_if {|x| x["address"] ==  addressObj["address"]}
				else

					whiteList_or_blackList(addressObj) #Should either be ip address or url by now
					batch.delete_if {|x| x["address"] ==  addressObj["address"]}
				end
			end
 			commit_white_list
			commit_black_list
		end
	end
end
