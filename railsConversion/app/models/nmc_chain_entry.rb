  include Namecoin
  include Crawl
  require 'json'


class NmcChainEntry < ActiveRecord::Base
  has_many :abnormal_jsons,dependent: :destroy
  has_many :json_histories,dependent: :destroy
  has_many :nmc_addresses,dependent: :destroy
  has_many :addresses, through: :nmc_addresses
  has_many :tags, through: :addresses
  accepts_nested_attributes_for :addresses



  WHITE_LIST={
    "ip_4" => /\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/,

    "ip_6"=>/(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/i,
    
    "Bit Message"=>/(BM-(?:(?![IlO0])[A-Za-z0-9]){32,34})/i,
    

    "email"=>/([\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+)/i,

    
    # "url"=>/((?<=[\s|\A|^])((https?)?:\/\/)?[^@\s\}\{\'\"\\\,\(\)]{1,}\.(\D{1,}(?=[\s|\z|$])))/i
    "URL" => /((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?/i
    # "one_name_protocol"=>// #Dunno if ill end up using this


  }


  def self.populate
    counter=0 #increases by 1 every 100 cycles. helped with some debugging and I dont want to nix it yet
    lastEntry="" #the bottom of the list has a 'name' of an empty string, the next entry is a white-space character
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
            NmcChainEntry.create(link: singleResponse)
        end
        counter+=1       # select * from cache1 where name like '%dot%'; just basic search.
      end
    end          #select * from cache1 where name = $$'!'$$; example query
  end

  def self.segment_string(string)
    characterBlackList=/[\}\{\'\[\"\\\],]/
    string.gsub('":"'," ").gsub(characterBlackList," ").split(/[\s,]/)
  end

  def self.scan_for_addresses(string,id,override=nil) #optional third param to force the 'regex_match' i.e 'name_server' if json key match or any of the specific namecoin protocal header keys...coming soon!
    results=[]
    entryBlackList=["10.0.0.1","10.0.0.","192.168.0.0",nil,"127.0.0.1"] #pretty sure http:* cant happen anymore
    # entryBlackList=["http","https","http://","[]","https://","10.0.0.1","10.0.0.","192.168.0.0","com","net",nil,"127.0.0.1"] #pretty sure http:* cant happen anymore
      WHITE_LIST.each do |key,regex|

        matches = []
        segment_string(string).each do |seg|
          matches.push regex.match(seg).to_a[0]
        end
        matches.flatten.each do |match|
          next if entryBlackList.any? {|x| x == match} || match.gsub(/[\s \n]/,"").empty?
          unless override
            if Address.exists?(value:match)
              o = Address.where(value:match).take
              results.push(NmcAddress.new(address_id:o.id,nmc_chain_entry_id:id))
            else
              tag = Tag.where(title:key).take
              o=Address.new(value:match)
              o.save
              results.push(AddressTag.new(address_id:o.id,tag_id:tag.id),NmcAddress.new(address_id:o.id,nmc_chain_entry_id:id))
            end
          else
            tag=Tag.where(title:override).take ################################################ This is thorough - but intensely difficult to read.
            addr = Address.where(value:match).take
            if addr && AddressTag.where(tag_id:tag.id,address_id:addr.id).exists?
              results.push NmcAddress.new(address_id:addr.id,nmc_chain_entry_id:id)
            elsif addr && !AddressTag.where(tag_id:tag.id,address_id:addr.id).exists?
              results.push NmcAddress.new(address_id:addr.id,nmc_chain_entry_id:id),AddressTag.new(address_id:addr.id,tag_id:tag.id)
            else
              tag = Tag.where(title:override).take
              o=Address.new(value:match)
              o.save
              results.push(AddressTag.new(address_id:o.id,tag_id:tag.id),NmcAddress.new(address_id:o.id,nmc_chain_entry_id:id))
            end
          end
        end
      end
    results
  end

  def self.process_json_vals(json_hash,id) #TODO: Add specifications for everything here: http://dot-bit.org/Namespace:Domain_names_v2.0#TLS_support
    results=[]
    json_hash.each do |key,val|
      key ||= " "
      if key.scan(/(\bns\b)|(\bnameserver\b)|(\bname\b \bserver\b)/i).count > 0 #Only doing name servers right now because nobody uses the protocols...at all.
        results.push(scan_for_addresses(val.to_s,id,"Name Server"))
      else
        results.push(scan_for_addresses(val.to_s,id))
      end
    end
    results.flatten!
  end


  def self.id_addresses #returns ips/urls/emails from the nmc_chain_links very loosely. Even returns fragments
    # TestNmcEntry.find_in_batches do |batch| 
    NmcChainEntry.find_in_batches do |batch| 
      results=[]
      batch.each do |entry| 
        next if entry.link["value"].class==NilClass || entry.link["value"].gsub(/[\s \n]/,"").empty? #removes empty string/nil values
        if jsonObj=is_json?(entry["link"]["value"])

          if jsonObj.class != Hash
              results.push(scan_for_addresses(jsonObj.to_s,entry.id)) #should return list of addressobjs
          else
            results.push process_json_vals(jsonObj,entry.id) #should return list of addressobjs
          end
        else
          unless jsonObj.class==NilClass
            results.push scan_for_addresses(jsonObj.to_s,entry.id) #should return list of addressobjs
          end
        end
      end
      # results.flatten.compact.each{ |x| puts x }
      results.flatten.compact.each{ |x| x.save }
    end
  end
end






#############################  select * from nmc_chain_entries jsonb_to_recordset(x) where link->>'value' like '%"ip":%';  USES JSONB!!!
# website.?[\s\\\/a-zA-Z0-9:{}'"_.-]*)|(url.?[\\\/a-zA-Z0-9:{}'"_.-]*,)


## Copy-pasta join: select nmc_chain_entries.link,addresses.value from nmc_chain_entries inner join nmc_addresses on nmc_chain_entries.id=nmc_addresses.nmc_chain_entry_id inner join addresses on addresses.id = nmc_addresses.nmc_chain_entry_id;