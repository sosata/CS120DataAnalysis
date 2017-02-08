
# coding: utf-8

# In[2]:

# This program will add an extra column to eml.csv containing the Foursquare
# highest-level category for the locations subjects have entered

import foursquare
import csv
from copy import deepcopy
import time
import os

data_root_dir = '/data/CS120/'
data_write_dir = '/data/CS120FourSquare/'

subjects = os.listdir(data_root_dir)
subjects = subjects[53:]
# subject 1367477 (52) should be skipped as it doesn't have lat/long values for location reports

client = foursquare.Foursquare(client_id='Z114Q224KB4ZFVHALYCFVTQIDEJZON30R3CY1UUABGI3SFA5', client_secret='4YZNN4DVQKW1IMY3SIZ1GBUGHKYRMNIGDDGHI3LJG0UGWAOU', version='20160108')

cat_map = client.venues.categories()

n_cat = 10 # no. fousquare categories

for (i,subject) in enumerate(subjects):
    #subject = subjects_row[0]
    print 'subject '+str(i)+' '+subject
    data_out = []
    filename = data_root_dir + subject + '/eml.csv'
    if os.path.exists(filename):
        with open(filename) as file_in:
            data = csv.reader(file_in, delimiter='\t')
            for data_row in data:
                if data_row:
                    #text = client.venues.search(params={'query':data_row[5], 'll':str(data_row[2])+','+str(data_row[3]), 'limit':'1'})
                    #print data_row
                    #t0 = time.time()
                    text = client.venues.search(params={'ll':str(data_row[2])+','+str(data_row[3]), 'limit':'1'})
                    #t1 = time.time()
                    time.sleep(1)
                    #t2 = time.time()
                    categ_high = 'Unknown'
                    distance = float('NaN')
                    if text['venues']:
                        if text['venues'][0]['location']:
                            distance = text['venues'][0]['location']['distance']
                        if text['venues'][0]['categories']:
                            categ_low = text['venues'][0]['categories'][0]['name']
                            #print categ_low
                            for j in range(n_cat):
                                has_it = False
                                for t in cat_map['categories'][j]['categories']:
                                    # if there are level 3 categories
                                    if t['categories']:
                                        for tt in t['categories']:
                                            if tt['name']==categ_low:
                                                has_it = True
                                                break
                                    else:
                                        if t['name']==categ_low:
                                            has_it = True
                                    if has_it:
                                        break
                                if has_it:
                                    categ_high = cat_map['categories'][j]['name']
                                    break
                            #print categ_high
                    else:
                        print 'warning: query response was empty'
                    #t3 = time.time()
                    #print t3-t2, t2-t1, t1-t0
                    data_out_row = data_row
                    data_out_row.append(categ_high)
                    data_out_row.append(distance)
                    data_out.append(deepcopy(data_out_row))
        file_in.close()
        if not os.path.exists(data_write_dir+subject):
            os.makedirs(data_write_dir+subject)
        with open(data_write_dir + subject + '/fsq2.csv', 'w') as file_out:
            spamwriter = csv.writer(file_out, delimiter='\t',quotechar='|',quoting=csv.QUOTE_MINIMAL)
            for data_out_row in data_out:
                spamwriter.writerow(data_out_row)
        file_out.close()
    else:
        print 'subject skipped due to no eml.csv'


# In[4]:

import os
data_root_dir = '/data/CS120/'
subjects = os.listdir(data_root_dir)
print subjects

