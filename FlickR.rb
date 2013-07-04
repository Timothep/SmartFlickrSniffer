require 'flickraw-cached'
require 'rubygems'
require 'json'

####################### CONSTANTS ###############################################

PHOTOSET_ID = 72157632363129361 
PRIVACY_FILTER = 4 # private photos visible to friends & family
MEDIA = 'photos'
PICTURES_COUNT = 20
PICTURES_FOLDER = 'Pictures/'
IMAGES_EXTENSION = '.jpg'
CONFIG_FILE = 'config'

LAST_KNOWN_IMAGES_FILENAME = 'LastKnownImages.txt'

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
		picture_path = PICTURES_FOLDER + filename + IMAGES_EXTENSION
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
		open(PICTURES_FOLDER + pic_id + IMAGES_EXTENSION, "wb") { |file| file.write(Net::HTTP.get_response(URI.parse(photo_url)).body)}
   	end
end

def readConfig()
	buffer = File.open(CONFIG_FILE, 'r').read
	if buffer.length > 0
		myArray = JSON.parse(buffer)
	else
		myArray = []
	end
end

def getAlreadyDownloadedImages()
	Dir.entries(PICTURES_FOLDER).map { |picture_name| File.basename(picture_name, '.*')}
end

#Update the list with the id which are passed in the array
def saveLastKnownImages(last20)
	$stdout = File.open(LAST_KNOWN_IMAGES_FILENAME, 'w')
	puts last20.to_json
end

####################### SCRIPT ##################################################

config = readConfig()
if config.count < 4
	raise "Your configuration file is not correctly formatted"
end

FlickRaw.api_key=config[0]
FlickRaw.shared_secret=config[1]
flickr.access_token = config[2]
flickr.access_secret = config[3]

login = flickr.test.login
puts "You are now authenticated as #{login.username}"

#Retrive the ids of the last pictures downloaded
alreadyDownloadedImages = getAlreadyDownloadedImages()

#Retrieve the last pictures of the set
last20 = getLastPhotosOfSet(PHOTOSET_ID, PICTURES_COUNT)

#Find the old pictures to erase and the new ones to download
imagesToDelete = alreadyDownloadedImages - last20

	puts "Images to delete:"
	imagesToDelete.each do |image|
		puts image
		end

imagesToDownload = last20 - alreadyDownloadedImages

	puts "Images to download:"
	imagesToDownload.each do |image|
		puts image
		end

#Do it!
deleteImages(imagesToDelete)
downloadImages(imagesToDownload)