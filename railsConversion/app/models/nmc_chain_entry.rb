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


  def is_json?
    begin
      JSON.parse(self.link["value"])
    rescue JSON::ParserError
      nil
    end
  end




end






#############################  select * from nmc_chain_entries jsonb_to_recordset(x) where link->>'value' like '%"ip":%';  USES JSONB!!!
# website.?[\s\\\/a-zA-Z0-9:{}'"_.-]*)|(url.?[\\\/a-zA-Z0-9:{}'"_.-]*,)


## Copy-pasta join: select nmc_chain_entries.link,addresses.value from nmc_chain_entries inner join nmc_addresses on nmc_chain_entries.id=nmc_addresses.nmc_chain_entry_id inner join addresses on addresses.id = nmc_addresses.nmc_chain_entry_id;