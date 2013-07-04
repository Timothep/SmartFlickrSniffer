config = readConfig()

#Temporary keys to revoke
FlickRaw.api_key=config[0]
FlickRaw.shared_secret=config[1]

Get an access token
token = flickr.get_request_token
auth_url = flickr.get_authorize_url(token['oauth_token'], :perms => 'delete')

puts "Open this url in your process to complete the authication process : #{auth_url}"
puts "Copy here the number given when you complete the process."
verify = gets.strip

begin
  flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], verify)
  login = flickr.test.login
  puts "You are now authenticated as #{login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}"
rescue FlickRaw::FailedResponse => e
  puts "Authentication failed : #{e.msg}"
end

#Update the configuration
config << flickr.access_token
config << flickr.access_secret

$stdout = File.open('config', 'w')
puts config.to_json