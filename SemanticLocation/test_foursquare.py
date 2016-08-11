
# coding: utf-8

# In[12]:

import foursquare
import json

client = foursquare.Foursquare(client_id='Z114Q224KB4ZFVHALYCFVTQIDEJZON30R3CY1UUABGI3SFA5', client_secret='4YZNN4DVQKW1IMY3SIZ1GBUGHKYRMNIGDDGHI3LJG0UGWAOU', version='20160108')
text = client.venues.search(params={'ll':'42.2086045, -98.7505142', 'limit':'1'})
print text
print text['venues'][0]['location']['distance']
print text['venues'][0]['categories'][0]['name']

