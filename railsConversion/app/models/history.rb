class History < ActiveRecord::Base
	belongs_to :domain_caches
	include Namecoin
	def self.resetIdSeq
		sql = "ALTER SEQUENCE histories_id_seq RESTART WITH 1;"
		if (ActiveRecord::Base.connection.execute(sql))
			puts "Histories ID sequence reset"
		else
			puts "Error: Histories ID Sequence reset failed"
		end
	end

	def self.updateHistories	
		NmcChainLink.find_in_batches do |batch|
		# DomainCache.find_in_batches do |cache|
			h = NamecoinRPC.new('http://user:test@127.0.0.1:8337')
			batch.each do |e|
				begin

					name=e["link"]["name"].gsub("'","") #This is weird now! make sure you look at what the hash structure is like.  Its way different
					cacheHistory=h.name_history(name)
					id=e["id"]
					cacheHistory.each do |h|
						History.new do |o|
							o.transactionId=h["txid"]
							o.address=h["address"]
							o.domain_cache_id=id
							o.save
							puts o.save ? "Success! History saved" : "Failed to save history!"
						end
					end
				rescue History::NamecoinRPC::JSONRPCError
					id=e.id
					o=AbnormalName.create(domain_cache_id: id) #Some of the character that come through the blockchain cant even be recognized by the namecoin client wah wah.
				end
			end
		end
	end
end
