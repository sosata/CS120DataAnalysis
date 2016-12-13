
# coding: utf-8

# In[1]:

# This code adds extract the foursquare entries from the source data (/Data/CS120FourSquare) and puts them in separate files
# in ./data for later feature extraction

import pandas as pd
import os
import numpy as np

data_dir = 'data/'
fsq_data_dir = '/home/sohrob/Dropbox/Data/CS120FourSquare/'

subjects = os.listdir(data_dir)

for (i,subject) in enumerate(subjects):

    print str(i)+' '+subject
    
    # load foursquare data
    filename = fsq_data_dir+subject+'/fsq2.csv'
    data_fsq = pd.read_csv(filename, delimiter='\t', header=None)
    
    #print data_fsq[:][2]
        
    subdirs = os.listdir(data_dir+subject)
    
    for (j,subdir) in enumerate(subdirs):
        
        # load eml data
        filename = data_dir+subject+'/'+subdir+'/eml.csv'
        data = pd.read_csv(filename, delimiter='\t', header=None)
        
        # searching though foursquare data
        ind = np.where(np.logical_and(np.logical_and(data_fsq[0][:]==data[0][0], data_fsq[2][:]==data[2][0]),                                   data_fsq[3][:]==data[3][0]))[0]
        
        if len(ind)>0:
            ind = ind[0]
            data_to_write = data_fsq.loc[ind,:]
            filename = data_dir+subject+'/'+subdir+'/fsq2.csv'
            data_to_write.to_csv(filename, sep='\t', header=None)
        else:
            print 'subject '+subject+' subdir '+str(subdir)+' not found in foursquare data'
        
        


# In[97]:

print ind

