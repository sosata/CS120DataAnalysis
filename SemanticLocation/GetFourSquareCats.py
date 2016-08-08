
# coding: utf-8

# In[11]:

# This program will add an extra column to eml.csv containing the Foursquare
# highest-level category for the locations subjects have entered

import foursquare
import csv
from copy import deepcopy
import time
import os

data_root_dir = '/home/sohrob/Dropbox/Data/CS120/'
data_write_dir = '/home/sohrob/Dropbox/Data/CS120FourSquare/'

subjects = os.listdir(data_root_dir)
subjects = subjects[169:]

client = foursquare.Foursquare(client_id='Z114Q224KB4ZFVHALYCFVTQIDEJZON30R3CY1UUABGI3SFA5', client_secret='4YZNN4DVQKW1IMY3SIZ1GBUGHKYRMNIGDDGHI3LJG0UGWAOU', version='20160108')

cat_map = client.venues.categories()

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
                    text = client.venues.search(params={'ll':str(data_row[2])+','+str(data_row[3]), 'limit':'1'})
                    time.sleep(1)
                    categ_high = 'Unknown'
                    if text['venues']:
                        if text['venues'][0]['categories']:
                            categ_low = text['venues'][0]['categories'][0]['name']
                            #print categ_low
                            for j in range(10):
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
                    data_out_row = data_row
                    data_out_row.append(categ_high)
                    data_out.append(deepcopy(data_out_row))
        file_in.close()
        if not os.path.exists(data_write_dir+subject):
            os.makedirs(data_write_dir+subject)
        with open(data_write_dir + subject + '/fsq.csv', 'w') as file_out:
            spamwriter = csv.writer(file_out, delimiter='\t',quotechar='|',quoting=csv.QUOTE_MINIMAL)
            for data_out_row in data_out:
                spamwriter.writerow(data_out_row)
        file_out.close()
    else:
        print 'subject skipped due to no eml.csv'


# In[9]:

#print [text['categories'][i]['name'] for i in range(10) if 
# print [1 for t in cat_map['categories'][4]['categories'] if t['name'] == 'Conference Room']
# print [cat_map['categories'][i]['name'] for i in range(10)]
# cat_map['categories'][6]['categories'][22]['categories']
print text['venues']
print data_row

