import oauth2 as oauth
import urlparse
import time
import httplib2

url = 'http://www.flickr.com/services'
request_token_url = '%s/oauth/request_token' % url
authorize_url = '%s/oauth/authorize/' % url
access_token_url = '%s/oauth/access_token/' % url
consumer_key = '89a9b710d93bb47c4d515f66bd11e2b8'
secret_key = 'c181975cafc6a102'

# Token.secret is given to you after a three-legged authentication.
token = oauth.Token(key=consumer_key, secret=secret_key)

# Setup the Consumer with the api_keys given by the provider
consumer = oauth.Consumer(key=consumer_key, secret=secret_key)

params = {
    'oauth_timestamp': int(time.time()),
    'oauth_signature_method':"HMAC-SHA1",
    'oauth_version': "1.0",
    'oauth_nonce': oauth.generate_nonce(),
    'oauth_token': token.key,
    'oauth_consumer_key': consumer.key,
    'oauth_callback': 'http://www.timothep.net'
}

# Create our request. Change method, etc. accordingly.
req = oauth.Request(method="GET", url=url, parameters=params)

# Demandes de signature
signature = oauth.SignatureMethod_HMAC_SHA1().sign(req, consumer, token)
req['oauth_signature'] = signature
params['oauth_signature'] = signature

print params

# Obtention d'un jeton de requete
h = httplib2.Http()
resp, content = h.request(req.to_url(), "GET")

print resp

if resp['status'] != '200':
    raise Exception("Invalid response %s." % resp['status'])
else:
    print 'Status 200 received, continuing'



resp, content = h.request(req.to_url(), "GET")


#parse the content
request_token = dict(urlparse.parse_qsl(content))

#print "Request Token:"
#print "    - oauth_token        = %s" % request_token['oauth_token']
#print "    - oauth_token_secret = %s" % request_token['oauth_token_secret']
#print