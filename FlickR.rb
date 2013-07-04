require 'flickraw-cached'
require 'rubygems'
require 'json'

####################### CONSTANTS ###############################################

PHOTOSET_ID = 72157632363129361 
PRIVACY_FILTER = 4 # private photos visible to friends & family
MEDIA = 'photos'
PICTURES_COUNT = 20
LAST_KNOWN_IMAGES_FILENAME = 'LastKnownImages.txt'
PICTURES_FOLDER = 'Pictures'

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
	photoset.photo[photoset.photo.count - count - 1, count].map { |photo| photo.id }
end

#Delete the images which id are passed in the array
def deleteImages(imagesToDelete)
	imagesToDelete.each do |filename|
		picture_path = 'Pictures/' + filename + '.jpg'
		if File.exists?(picture_path)
			File.delete(picture_path)
		end
	end
end

#Download the images which id are passed in the array
def downloadImages(imagesToDownload)
	imagesToDownload.each do |pic_id|
		photo_info = flickr.photos.getInfo(:photo_id => pic_id)
		photo_url = FlickRaw.url_b(photo_info)  
		puts "Downloading image " + pic_id
		open("Pictures/" + pic_id + ".jpg", "wb") { |file|  
    		file.write(Net::HTTP.get_response(URI.parse(photo_url)).body)  
   		}  
   	end
end

def readLastKnownImages()
	buffer = File.open(LAST_KNOWN_IMAGES_FILENAME, 'r').read
	if buffer.length > 0
		myArray = JSON.parse(buffer)
	else
		myArray = []
	end
end

#Update the list with the id which are passed in the array
def saveLastKnownImages(last20)
	$stdout = File.open(LAST_KNOWN_IMAGES_FILENAME, 'w')
	puts last20.to_json
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

#Retrive the ids of the last pictures downloaded
lastKnownImages = readLastKnownImages()

#Retrieve the last pictures of the set
last20 = getLastPhotosOfSet(PHOTOSET_ID, PICTURES_COUNT)

#Find the old pictures to erase and the new ones to download
imagesToDelete = lastKnownImages - last20

puts "Images to delete:"
imagesToDelete.each do |image|
	puts image
	end

imagesToDownload = last20 - lastKnownImages

puts "Images to download:"
imagesToDownload.each do |image|
	puts image
	end

#Do it!
deleteImages(imagesToDelete)
downloadImages(imagesToDownload)

#Update the list
#saveLastKnownImages(last20)