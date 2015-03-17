require 'active_support/concern'


module Crawl
  extend ActiveSupport::Concern
  require 'net/http'
  require 'uri'
  require 'json'

  class Curl_Machine
    def initialize(service_url)
      @uri = URI.parse(service_url)
    end
   
    def method_missing(name, *args)
      post_body = { 'method' => name, 'params' => args, 'id' => 'jsonrpc' }.to_json
      # resp = JSON.parse( http_post_request(post_body) )
      raise Curl_Machine_Error, resp['error'] if resp['error']
      resp['result']
    end
   
    def http_post_request(post_body)
      # http    = Net::HTTP.new(@uri.host, @uri.port)
      request = Net::HTTP::Get.new(@uri.request_uri)
      # request.basic_auth @uri.user, @uri.password
      # request.content_type = 'application/json'
      request.body = post_body
      http.request(request).body
    end
   
    class Curl_Machine_Error < RuntimeError; end
  end
end