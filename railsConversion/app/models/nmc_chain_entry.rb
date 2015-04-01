  include Namecoin
  include Crawl
  require 'json'
class NmcChainEntry < ActiveRecord::Base
  has_many :abnormal_jsons,dependent: :destroy
  has_many :json_histories,dependent: :destroy
  has_many :possible_addresses,dependent: :destroy



  WHITE_LIST={
    "ip_4" => /\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/,

    "ip_6"=>/(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/,
    "bit_message"=>/(BM-(?:(?![IlO0])[A-Za-z0-9]){32,34})/i,




    
    "url_or_email"=>/((https?:\/\/)?(\S+\.)\S+\.?+)/,     # Distinguishes it by a ".includes '@' later."
    "name_server"=>/\Ans|nameserver|(name server)/i #IMPORTANT - just used to scan json keys to see if theyre labeled as name server addresses. I DO NOT USE [ns].something as a nameserver identifier

    # "one_name_protocol"=>// #They have a big a enough presence to go ahead and make a specific set of catch-rules for them.
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
            # puts singleResponse
            begin
              NmcChainEntry.create(link: singleResponse)
            # rescue => e
            #   puts e
            end
          end
          counter+=1       # select * from cache1 where name like '%dot%'; just basic search.
      end
    end          #select * from cache1 where name = $$'!'$$; example query
  end

  def self.scan_for_addresses(string,id,override=nil) #optional third param to force the 'regex_match'
    results=[]
    characterBlackList=/[\}\{\'\"\\\,]/
    entryBlackList=["http://","[]","https://","10.0.0.1","192.168.0.0",nil]
    WHITE_LIST.each do |key,regex|
      g = string.gsub('":"'," ").gsub(characterBlackList," ").scan(regex)
      matches=g.flatten
      unless matches==nil
        matches.each do |match|
        next if match.class != String || entryBlackList.any? {|x| x == match} 
          results.push(PossibleAddress.new(nmc_chain_entry_id:id,address:match,regex_match:override ? override : key))
        end
      end
    end
    results.to_a
  end

  def self.process_json_vals(json_hash,id)
    results=[]
    json_hash.each do |key,val|
      key ||= " "
      if key.scan(WHITE_LIST["name_server"]).count >= 1

        results.push(scan_for_addresses(val.to_s,id,"name_server"))
      else
        results.push(scan_for_addresses(val.to_s,id))
      end
    end
    results.flatten!
  end




  def self.tag_possible_addresses #returns ips/urls/emails from the nmc_chain_links very loosely. Even returns fragments of stuff and guesses what they are.
    NmcChainEntry.find_in_batches do |batch|
      possible_addrs=[]
      batch.each do |entry| 
        next if entry["link"]["value"].class==NilClass || entry["link"]["value"].gsub(/[\s \n]/,"").empty? #removes empty strings/nil values
        nmc_value=entry["link"]["value"]
        if jsonHash=is_json?(nmc_value)
          if jsonHash.class !=Hash
            begin
              possible_addrs.push(scan_for_addresses(jsonHash.to_s,entry.id))
            rescue NoMethodError
              next
            end
          else
            possible_addrs.push process_json_vals(jsonHash,entry.id)
          end
        else
          begin
            possible_addrs.push scan_for_addresses(nmc_value.to_s,entry.id)
          rescue NoMethodError
            next
          end
        end
      end
      possible_addrs.flatten.compact.each{ |x| x.save}
    end
  end
end







#############################  select * from nmc_chain_entries jsonb_to_recordset(x) where link->>'value' like '%"ip":%';  USES JSONB!!!
# website.?[\s\\\/a-zA-Z0-9:{}'"_.-]*)|(url.?[\\\/a-zA-Z0-9:{}'"_.-]*,)




            # begin 
            #   o=scan_for_addresses(nmc_value.to_s) unless o.class==NilClass
            #   results.add(o) unless o.class==NilClass
            #   results.each do |match_hash|
            #     match_hash.each do |x|
            #       x["matches"].each do |match|
            #         next if match.class==NilClass || match.class==Nil
            #           # PossibleAddress.create(nmc_chain_entry_id:entry.id,address:match,regex_match:x["key"])
            #       end
            #     end
            #   end
            # end 