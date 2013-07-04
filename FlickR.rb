require 'flickraw-cached'

####################### CONSTANTS ###############################################

PHOTOSET_ID = 72157632363129361 
PRIVACY_FILTER = 4 # private photos visible to friends & family
MEDIA = 'photos'
PICTURES_COUNT = 20

####################### METHOD DEFINITIONS ######################################

#Query the [page*500:(page+1)*500] pictures of a photoset
def getPhotos(photosetid, page)
	photoset = flickr.photosets.getPhotos(:photoset_id => photosetid, :privacy_filter => PRIVACY_FILTER, :media => MEDIA, :page => page)
end

#Retrieves "count" pictures from the set with "photosetid"
def getLastPhotosOfSet(photosetid, count)
	i = 1
	photoset = getPhotos(photosetid, i)
	until photoset.photo.count < 500
		i += 1
		photoset = getPhotos(photosetid, i)
	end
	last20 = photoset.photo[photoset.photo.count - count - 1, count]
end

####################### SCRIPT ##################################################

#Temporary keys to revoke
FlickRaw.api_key="89a9b710d93bb47c4d515f66bd11e2b8"
FlickRaw.shared_secret="c181975cafc6a102"

	#Get an access token
	#token = flickr.get_request_token
	#auth_url = flickr.get_authorize_url(token['oauth_token'], :perms => 'delete')
	#
	#puts "Open this url in your process to complete the authication process : #{auth_url}"
	#puts "Copy here the number given when you complete the process."
	#verify = gets.strip
	#
	#begin
	#  flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], verify)
	#  login = flickr.test.login
	#  puts "You are now authenticated as #{login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}"
	#rescue FlickRaw::FailedResponse => e
	#  puts "Authentication failed : #{e.msg}"
	#end

#Temporary dev tokens to revoke
flickr.access_token = "72157634478049638-2426944c97e49396"
flickr.access_secret = "ee8725e2830876c9"

login = flickr.test.login
puts "You are now authenticated as #{login.username}"

#Retrieve the last "PICTURES_COUNT" pictures of the set
last20 = getLastPhotosOfSet(PHOTOSET_ID, PICTURES_COUNT)

puts "The last pictures found are:"
last20.each do |photo|
	puts photo.id
end

