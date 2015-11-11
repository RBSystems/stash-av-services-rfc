#Python 2.7.6
#RestfulClient.py

import requests
from requests.auth import HTTPDigestAuth
import json

host='192.168.99.100'
port='32773'

url = 'http://{0}:{1}/devices/touchpanel/_search'.format(host,port)
print url
# It is a good practice not to hardcode the credentials. So ask the user to enter credentials at runtime
resp = requests.get(url)
#print (myResponse.status_code)

# For successful API call, response code will be 200 (OK)
if(resp.ok):

    # Loading the response data into a dict variable
    # json.loads takes in only binary or string variables so using content to fetch binary content
    # Loads (Load String) takes a Json file and converts into python data structure (dict or list, depending on JSON)
    jData = json.loads(resp.content)
    numPanels = jData['hits']['total']
    if(numPanels > 0):
    	print numPanels
    else:
    	print "Zilcho"
    #print jData['hits']['hits'][0]['_source']['IP']
else:
  # If response code is not ok (200), print the resulting http error code with description
    resp.raise_for_status()