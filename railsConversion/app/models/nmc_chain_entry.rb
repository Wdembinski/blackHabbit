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

    # "url"=>/(?:")(https?:\/\/)?(\S+\.)\S+\.?+(?:")/
    "url_or_email"=>/((https?:\/\/)?(\S+\.)\S+\.?+)/,
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








  def self.find_PossibleAddresses #returns ips/urls/emails from the nmc_chain_links very loosely. Even returns fragments of stuff.
    characterBlackList=/[\}\{\'\"]|[,]|(\.\z|\.$)/
    NmcChainEntry.find_in_batches do |json_batch|
      json_batch.each do |json|
        next if json["link"]["value"].is_a? NilClass || json["link"]["value"].length==0
        list_of_matches=[]
        if json["link"]["value"].to_s.gsub(/[\s\n]/,"").length > 4 #two quotes plus min of two chars
          WHITE_LIST.each do |key,regex|

            list_of_matches=flatten(json["link"]["value"].to_s.gsub('":"'," ").scan(regex),true)
            list_of_matches.each do |entry|
          	  next if entry.class==NilClass || entry==nil #are these the same?
              PossibleAddress.create(nmc_chain_link_id: json.id,address: entry.gsub(characterBlackList,""),regex_match:key)
            end
          end
        end
      end
    end
  end
end










#############################  select * from nmc_chain_links jsonb_to_recordset(x) where link->>'value' like '%"ip":%';  USES JSONB!!!
# website.?[\s\\\/a-zA-Z0-9:{}'"_.-]*)|(url.?[\\\/a-zA-Z0-9:{}'"_.-]*,)