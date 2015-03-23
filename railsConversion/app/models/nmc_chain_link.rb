	include Namecoin
	include Crawl
	require 'json'
class NmcChainLink < ActiveRecord::Base

	has_many :abnormal_jsons
	has_many :json_histories
	WHITE_LIST={
		"ip_4" => /\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/,
		"ip_6"=>/(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/,

		# "url"=>/(?:")(https?:\/\/)?(\S+\.)\S+\.?+(?:")/
		"url"=>/((https?:\/\/)?(\S+\.)\S+\.?+)/
	}


	def self.populate
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
			    	singleResponse.each do |key, value| 
			    		value.to_s.force_encoding("ISO-8859-1").encode("UTF-8")
			    	end
			    	# puts singleResponse
			    	begin
			    		NmcChainLink.create(link: singleResponse)
			    	rescue => e
			    		puts e
			    	end
			    end
		    	counter+=1 		  # select * from cache1 where name like '%dot%'; just cute basic search.
			end
		end          #select * from cache1 where name = $$'!'$$; example query
	end


	def self.flatten(enumerable,bool=false) #Flattens stuff recursively. Returns set if bool is true - removes dups etc
		bool ? result=Set.new : result=[]
		test=Proc.new do |x| 
			if x.is_a? Array || Hash
				x.flatten.each(&test)
			else
				bool ? result.add(x) : result.push(x)
			end
		end
		enumerable.each(&test)
		result
	end





	def self.findAddresses #returns ips or urls from the nmc_chain_links.
		characterBlackList=/(\}|\{)|(\}\})|(\')/
		NmcChainLink.find_in_batches do |json_batch|
			json_batch.each do |json|
				next if json["link"]["value"].is_a? NilClass || json["link"]["value"].length==0
				                         #(ip[^a-zA-Z].?[\sa-zA-Z:"0-9\.{}]*)|
				list_of_matches=[]
				if json["link"]["value"].to_s.gsub(/(\s*)|(\n)/,"").length > 2
				  WHITE_LIST.each do |key,regex|
				  	list_of_matches=flatten(json["link"]["value"].to_s.gsub('":"'," ").scan(regex))
				  	# list_of_matches.each { |entry| puts "#{list_of_matches.find_index(entry)}---------#{entry}=====#{json.id}========#{key}"}

				  	list_of_matches.each do |entry| 
				  		next if entry==nil
				  	puts json.id, entry

				  		PossibleAddress.create(nmc_chain_link_id: json.id,address: entry)
				  	end
				  end
				  # lists_of_lists_of_matches=flatten(json["link"]["value"].to_s.scan(WHITE_LIST["ip_4_regex"]))
				  # puts lists_of_lists_of_matches
				  # lists_of_lists_of_matches=flatten(json["link"]["value"].to_s.scan(WHITE_LIST["ip_6_regex"]))
				  # puts lists_of_lists_of_matches
				  # lists_of_lists_of_matches=flatten(json["link"]["value"].to_s.scan(WHITE_LIST["best_url_regex_i_can_do"]))
				  # puts lists_of_lists_of_matches
				  
				end
			end
		end
	end

end
#############################  select * from nmc_chain_links jsonb_to_recordset(x) where link->>'value' like '%"ip":%';  USES JSONB DUDE!!!
# website.?[\s\\\/a-zA-Z0-9:{}'"_.-]*)|(url.?[\\\/a-zA-Z0-9:{}'"_.-]*,)