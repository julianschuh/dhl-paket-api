require_relative './common'

print "Refresh Token: "
refresh_token = gets.chomp

############################################################
####################### Renew Tokens #######################
############################################################

uri = URI('https://app.dhl.de/oauth/token/request')

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true


req =  Net::HTTP::Post.new(uri)
req.add_field "Client_id", CLIENT_ID
req.add_field "Interface-Key", INTERFACE_KEY
req.add_field "Emmi-Api-Version", EMMI_API_VERSION
req.add_field "Authorization", "Refresh " + refresh_token
req.add_field "Content-Type", "application/json; charset=utf-8"

res = http.request(req)

if res.code.to_i != 200
	puts "Did not receive 200 (got " + res.code.to_s + ")"
	puts res.body
	exit
end
tokens = JSON.parse!(res.body)

access_token = tokens["accessToken"]
access_validity = tokens["accessValidity"]
refresh_token = tokens["refreshToken"]

puts "Acecss Token (Valid: " + access_validity.to_s + "): "
puts access_token

puts "Refresh Token: "
puts refresh_token


