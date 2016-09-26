
# coding: utf-8

# In[74]:

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
split = 0.9
np.random.seed(seed=0)

ft_dir = 'features_long/'

# list feature files
files = os.listdir(ft_dir)

# reading top locations
with open('top_locations.dat') as f:
    location_top = pickle.load(f)
f.close()

# reading top reasons
# with open('top_reasons.dat') as f:
#     reason_top = pickle.load(f)
# f.close()
    
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
#         ind = np.array([], int)
#         for (i,r) in enumerate(target['reason']):
#             if r in reason_top:
#                 ind = np.append(ind, i)
#         feature = feature.loc[ind,:]
#         target = target.loc[ind]
#         feature = feature.reset_index(drop=True)
#         target = target.reset_index(drop=True)

        feature_all.append(feature)
        target_all.append(target)
        
    f.close()

confs = []
aucs = []
labels = []
inds = np.arange(0,len(feature_all),1)
inds_split = np.floor(split*len(feature_all))

for i in range(n_boot):#range(len(feature_all)):
    
    print '------------------'
    print i
#     if i==6:
#         print 'subject skipped because of lack of data'
#         continue
    
    # training set
#     ind_train = range(len(feature_all))
#     ind_train.pop(i)
    np.random.shuffle(inds)
    ind_train = inds[:inds_split]
    ind_test = inds[inds_split:]
    
    x_train = pd.concat([feature_all[j] for j in ind_train], axis=0)
    y_train = pd.concat([target_all[j]['location'] for j in ind_train], axis=0)
    x_train = x_train.reset_index(drop=True)
    y_train = y_train.reset_index(drop=True)
    
    # test set
#     x_test = feature_all[i]
#     y_test = target_all[i]['location']
    x_test = pd.concat([feature_all[j] for j in ind_test], axis=0)
    y_test = pd.concat([target_all[j]['location'] for j in ind_test], axis=0)
    x_test = x_test.reset_index(drop=True)
    y_test = y_test.reset_index(drop=True)
    
    # remove foursquare data
    x_train = x_train.drop(['fsq 0','fsq 1','fsq 2','fsq 3','fsq 4','fsq 5','fsq 6','fsq 7','fsq 8','fsq distance'],axis=1)
    x_test = x_test.drop(['fsq 0','fsq 1','fsq 2','fsq 3','fsq 4','fsq 5','fsq 6','fsq 7','fsq 8','fsq distance'],axis=1)
    x_train = x_train.reset_index(drop=True)
    x_test = x_test.reset_index(drop=True)
    
    # train (layer 1)
    #eta_array = np.array([0.05]*200+[0.02]*200+[0.01]*200)
    gbm = xgb.XGBClassifier(max_depth=3, n_estimators=300, learning_rate=0.05, nthread=12, subsample=0.1,                             colsample_bytree=0.5, max_delta_step=0, gamma=2, objective='multi:softmax', reg_alpha=0.9,                            missing=np.nan)
#     gbm.fit(x_train, y_train, eval_set=[(x_train,y_train),(x_test, y_test)], eval_metric='mlogloss', verbose=True)
#     print gbm.evals_result()
    gbm.fit(x_train, y_train)
    
    # training performance
    y_pred = gbm.predict(x_train)
    conf_train, roc_auc_train = calculate_confusion_matrix(y_pred, y_train)

    # test
    y_pred = gbm.predict(x_test)
    conf, roc_auc = calculate_confusion_matrix(y_pred, y_test)
    
    # foursquare performance
    #conf_fsq, roc_auc_fsq = calculate_confusion_matrix(state_fsq_all[i], y_test)
    
    labels.append(np.unique(y_test))
    confs.append(conf)
    aucs.append(roc_auc)

    print np.unique(y_test)
    print roc_auc_train, np.nanmean(roc_auc_train)
    print roc_auc, np.nanmean(roc_auc)
   
# saving the results
if save_results:
    with open('auc_location_new_10fold_sensor.dat','w') as f:
        pickle.dump([aucs, confs, labels], f)
    f.close()


# In[73]:

x_train.columns

