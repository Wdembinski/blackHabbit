class PossibleAddress < ActiveRecord::Base
	has_many :category_memberships,dependent: :destroy
	has_many :categories, through: :category_memberships, source: :possible_address_category
	include Crawl
	VALID_EMAIL_REGEX = /(\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z)/i
	VALID_BM_REGEX = /(BM-(?:(?![IlO0])[A-Za-z0-9]){32,34})/i



	def self.ping_address(string,bool=false) #return body of response if true
		response=[]
		begin
			ping_Machine=Curl::Easy.new(string)
			ping_Machine.connect_timeout=3
			# ping_Machine.on_success {response.push [true,  ping_Machine.response_code.to_s]}# 2xx
			# ping_Machine.on_redirect {response.push [true, ping_Machine.response_code.to_s]}#3xx
			# ping_Machine.on_missing {response.push [true,  ping_Machine.response_code.to_s]}#4xx
			# ping_Machine.on_failure {response.push [false, ping_Machine.response_code.to_s]}#5xx
			ping_Machine.perform
			if bool==true
				response.push ping_Machine.body_str
			end
			return response.flatten
		end
	end

	def self.validate_address(string)
		begin
			# Jon-won fu - This is a cool regex, however, chose to cast a wider net and validate a lot more stuff by curling it.
			# ParseMe p[2] if p = /^(https?)?(.*)$/.match string
			if string.match(/[^\A](https?)/)
				return true
			elsif IPAddress.valid? string
				return true
			elsif PublicSuffix.parse(string)
				return true
			else
				return false
			end
		rescue PublicSuffix::DomainInvalid
			# puts "There was an error! #{e.class}:#{e.message}"
			return false
		end
	end



	def self.flatten(enumerable,bool=false) #Flattens stuff recursively. Uses Set if bool is true - removes dups
	  bool ? result=Set.new : result=[]
	  bomb=Proc.new do |x| 
	    if x.is_a? Array || Hash
	      x.flatten.each(&bomb)
	    else
	      bool ? result.add(x) : result.push(x)
	    end
	  end
	  enumerable.each(&bomb)
	  result.to_a
	end

	def self.is_email?(string)
		flatten(string.scan(VALID_EMAIL_REGEX)).compact.count > 0 ? true:false
	end
	def self.is_bit_message?(string)
		flatten(string.scan(VALID_BM_REGEX)).compact.count > 0 ? true:false
	end


  def self.clean_possible_address(string)
		string.gsub(/[\s\,\"\'\}\{]/,"")
  end

  def self.process_page_content(xml_page) #xml is like violence.
  	page = Nokogiri::HTML(xml_page)
  	links= page.css('a')
 	  hrefs = links.map {|link| link.attribute('href').to_s}.uniq.sort.delete_if {|href| href.empty?}
 	  return hrefs
 	end

	def self.investigate_addresses
		black_list=[]  #An array of already investigated and failed addresses!
		PossibleAddress.find_in_batches do |batch|
			batch.each do |address|
				if black_list.include?(address)
					PossibleAddress.find(address.id).destroy
				elsif is_email?(clean_possible_address(address["address"]))
					puts "++++++++++++++++++++++++++++++++++++++++++++++++++++"
					o=PossibleAddressCategory.where(name: 'Email').take
					address.category_memberships.create!(possible_address_category_id:o.id)
				elsif is_bit_message?(clean_possible_address(address["address"]))
					o=PossibleAddressCategory.where(name: 'Bit Message').take
					address.category_memberships.create!(possible_address_category_id:o.id)
				else
					begin
						the_Ping_Machine=Curl::Easy.new(clean_possible_address(address["address"]))
						the_Ping_Machine.connect_timeout=5
						# the_Ping_Machine.on_success {process_page_content(the_Ping_Machine.body_str)}# 2xx
						# the_Ping_Machine.on_redirect {puts "REDIRCTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz!"}#3xx
						# the_Ping_Machine.on_missing {puts "MISSING%%%%%%%%%%%%%%%%%%%%%%%%"}#4xx
						# the_Ping_Machine.on_failure {puts "FAILURE!!!!!!!!!!!!!!!!!"}#5xx
						# the_Ping_Machine.on_complete {puts "YERS"} #
						the_Ping_Machine.perform
						if the_Ping_Machine.body_str.length > 0
							links=process_page_content(the_Ping_Machine.body_str)
							address.update(links: links)
							o=PossibleAddressCategory.where(name: 'Active').take
								address.category_memberships.create!(possible_address_category_id:o.id)
						end
					rescue Curl::Err::MalformedURLError
						black_list.push(address)
						PossibleAddress.find(address.id).destroy
					rescue Curl::Err::HostResolutionError
						black_list.push(address)
						PossibleAddress.find(address.id).destroy
					rescue Curl::Err::TimeoutError
						if address.regex_match=="ip_4_or_email" || address.regex_match=="ip_6" || address.regex_match=="ip_4"
							o=PossibleAddressCategory.where(name: 'Ip Address').take
								address.category_memberships.create!(possible_address_category_id:o.id)
							g=PossibleAddressCategory.where(name: 'Inactive').take
								address.category_memberships.create!(possible_address_category_id:g.id)
						elsif address.regex_match=="url" || address.regex_match=="URL" #GEHTTO FIX SOON!!!!!!!!!!!!!!!!!!
							o=PossibleAddressCategory.where(name: 'URL').take
							address.category_memberships.create!(possible_address_category_id:o.id)
							g=PossibleAddressCategory.where(name: 'Inactive').take
								address.category_memberships.create!(possible_address_category_id:g.id)
						else
							o=PossibleAddressCategory.where(name: 'Uncategorized').take
							address.category_memberships.create!(possible_address_category_id:o.id)
							g=PossibleAddressCategory.where(name: 'Inactive').take
								address.category_memberships.create!(possible_address_category_id:g.id)
						end
					rescue Curl::Err::ConnectionFailedError
						o=PossibleAddressCategory.where(name: 'Connection Failed').take
						address.category_memberships.create!(possible_address_category_id:o.id)
						g=PossibleAddressCategory.where(name: 'Inactive').take
							address.category_memberships.create!(possible_address_category_id:g.id)
					end
				end
			end
		end
	end
end
