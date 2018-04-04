require_relative './common'

print "Access Token: "
access_token = gets.chomp

############################################################
#################### Retrieve Shipments ####################
############################################################

uri = URI('https://app.dhl.de/shipments')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
dict = {
        "includeArchived" => false,
        "includeCurrent" => true,
        "shipmentsInCache" => {
            "completedShipmentsInCache" => [],
            "archivedShipmentsInCache" => []
        },
        "languageCode" => "de"
    }
body = JSON.dump(dict)

req =  Net::HTTP::Post.new(uri)
req.add_field "Interface-Key", INTERFACE_KEY
req.add_field "Authorization", "Bearer " + access_token
req.add_field "Emmi-Api-Version", EMMI_API_VERSION
req.add_field "Content-Type", "application/json; charset=utf-8"
req.body = body

res = http.request(req)

content = JSON.parse(res.body)
puts content.to_s