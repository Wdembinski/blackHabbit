# require 'pg'
# require 'net/http'
# require 'uri'
# require 'json'
# require 'pry'
class History < ActiveRecord::Base
	belongs_to :domain_caches
	include Namecoin

	# class NamecoinRPC
	#   def initialize(service_url)
	#     @uri = URI.parse(service_url)
	#   end
	 
	#   def method_missing(name, *args)
	#     post_body = { 'method' => name, 'params' => args, 'id' => 'jsonrpc' }.to_json
	#     # post_body = { 'method' => name, 'params' => args, 'id' => 'jsonrpc' }.to_json
	#     resp = JSON.parse( http_post_request(post_body) )
	#     raise JSONRPCError, resp['error'] if resp['error']
	#     resp['result']
	#   end
	 
	#   def http_post_request(post_body)
	#     http    = Net::HTTP.new(@uri.host, @uri.port)
	#     request = Net::HTTP::Post.new(@uri.request_uri)
	#     request.basic_auth @uri.user, @uri.password
	#     request.content_type = 'application/json'
	#     request.body = post_body
	#     http.request(request).body
	#   end
	 
	#   class JSONRPCError < RuntimeError; end
	# end

	def self.resetIdSeq
		sql = "ALTER SEQUENCE histories_id_seq RESTART WITH 1;"
		if (ActiveRecord::Base.connection.execute(sql))
			puts "Histories ID sequence reset"
		else
			puts "Error: Histories ID Sequence reset failed"
		end
	end

	def self.updateHistories	
		DomainCache.find_in_batches do |cache|
			h = NamecoinRPC.new('http://user:test@127.0.0.1:8337')
			cache.each do |e|
				begin
					name=e.name.gsub("'","")
					cacheHistory=h.name_history(name)
					id=e.id
					cacheHistory.each do |history|
						o = History.new
						o.transactionId=history["txid"]
						o.address=history["address"]
						o.domain_cache_id=id
						o.save
						if o.save
							puts "Success"
						end
					end
					# puts "=====================================================#{name}"
				rescue History::NamecoinRPC::JSONRPCError
					id=e.id
					o=AbnormalName.create(domain_cache_id: id)
				end
			end
		end
	end
end
