This script is used to regularly download the latest images of a private FlickrSet. The script keeps only the last X images on the disk and removes the previously downloaded ones (it is intended to create a slideshow of the new images only and not to grow incomensurably as time passes).

Setup:
* Go to [Flickr](http://www.flickr.com/services/apps/create/apply/?) and create keys for your API
* Create a 'config' file (no extension) and create an array that looks like the following with the keys you just got in it '["api_key", "secret_key"]'
* Run the 'Authenticate.rb' script and copy the link that is given to you as a result
* Paste the link in a browser and copy back the authentication token that Flickr will give you into the command window
* Verify that the 'config' file now has 4 values. You're good to go!

Change the constants as you see fit: 
* PHOTOSET_ID = the id of the set you wish to observe
* PRIVACY_FILTER = <1 to 5> depending of the degree of privacy (see [Flickraw API doc](http://hanklords.github.io/flickraw/FlickRaw/Flickr/Photosets.html#method-i-getPhotos) for explanation)

You can now run the 'SmartFlickrSniffer.rb' script.
