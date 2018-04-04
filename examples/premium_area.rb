require_relative './common'

print "Access Token: "
access_token = gets.chomp

############################################################
####################### Premium Area #######################
############################################################

uri = URI('https://app.dhl.de/premium-area')

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

req =  Net::HTTP::Get.new(uri)
req.add_field "Interface-Key", INTERFACE_KEY
req.add_field "Authorization", "Bearer " + access_token
req.add_field "Emmi-Api-Version", EMMI_API_VERSION

res = http.request(req)

content = JSON.parse(res.body)
puts content.to_s
