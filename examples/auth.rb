require_relative './common'

############################################################
################## Initial Authentication ##################
############################################################

state = Base64.urlsafe_encode64(SecureRandom.random_bytes(32))
code = SecureRandom.random_bytes(32)
code_verifier = Base64.urlsafe_encode64(code)
code_challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(code_verifier)).split('=')[0]

puts "Open in Browser, Login and past URL after redirect here:"
puts "https://mobil.dhl.de/oauth-web/oauth/grant?response_type=code&client_id=" + CLIENT_ID + "&scope=" + SCOPE + "&state=" + state + "&code_challenge=" + code_challenge + "&code_challenge_method=" + CODE_CHALLENGE_METHOD

print "URL: "
redirect_url = gets.chomp

tmp_uri = URI.parse(redirect_url)
uri = URI.parse("http://app.dhl.de/?" + tmp_uri.fragment);

parts = CGI::parse(uri.query).map { |k, v| [k, v.first] }.to_h

if parts["state"] != state
	puts "State not equal"
	exit
end

############################################################
############## Exchange Auth. Code for Tokens ##############
############################################################

uri = URI('https://app.dhl.de/oauth/grant/exchange')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
dict = {
        "code_verifier" => code_verifier
    }
body = JSON.dump(dict)

req =  Net::HTTP::Post.new(uri)
req.add_field "Content-Type", "application/json; charset=utf-8"
req.add_field "Code_verifier", code_verifier
req.add_field "Client_id", CLIENT_ID
req.add_field "Interface-Key", INTERFACE_KEY
req.add_field "Emmi-Api-Version", EMMI_API_VERSION
req.add_field "Authorization", "Grant " + parts["code"]
req.body = body

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


