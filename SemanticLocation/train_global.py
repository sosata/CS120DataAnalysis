
# coding: utf-8

# In[ ]:

def stratify(x, y):
    
    import collections as col
    counts = col.Counter(y)
    n_max = np.max(counts.values())
    
    y_uniq = np.unique(y)
    y_out_class = [[] for i in range(y_uniq.size)]
    x_out_class = [[] for i in range(y_uniq.size)]
    for (i,y_u) in enumerate(y_uniq):
        inds = y==y_u
        y_class = y[inds]
        x_class = x[inds,:]
        inds = np.random.choice(np.arange(0,y_class.size), n_max, replace=True)
        y_out_class[i] = y_class[inds]
        x_out_class[i] = x_class[inds]
        
    y = np.concatenate(y_out_class)
    x = np.concatenate(x_out_class, axis=0)
    
    return x,y
        


# In[1]:

import os
import pickle
import numpy as np
import xgboost
from calculate_confusion_matrix import calculate_confusion_matrix
import time
from copy import deepcopy
# from sklearn.preprocessing import OneHotEncoder
# from sklearn import preprocessing


save_results = True
do_stratify = False

ft_dir = 'features_long/'

# list feature files
files = os.listdir(ft_dir)

with open('top10.dat') as f:
    state_top10 = pickle.load(f)
f.close()
for (i,s) in enumerate(state_top10):
    state_top10[i] = state_top10[i].replace('"','')
    state_top10[i] = state_top10[i].replace('[','')
    state_top10[i] = state_top10[i].replace(']','')

feature_all = []
state_all = []
state_fsq_all = []
for filename in files:
    with open(ft_dir+filename) as f:  
        feature, state, state_fsq, feature_label = pickle.load(f)

        # only keeping top 10 states
        ind = np.array([], int)
        for (i,st) in enumerate(state):
            if st in state_top10:
                ind = np.append(ind, i)
        feature = feature[ind,:]
        state = state[ind]
        state_fsq = state_fsq[ind]
        
        feature_all.append(feature)
        state_all.append(state)
        state_fsq_all.append(state_fsq)
        
    f.close()

confs = []
aucs = []
labels = []
confs_fsq = []
aucs_fsq = []

for i in range(len(feature_all)):
    
    #t0 = time.time()
    print '------------------'
    print i
    if i==6:
        print 'subject skipped because of lack of data'
        continue
    
    # training set
    j_range = range(len(feature_all))
    j_range.pop(i)
    x_train = np.concatenate([feature_all[j] for j in j_range], axis=0)
    y_train = np.concatenate([state_all[j] for j in j_range])
    #t1 = time.time()
    
    if do_stratify:
        x_train, y_train = stratify(x_train,y_train)
    
    # test set
    x_test = feature_all[i]
    y_test = state_all[i]
    #t2 = time.time()
    
    # training (layer 1)
    gbm = xgboost.XGBClassifier(max_depth=3, n_estimators=600, learning_rate=0.05, nthread=12, subsample=1,                               max_delta_step=0).fit(x_train, y_train)
    
    # training (later 2)
#     x_train_post = gbm.predict_proba(x_train)
#     gbm2 = xgboost.XGBClassifier(max_depth=3, n_estimators=30, learning_rate=0.05, nthread=12, subsample=1,\
#                                max_delta_step=0).fit(x_train_post, y_train)
    
    # test
    y_pred = gbm.predict(x_test) # first layer
    
#     x_test_post = gbm.predict_proba(x_test)
#     y_pred = gbm2.predict(x_test_post) # 2 layer prediction
    
    #t3 = time.time()
    
    # confusion matrix, AUC
    conf, roc_auc = calculate_confusion_matrix(y_pred, y_test)
    #t4 = time.time()
    
    # confusion matrix, AUC for foursquare
    conf_fsq, roc_auc_fsq = calculate_confusion_matrix(state_fsq_all[i], y_test)
    
    #print t1-t0, t2-t1, t3-t2, t4-t3
    print np.unique(y_test)
    #print conf
    print 'model:'
    print roc_auc
    print 'foursquare:'
    print roc_auc_fsq
    labels.append(np.unique(y_test))
    confs.append(conf)
    aucs.append(roc_auc)
    confs_fsq.append(conf_fsq)
    aucs_fsq.append(roc_auc_fsq)
    
# saving the results
if save_results:
    with open('accuracy_new600_3_depth6_fsq2_distance2_longterm.dat','w') as f:
        pickle.dump([aucs, confs, labels, aucs_fsq, confs_fsq], f)
    f.close()



# In[ ]:

# print predictions

