# think about resolvin gthe name server address befire crawling



class Address < ActiveRecord::Base
	# extend Crawl
	# scope :name_servers, where(subscribed_to_newsletter: true)
	has_many :hyperlinks, dependent: :destroy
	has_many :address_tags,dependent: :destroy
	has_many :tags, through: :address_tags
	has_many :nmc_addresses,dependent: :destroy
	has_many :nmc_chain_entries, through: :nmc_addresses
	accepts_nested_attributes_for :nmc_chain_entries
	FILTER={
    "ip_4" => /\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/,

    "ip_6"=>/(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/i,
    
    "Bit Message"=>/(BM-(?:(?![IlO0])[A-Za-z0-9]){32,34})/i,
    

    "email"=>/([\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+)/i,

    
    # "url"=>/((?<=[\s|\A|^])((https?)?:\/\/)?[^@\s\}\{\'\"\\\,\(\)]{1,}\.(\D{1,}(?=[\s|\z|$])))/i
    "URL" => /((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?/i
    # "one_name_protocol"=>// #Dunno if ill end up using this


  }
  def cousins_in_nmc(nmc_chain_entry,options={}) #take NmcChainEntry or id of NmcChainEntry and returns all cousins in that NmcChainEntry
  	identifier = nmc_chain_entry.is_a?(Fixnum) ? nmc_chain_entry : nmc_chain_entry.id
  	# sql="select distinct addresses.value from addresses inner join nmc_addresses on addresses.id=nmc_addresses.address_id inner join address_tags on address_tags.id=addresses.id inner join tags on tags.id=address_tags.tag_id where nmc_addresses.nmc_chain_entry_id=#{identifier}"


  	sql="select addresses.value from nmc_chain_entries inner join nmc_addresses on nmc_chain_entries.id=nmc_addresses.nmc_chain_entry_id inner join addresses on addresses.id=nmc_addresses.address_id inner join address_tags on addresses.id=address_tags.address_id where tag_id != 6 and tag_id != 9 and tag_id != 10 and nmc_addresses.nmc_chain_entry_id=#{identifier}"

  	# Address.find_by_sql("select addresses from nmc_chain_entries inner join nmc_addresses on nmc_chain_entries.id=nmc_addresses.nmc_chain_entry_id inner join addresses on addresses.id=nmc_addresses.address_id inner join address_tags on addresses.id=address_tags.address_id where tag_id != 6 and tag_id != 9 and tag_id != 10 and nmc_addresses.nmc_chain_entry_id=#{identifier}")


  	if options["exclude"] && options["exclude"].count > 0
  		options["exclude"].each do |exclusion|
  			sql = sql + "and tag_id != #{exclusion}"
  		end
  	Address.find_by_sql(sql)
  	end
  end

	def self.split_scan_json(json_hash,nmcObj) #TODO: Add specifications for everything here: http://dot-bit.org/Namespace:Domain_names_v2.0#TLS_support
	  results=[]
	  json_hash.each do |key,val|
	    key ||= " "
	    if key.scan(/(\bns\b)|(\bname_server\b)|(\bnameserver\b)|(\bname\b \bserver\b)/i).count > 0 #Only doing name servers right now because nobody uses the protocols...at all.
	      results.push(build_and_tag_addresses(val.to_s,nmcObj,"Name Server"))
	    else
	      results.push(build_and_tag_addresses(val.to_s,nmcObj))
	    end
	  end
	  results
	end

	def self.segment_addr_string(string) #take a string containing possible address substrings and removes any characters that might conflict with the regexes in the FILTER.
	  characterBlackList=/[\}\{\'\[\"\\\],]/
	  string.gsub('":"'," ").gsub(characterBlackList," ").split(/[\s,]/)
	end

	def self.black_listed?()
	  entryBlackList=["10.0.0.1","10.0.0.","192.168.0.0",nil,"127.0.0.1","127.0.0."] #pretty sure http:* cant happen anymore
	  unless entryBlackList.any? {|x| x == match} || match.gsub(/[\s \n]/,"").empty?
	  	true
	  else
	  	false
		end
	end

	def self.build_and_tag_addresses(string,nmcObj,override=nil) #optional third param to force the 'regex_match' i.e 'name_server' if json key match or any of the specific namecoin protocal header keys...coming soon!
	  results=[]
	    FILTER.each do |key,regex|
	      matches = []
	      segment_addr_string(string).each do |seg|
          match=regex.match(seg).to_a[0]
	      	unless black_listed?(seg)
	      		matches.push seg
	      	end
	      end
	      matches.flatten.each do |match|
	    		match = ( key == "ip_6" ? "[#{match}]" : match )   #ip_v6 addresses need to have brackets
	        unless override #no override = tag address if exists, otherwise make new address and tag
	          if Address.exists?(value:match) #better to begin-rescue to save sql call?
	            o = Address.find_by(value:match)
	            results.push(nmcObj.nmc_addresses.new(address_id:o.id))
	          else
	            tag = Tag.find_by(title:key)
	            o=Address.create(value:match)
	            results.push(o.tag(tag.id),nmcObj.nmc_addresses.new(address_id:o.id))
	          end
	        else 
	          tag = Tag.find(Standard_Tags[override]) #### This is thorough - but intensely difficult to read.
	          addr = Address.find_by(value:match)
	          if addr && AddressTag.exists?(tag_id:tag.id,address_id:addr.id)
	            results.push nmcObj.nmc_addresses.new(address_id:addr.id)
	          elsif addr && !AddressTag.exists?(tag_id:tag.id,address_id:addr.id)
	            results.push nmcObj.nmc_addresses.new(address_id:addr.id),addr.tag(tag.id)
	          else
	            tag = Tag.find(Standard_Tags[override])
	            o=Address.create(value:match)
	            results.push(o.tag(tag.id),nmcObj.nmc_addresses.new(address_id:o.id))
	          end
	        end
	      end
	    end
	  results
	end

	def is_ns?
		self.tags.include?(Tag.find(6)) ? true : false #title: "Name Server"
	end

	def is_tagged_as?(identifier)
		if identifier.is_a? Fixnum
			self.address_tags.include?(Tag.new(id:identifier))
		elsif identifier.is? Tag
			self.address_tags.include?(identifier)
		else
			self.address_tags.include?(Tag.find_by(id:identifier))
		end
	end


	def self.populate_addresses#creates ips/urls/emails/bit messages from the nmc_chain_links
	  # TestNmcEntry.find_in_batches do |batch| 
	  db_batch=DB_Batch.new 
	  NmcChainEntry.find_in_batches do |batch|
	    batch.each do |nmcObj| 
	      next if nmcObj.link["value"].class==NilClass || nmcObj.link["value"].gsub(/[\s \n]/,"").empty? #removes empty string/nil values
	      if jsonObj=nmcObj.is_json? #returns json hash if true, else nil
	        if jsonObj.class != Hash
	          db_batch.white_list(build_and_tag_addresses(jsonObj.to_s,nmcObj)) #should return list of addressobjs + tags
	        else
	          db_batch.white_list(split_scan_json(jsonObj,nmcObj)) #should return list of addressobjs + tagobjs
	        end
	      else
	        unless jsonObj.class==NilClass
	          db_batch.white_list(build_and_tag_addresses(jsonObj.to_s,nmcObj)) #should return list of addressobjs + tags
	        end
	      end
	    end
	    db_batch.commit_white_list
	  end
	end

	def tag(identifier=nil) #returns address_tagObj
		unless identifier==nil
			if identifier.is_a? Fixnum
				self.address_tags.new(tag_id:identifier)
			elsif identifier.is? Tag
				self.address_tags.new(tag_id:identifier.id)
			else
				tag=Tag.find_by(title:identifier)
				self.address_tags.new(tag_id:tag.id,address_id:self.id)
			end
		else
			raise AbstractController::Error
		end
	end

	def tag!(identifier=nil)
		unless identifier==nil
			if identifier.is_a? Fixnum
				tag=Tag.find(identifier)
				self.address_tags.create(tag_id:tag.id,address_id:self.id)
			elsif identifier.is? Tag
				self.address_tags.create(tag_id:indentifier.id ,address_id:self.id)
			else
				tag=Tag.find_by(title:identifier)
				self.address_tags.create(tag_id:tag.id,address_id:self.id)
			end
		else
			raise AbstractController::Error
		end
	end

end
