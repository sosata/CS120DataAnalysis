
# coding: utf-8

# In[137]:

# this program uses short-term features from features_new/ and adds personal, long-term features to them

import os
import pickle
import numpy as np

ind_lat = 51
ind_long = 52
th_dist_squared = 0.001**2 # equivalent to about 100 meters

save_results = True

feature_dir = 'features_new/'
feature_out = 'features_long/'

files = os.listdir(feature_dir)
#files = [files[1]]

for filename in files:
    print filename
    with open(feature_dir+filename) as f:  
        feature, state, state_fsq, feature_label = pickle.load(f)
        rf = np.zeros([state.size,1])
        ai = np.zeros([state.size,1])
        for i in range(state.size):
            dist_squared = (feature[:,ind_lat] - feature[i,ind_lat])**2 + (feature[:,ind_long] - feature[i,ind_long])**2
            ind_same = dist_squared<th_dist_squared
            # relative frequency
            rf[i] = np.sum(ind_same)/float(state.size)
            # average interval between visits
            ai[i] = np.mean(np.diff(np.where(ind_same)[0]))
        
        feature = np.append(feature, rf, axis=1)
        feature = np.append(feature, ai, axis=1)
        
    f.close()
    
    if save_results:
        feature_label = np.append(feature_label, ['LT frequency','LT interval mean'])
        with open(feature_out+filename, 'w') as f:
            pickle.dump([feature, state, state_fsq, feature_label], f)
        f.close()

    


# In[141]:

print rf

