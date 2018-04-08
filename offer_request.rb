#!./bin/ruby

require 'date'
require 'Base64'
require 'json'
require 'net/http'

def auth_params(client_id, password)
  date = DateTime.now.iso8601 # check timezone??
  digest = OpenSSL::Digest.new('sha256')
  signature = Base64.encode64(OpenSSL::HMAC.digest(digest, password, date)).chomp
  auth = %(ClientID = #{client_id}; Timestamp = #{date}; Signature = #{signature})
end

def get_auth_token
  client_id = 'mhuntley'
  password = 'test'
  headers = auth_params(client_id, password)
  return headers
end

def request_offers!
	authorization = get_auth_token
	puts "#{authorization}"
	content_type = 'application/x-www-form-urlencoded'
	payload = URI.encode_www_form(get_test_payload)
	puts "#{payload}"
	url = 'https://httpbin.org/'
  ## define endpoint
	puts "#{url}"
	response = https_post(url, payload, content_type, authorization, false)
	case response.code.to_i
	when 200 || 201
	  puts [:success]
	when (400..499)
	  puts [:bad_request]
	when (500..599)
	  puts [:server_problems]
	end
  if response.code.to_i == 200
    response_body = JSON.parse(response.body)
  	@id = response_body['success']['id']
    @key = response_body['success']['key']
  	puts "#{@id} and #{@key}"
    puts "#{response_body}"
  end
  puts "#{response.body}"
end

def https_post(url, payload, content_type, authorization=nil, parse_json=true)
  url = URI(url)
  http = Net::HTTP.new(url.host, url.port)
  # http.use_ssl = false
  # http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Post.new(url)
  unless authorization.nil?
    request['authorization'] = authorization
  end
  request["content-type"] = content_type
  request["cache-control"] = 'no-cache'
  request["core"] = '1001'
  request.body = payload
  response = http.request(request)
  return JSON.parse(response.body) if parse_json
  response
end

def get_test_payload
	{
		'contact' => 'test11',
		'login' => 'test111',
		'response-email' => 'tester1@proxy.com',
		'contact-name' => 'mark',
    'id' => 'mhuntley',
    'pw' => 'test'
   }
end

request_offers!



