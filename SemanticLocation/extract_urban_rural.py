
# coding: utf-8

# In[109]:

import csv
import os
import urllib2
import json
import pandas as pd

data_dir = '/data/CS120/'

subjects = os.listdir(data_dir)

# subjects = subjects[0:3]

tab = pd.DataFrame(columns=['subject','county','state','status'])

i = 0
for subj in subjects:
    # reading GPS data
    filename = data_dir + subj + '/fus.csv'
    if os.path.exists(filename):
        with open(filename) as file_in:
            reader = csv.reader(file_in, delimiter='\t')
            data = next(reader)
            lat = data[1]
            lng = data[2]
            query = 'http://data.fcc.gov/api/block/find?format=json&latitude={}&longitude={}&showall=true'.format(lat,lng)
            print query
            res = urllib2.urlopen(query)
            j = json.loads(res.read())
            
            tab.loc[i,'subject'] = subj
            tab.loc[i,'county'] = j['County']['name']
            tab.loc[i,'state'] = j['State']['name']
            i+=1


# In[110]:

tab


# In[111]:

import openpyxl as ol
wb = ol.load_workbook('County_Rural_Lookup.xlsx', data_only=True)
sh = wb['United States']
# print sh['A16'].fill.start_color.index
# a = sh['C27'].value


# In[119]:

import numpy as np

urban_rural = pd.DataFrame(columns=['county', 'state', 'status'])

for i in np.arange(5,3147):
    cntst = sh['C{}'.format(i)].value
    urban_rural.loc[i-5,'county'] = cntst.split(',')[0]
    urban_rural.loc[i-5,'state'] = cntst.split(',')[1][1:]
    cl = sh['A{}'.format(i)].fill.start_color.index
    if cl==6:
        urban_rural.loc[i-5,'status'] = 'mostly rural'
    elif cl==4:
        urban_rural.loc[i-5,'status'] = 'mostly urban'
    elif cl==9:
        urban_rural.loc[i-5,'status'] = 'completely rural'
    else:
        print 'Warning: color code unknown'


# In[120]:

urban_rural


# In[139]:

for i in range(tab.shape[0]):
    print i
    num = 0
    for j in range(urban_rural.shape[0]):
        if type(tab.loc[i,'county']) is unicode:
            if (tab.loc[i,'county']+' ' in urban_rural.loc[j,'county']) and tab.loc[i,'state']==urban_rural.loc[j,'state']:
                tab.loc[i,'status'] = urban_rural.loc[j,'status']
                num += 1
    if num>1:
        print 'Warning: more than one match found for '+tab.loc[i,'county']
    if num<1:
        print 'Warning: no match found for '+str(tab.loc[i,'county'])


# In[146]:

print np.sum(tab['status']=='mostly urban'), np.sum(tab['status']=='mostly urban')/206.0
print np.sum(tab['status']=='mostly rural'), np.sum(tab['status']=='mostly rural')/206.0
print np.sum(tab['status']=='completely urban'), np.sum(tab['status']=='completely urban')/206.0

