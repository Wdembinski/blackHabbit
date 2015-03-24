class DomainCache < ActiveRecord::Base
	require 'uri'
	require 'ipaddr'
	require 'set'
	include Namecoin
	include Crawl
	has_many :histories
	has_many :abnormal_names

	def self.resetIdSeq
		sql = "ALTER SEQUENCE domain_caches_id_seq RESTART WITH 1;"
		if (ActiveRecord::Base.connection.execute(sql))
			puts "AbnormalName ID sequence reset"
		else
			puts "Error: AbnormalName ID Sequence reset failed"
		end
	end



	$addresses=Set.new
	def self.findAll_addresses(iterableObject)
		# puts iterableObject
		iterableObject.each do |entry|
			if entry.respond_to? :each
				findAll_addresses(entry)
			else validate_address(entry)
				$addresses.add?(entry) unless entry.length <=5
			end
		end
	end








	def self.categorize
			count=0
		DomainCache.find_in_batches do |batch|
			batch.each do |address|
				garbage_characters=/(\s){2}/
				begin
					jsonContent = ActiveSupport::JSON.decode(address.value) #Checks if json - namecoin-y format is supposed to be json by convention.
					jsonContent.each do |c| #Checks for possible addresses/url for the crawler.
					  c.each do |x|
					    if x.respond_to? :each
					  		findAll_addresses(x) #global Set object. "$addresses"
							unless $addresses.empty?
								$addresses.each {|a|PossibleAddress.create(domain_cache_id: address.id,address:a)}
								$addresses.clear
							end
					  	elsif validate_address(x)
					  		 PossibleAddress.create(domain_cache_id: address.id,address:x)
					  	else
					  		puts x,"<=============================not valid"
					  	end
					  end
					end
				rescue => e
					puts "THIS DOESNT LOOK LIKE JSON! #{e.class}:#{e.message}"
					if validate_address 
					end
					count+=1
				end
			end
		end
	end









	def self.process_page_content(xml_page) #xml is like violence.
		page = Nokogiri::HTML(xml_page)
		links= page.css('a')
		title = page.css('title')
		body=page.css('body')
		puts body.lines.count
	end





	def self.identifyURLorIPstuff
		DomainCache.find_in_batches do |domain_list|
			domain_list.each do |domain|
				@domain_cache_id=domain.id
				list_possible_locators = domain.value.scan /(ip[^a-zA-Z].?[\sa-zA-Z:"0-9\.{}]*)|(website.?[\s\\\/a-zA-Z0-9:{}'"_.-]*)|(url.?[\\\/a-zA-Z0-9:{}'"_.-]*,)|(\.?[a-zA-Z0-9\.]{0,5}\.?)*|(\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*)/ 
				list_possible_locators.each do |locator|
					locator.each do |x|
						next if x==nil or x=="\n" or x == ""
						x=x.gsub("}","")
						characterBlackList=/(\}|\{)|(\}\})|(\')/ #There is something crazy happening where it wont remove the "}" characters.  Thinking the 'end' of the gsub range is being confused quotes in the string?  "}}}" (x3) is the pattern
						x=x.gsub(characterBlackList,"")
						PossibleAddress.create(domain_cache_id: @domain_cache_id,address:x) #This isnt really a good name for this, its finding anything that could be used to pull content from the internet. URLs, IP, or anything.
						puts x
					end
				end
			end
		end
	end

	def self.populateDomainCache
		counter=0 #increases by 1 ever 100 cycles. helped with some debugging and I dont want to nix it yet
		lastEntry="" #the bottom of the list has a 'name' of an empty string, the next entry is a space character
		doneIndicator=100 #just the batch size. if it decreases in number, it means we've reached the end of the line.
		begin
			while doneIndicator == 100

			    h = NamecoinRPC.new('http://user:test@127.0.0.1:8337')
			    response = h.name_scan lastEntry,100 #some ghetto here.  Probably exists a better/more elegant way of handling this.
			    doneIndicator = response.count
			    lastEntry = response.last["name"].force_encoding("ISO-8859-1").encode("UTF-8")

			    response.each do |singleResponse|
			      next if singleResponse["name"] == lastEntry
			      name=singleResponse["name"].to_s.force_encoding("ISO-8859-1").encode("UTF-8")
			      value=singleResponse["value"].to_s.force_encoding("ISO-8859-1").encode("UTF-8")
			      expires_in=singleResponse["expires_in"]
			      puts "=================================Cycle #{counter} #{name} ================================="
			        if value==nil || value.class!=String then
			          value=nil
			        end
			        if expires_in.class!=Fixnum then
			          expires_in=0
			        end
			        # res  = conn.exec("INSERT INTO cache1 values('#{name}','#{value}','#{expires_in}')")
			        DomainCache.new do |d|
			        	d.name=name
			        	d.value=value
			        	d.expires_in=expires_in
			        	d.save
			        	puts d.save ? "Domain Cache saved!" : "Domain Cache Failed to save!"
			        end
			    end		  # select * from cache1 where name like '%dot%'; just cute basic search.
			end               #select * from cache1 where name = $$'!'$$; example query
		end
	end
end
