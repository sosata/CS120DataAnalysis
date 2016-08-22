
# coding: utf-8

# In[1]:

# this program uses short-term features from features_new/ and adds personal, long-term features to them

import os
import pickle
import numpy as np
import pandas as pd

ind_lat = 51
ind_long = 52
threshold_distance_squared = 0.001**2 # equivalent to about 100 meters

save_results = True

feature_dir = 'features/'
feature_out = 'features_long/'

files = os.listdir(feature_dir)

for filename in files:
    print filename
    with open(feature_dir+filename) as f:  
        feature, target = pickle.load(f)
        rf = pd.DataFrame(columns=['LT frequency'])
        ai = pd.DataFrame(columns=['LT interval mean'])
        for i in range(feature.shape[0]):
            dist_squared = (feature.loc[:,'lat mean'] - feature.loc[i,'lat mean'])**2 +             (feature.loc[:,'lng mean'] - feature.loc[i,'lng mean'])**2
            ind_same = dist_squared<threshold_distance_squared
            # relative frequency
            rf.loc[i] = np.sum(ind_same)/float(feature.shape[0])
            # average interval between visits
            ai.loc[i] = np.mean(np.diff(np.where(ind_same)[0]))
        
        feature = pd.concat([feature, rf, ai], axis=1)
        
    f.close()
    
    if save_results:
        with open(feature_out+filename, 'w') as f:
            pickle.dump([feature, target], f)
        f.close()


# In[12]:

target

