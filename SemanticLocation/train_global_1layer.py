
# coding: utf-8

# In[4]:

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

ft_dir = 'features_long/'

# list feature files
files = os.listdir(ft_dir)

# reading top locations
with open('top_locations.dat') as f:
    location_top = pickle.load(f)
f.close()

# reading top reasons
with open('top_reasons.dat') as f:
    reason_top = pickle.load(f)
f.close()
    
feature_all = []
target_all = []
for filename in files:
    with open(ft_dir+filename) as f:  
        feature, target = pickle.load(f)

        # only keeping top locations
        ind = np.array([], int)
        for (i,loc) in enumerate(target['location']):
            if loc in location_top:
                ind = np.append(ind, i)
        feature = feature.loc[ind,:]
        target = target.loc[ind]
        feature = feature.reset_index(drop=True)
        target = target.reset_index(drop=True)
        
        # only keeping top reasons
        ind = np.array([], int)
        for (i,r) in enumerate(target['reason']):
            if r in reason_top:
                ind = np.append(ind, i)
        feature = feature.loc[ind,:]
        target = target.loc[ind]
        feature = feature.reset_index(drop=True)
        target = target.reset_index(drop=True)

        feature_all.append(feature)
        target_all.append(target)
        
    f.close()

confs = []
aucs = []
labels = []
confs_fsq = []
aucs_fsq = []

for i in range(len(feature_all)):
    
    print '------------------'
    print i
    if i==6:
        print 'subject skipped because of lack of data'
        continue
    
    # training set
    j_range = range(len(feature_all))
    j_range.pop(i)
    
    x_train = pd.concat([feature_all[j] for j in j_range], axis=0)
    y_train = pd.concat([target_all[j]['location'] for j in j_range], axis=0)
#     y_train = pd.concat([target_all[j]['reason'] for j in j_range], axis=0)
    
    x_train = x_train.reset_index(drop=True)
    y_train = y_train.reset_index(drop=True)
    
#     if do_stratify:
#         x_train, y_train = stratify(x_train,y_train)
    
    # test set
    x_test = feature_all[i]
    y_test = target_all[i]['location']
#     y_test = target_all[i]['reason']
    
    # remove foursquare data
#     x_train = x_train.drop(['fsq 0','fsq 1','fsq 2','fsq 3','fsq 4','fsq 5','fsq 6','fsq 7'],axis=1)
#     x_test = x_test.drop(['fsq 0','fsq 1','fsq 2','fsq 3','fsq 4','fsq 5','fsq 6','fsq 7'],axis=1)
    
    # train (layer 1)
    #eta_list = np.array([0.05]*200+[0.02]*200+[0.01]*200)
    gbm = xgb.XGBClassifier(max_depth=3, n_estimators=100, learning_rate=0.01, nthread=12, subsample=1,                               max_delta_step=0).fit(x_train, y_train)
    
    # train performance
#     y_pred = gbm.predict(x_train)
#     conf_train, roc_auc_train = calculate_confusion_matrix(y_pred, y_train)

    # test (layer 1)
    y_pred = gbm.predict(x_test)
    
    # test performance
    conf, roc_auc = calculate_confusion_matrix(y_pred, y_test)
    
    # foursquare performance
    #conf_fsq, roc_auc_fsq = calculate_confusion_matrix(state_fsq_all[i], y_test)
    
    labels.append(np.unique(y_test))
    confs.append(conf)
    aucs.append(roc_auc)
    #confs_fsq.append(conf_fsq)
    #aucs_fsq.append(roc_auc_fsq)

#     print 'train'
#     print np.unique(y_train)
#     #print conf
#     print np.nanmean(roc_auc_train)

#     print 'test'

    print np.unique(y_test)
    #print conf
    print roc_auc
    #print 'foursquare:'
    #print roc_auc_fsq
    
# saving the results
if save_results:
    with open('auc_location_sensor_fsq.dat','w') as f:
        #pickle.dump([aucs, confs, labels, aucs_fsq, confs_fsq], f)
        pickle.dump([aucs, confs, labels], f)
    f.close()



# In[3]:

location_top

