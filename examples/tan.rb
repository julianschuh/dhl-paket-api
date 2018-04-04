require_relative './common'

print "Access Token: "
access_token = gets.chomp

print "mTan Token: "
mtan_token = gets.chomp

############################################################
####################### Retrieve mTan ######################
############################################################

uri = URI('https://app.dhl.de/mTan')

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
dict = {
    "generate" => false,
    "mtan" => true
}
body = JSON.dump(dict)

req =  Net::HTTP::Post.new(uri)
req.add_field "Content-Type", "application/json; charset=utf-8"
req.add_field "Interface-Key", INTERFACE_KEY
req.add_field "Authorization", "Bearer " + access_token
req.add_field "Emmi-Api-Version", EMMI_API_VERSION
req.add_field "Token", mtan_token
req.body = body

res = http.request(req)

content = JSON.parse(res.body)

if res.code.to_i == 500 && !content
	puts "Could not retreiev current mTan, looks like a server error."
	exit
elsif res.code.to_i == 500
	puts "mTan not available: " + content["errorText"]
	exit
else
	puts "mTan: " + content["mTan"]
end

