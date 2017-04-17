
# coding: utf-8

# In[7]:

import os
import pickle
import pandas as pd
import numpy as np
import xgboost as xgb
from calculate_confusion_matrix import calculate_confusion_matrix
import time
from copy import deepcopy
from utils import one_hot_encoder
# from sklearn.preprocessing import OneHotEncoder
# from sklearn import preprocessing

save_results = True
do_stratify = False

n_boot = 100
split = 0.7
np.random.seed(seed=0)

ft_dir = 'features_long/'

# list feature files
files = os.listdir(ft_dir)

# reading top locations
with open('top_locations.dat') as f:
    location_top = pickle.load(f)
f.close()

target_all = []
for filename in files:
    with open(ft_dir+filename) as f:  
        _, target = pickle.load(f)

        # only keeping top locations
        ind = np.array([], int)
        for (i,loc) in enumerate(target['location']):
            if loc in location_top:
                ind = np.append(ind, i)
        target = target.loc[ind]
        target = target.reset_index(drop=True)
        
        target_all.append(target)
        
    f.close()

confs = []
aucs = []
labels = []
inds = np.arange(0,len(target_all),1)

for i in range(n_boot):
    
    print '------------------'
    print i
    
#     ind_boot = np.random.choice(inds, size=inds.size, replace=True)
    ind_boot = np.random.choice(inds, size=np.floor(inds.size*split), replace=False)
    
    y_report = pd.concat([target_all[j]['location'] for j in ind_boot], axis=0)
    y_fsq = pd.concat([target_all[j]['fsq'] for j in ind_boot], axis=0)
    
    # foursquare performance
    conf, roc_auc = calculate_confusion_matrix(y_fsq, y_report)
    
    labels.append(np.unique(y_report))
    confs.append(conf)
    aucs.append(roc_auc)

    print np.unique(y_report)
    print roc_auc, np.nanmean(roc_auc)
   
# saving the results
if save_results:
    with open('auc_location_new_10fold_fsq2.dat','w') as f:
        pickle.dump([aucs, confs, labels], f)
    f.close()


# In[1]:

import numpy as np

