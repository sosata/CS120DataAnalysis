
# coding: utf-8

# In[7]:

# some subjects don't have the lat/long coordinates in the eml.csv files for some instances

import csv
import os
import numpy as np
import matplotlib.pyplot as plt
from sklearn import preprocessing

get_ipython().magic(u'matplotlib inline')

data_dir = '/home/sohrob/Dropbox/Data/CS120/'

subjects = os.listdir(data_dir)

loc_subject = []
loc_all = np.array([])
n = np.zeros(len(subjects))
n_empty = np.zeros(len(subjects))
i = 0
for subj in subjects:
    filename = data_dir + subj + '/eml.csv'
    if os.path.exists(filename):
        #print filename
        with open(filename) as file_in:
            data = csv.reader(file_in, delimiter='\t')
            for data_row in data:
                if data_row:
                    if data_row[2]=='':
                        n_empty[i] +=1
                    n[i] +=1
    i +=1


# In[11]:

print n
print np.where(n_empty>0)

