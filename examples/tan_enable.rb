require_relative './common'

print "Access Token: "
access_token = gets.chomp

############################################################
################### Customer Information ###################
############################################################

puts "Retrieving Postnummer..."
uri = URI('https://app.dhl.de/customer-information')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

req =  Net::HTTP::Get.new(uri)
req.add_field "Emmi-Api-Version", EMMI_API_VERSION
req.add_field "Interface-Key", INTERFACE_KEY
req.add_field "Authorization", "Bearer " + access_token

res = http.request(req)
if res.code.to_i != 200
	puts "Error retrieving Postnummer..."
	exit
end

customer_info = JSON.parse!(res.body)
post_number = customer_info["postNumber"]

puts "Postnummer: " + post_number

hsh = post_number.unpack("c*").inject(0) { |h, c| ((h * 31) + c) % 10000 }.to_s.rjust(4, "0")

puts "Hash: " + hsh

############################################################
################### Request Verification ###################
############################################################

uri = URI('https://app.dhl.de/tan/request')

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

req =  Net::HTTP::Post.new(uri)
req.add_field "Emmi-Api-Version", EMMI_API_VERSION
req.add_field "Content-Type", "application/x-www-form-urlencoded"
req.add_field "Interface-Key", INTERFACE_KEY
req.add_field "Authorization", "Bearer " + access_token
req.add_field "X-Uhash", hsh

res = http.request(req)

if res.code.to_i != 204
	puts "Error requesting TAN."
	exit
end

############################################################
################### Perform Verification ###################
############################################################

print "Confirmation Code (SMS): "
confirmation_code = gets.chomp

uri = URI('https://app.dhl.de/tan/token')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
req =  Net::HTTP::Get.new(uri)
req.add_field "X-Uhash", hsh
req.add_field "Interface-Key", INTERFACE_KEY
req.add_field "Authorization", "Bearer " + access_token
req.add_field "Emmi-Api-Version", EMMI_API_VERSION
req.add_field "X-Targethint", "4"
req.add_field "Tan", confirmation_code

res = http.request(req)

if res.code.to_i != 200
	puts "Error requesting mTan token from entered confirmation code, code: " + res.code.to_s
	exit
end

token = JSON.parse!(res.body)

mtan_token = token["token"]

puts "Retrieved mTan Token: "
puts mtan_token

