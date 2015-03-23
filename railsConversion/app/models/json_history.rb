class JsonHistory < ActiveRecord::Base
	include Namecoin
	belongs_to :nmc_chain_links
	def self.resetIdSeq
		sql = "ALTER SEQUENCE json_histories RESTART WITH 1;"
		if (ActiveRecord::Base.connection.execute(sql))
			puts "AbnormalName ID sequence reset"
		else
			puts "Error: AbnormalName ID Sequence reset failed"
		end
	end

	def self.updateHistories	
		NmcChainLink.find_in_batches do |batch|
		# DomainCache.find_in_batches do |cache|
			h = NamecoinRPC.new('http://user:test@127.0.0.1:8337')

			batch.each do |e|
				begin
					name = e["link"]["name"]
					id=e.id
					json_history_batch=h.name_history(name)
					json_history_batch.each do |hist|
						hist["value"]=hist["value"].encode('utf-8', 'iso-8859-1').encode( 'UTF-8', 'Windows-1251' )
						begin
							JsonHistory.create(history: hist, nmc_chain_link_id:id)
						rescue JSON::GeneratorError
							JsonHistory.create(history: hist, nmc_chain_link_id:id)
							AbnormalJson.create(nmc_chain_link_id: id) #PROBLEM:This abnormalname thing is not specific enought to be useful.
							return
						end
					end	
				# rescue Namecoin::NamecoinRPC::JSONRPCError
					AbnormalJson.create(nmc_chain_link_id: id) #Some of the character that come through the blockchain cant even be recognized by the namecoin client (?) pretty weird.
				end
			end
		end
	end
end
