
class UpdateCacheController < ApplicationController
	require 'pg'
	require 'net/http'
	require 'uri'
	require 'json'

	class NamecoinRPC
	  def initialize(service_url)
	    @uri = URI.parse(service_url)
	  end
	 
	  def method_missing(name, *args)
	    post_body = { 'method' => name, 'params' => args, 'id' => 'jsonrpc' }.to_json
	    # post_body = { 'method' => name, 'params' => args, 'id' => 'jsonrpc' }.to_json
	    resp = JSON.parse( http_post_request(post_body) )
	    raise JSONRPCError, resp['error'] if resp['error']
	    resp['result']
	  end
	 
	  def http_post_request(post_body)
	    http    = Net::HTTP.new(@uri.host, @uri.port)
	    request = Net::HTTP::Post.new(@uri.request_uri)
	    request.basic_auth @uri.user, @uri.password
	    request.content_type = 'application/json'
	    request.body = post_body
	    http.request(request).body
	  end
	 
	  class JSONRPCError < RuntimeError; end
	end

	def buildCache

		counter=0
		lastEntry=""
		doneIndicator=10
		
		begin 
		  h = NamecoinRPC.new('http://user:test@127.0.0.1:8336')
		  response = h.name_scan lastEntry,10
		  doneIndicator = response.count
		  lastEntry = response.last["name"].force_encoding("ISO-8859-1").encode("UTF-8")
		  puts response
		  counter+=1


		  # puts "=================================Cycle #{counter} #{lastEntry} ================================="

		end while @doneIndicator == 10
	end

	# class cacheUpdate
	#   include HTTParty
	#   base_uri 'http://127.0.0.1:8336/'
	#   basic_auth 'user','test'
	#   default_params 
	#   def initialize(u, p)
	#     @auth = {username: u, password: p}
	#   end
	#   # which can be :friends, :user or :public
	#   # options[:query] can be things like since, since_id, count, etc.

	# end

	# update = cacheUpdate.new(config['user'], config['test'])
	# pp update



	# class Partay
	#   include HTTParty
	#   base_uri 'http://localhost:3000'
	# end

	# options = "{"jsonrpc": "1.0", "id":"curltest", "method": "name_scan", "params": ["blah",2] }"

	# pp Partay.post('/pears.xml', options)

end
