
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
        


# In[ ]:

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

# fsq_map = {'Nightlife Spot':'Nightlife Spot (Bar, Club)', 'Outdoors & Recreation':'Outdoors & Recreation',\
#           'Arts & Entertainment':'Arts & Entertainment (Theater, Music Venue, Etc.)',\
#           'Professional & Other Places':'Professional or Medical Office',\
#           'Food':'Food (Restaurant, Cafe)', 'Residence':'Home', 'Shop & Service':'Shop or Store'}

ft_dir = 'features_new/'

# building one hot encoder for foursquare locations (as extra features)
# state7 = np.array(fsq_map.values()+['Unknown'])
# le = preprocessing.LabelEncoder()
# le.fit(state7)
# state7_code = le.transform(state7)
# enc = OneHotEncoder()
# enc.fit(state7_code.reshape(-1, 1))

# list feature files
files = os.listdir(ft_dir)
#files = [files[0]]

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

#         for (i,s) in enumerate(state):
#             state[i] = state[i].replace('"','')
#             state[i] = state[i].replace('[','')
#             state[i] = state[i].replace(']','')
            
        # only keeping top 10 states
        ind = np.array([], int)
        for (i,st) in enumerate(state):
            if st in state_top10:
                ind = np.append(ind, i)
        feature = feature[ind,:]
        state = state[ind]
        state_fsq = state_fsq[ind]
        
        # converting foursquare names to standard names
#         state_fsq = list(state_fsq)
#         for (i,s) in enumerate(state_fsq):
#             if s in fsq_map:
#                 state_fsq[i] = fsq_map[s]
#             else:
#                 state_fsq[i] = 'Unknown'
#         state_fsq = np.array(state_fsq)
        
        # This is a temporary solution, to turn sky conditions into numbers
        # The original feature extraction file needs to change to solve this problem
        # (XGBoost does not accept string input)
#         feature_new = np.array([[]])
        for (i,ft_row) in enumerate(feature):
            if isinstance(feature[i,56], basestring):
                feature[i,56] = sum(ord(c) for c in feature[i,56])
            # adding foursquare locations as additional features
            # also converting it to float first
            #sum_fsq = sum(ord(c) for c in state_fsq[i])
#             state_fsq_code = le.transform(state_fsq[i])
#             state_fsq_bin = enc.transform(state_fsq_code.reshape(-1,1)).toarray()            
#             if feature_new.size>0:
#                 feature_new = np.append(feature_new, [np.append(feature[i,:], state_fsq_bin[0])], axis=0)
#             else:
#                 feature_new = np.array([np.append(feature[i,:], state_fsq_bin[0])])
#         feature  = feature_new
        
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
    
    t0 = time.time()
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
    t1 = time.time()
    
    if do_stratify:
        x_train, y_train = stratify(x_train,y_train)
    
    # test set
    x_test = feature_all[i]
    y_test = state_all[i]
    t2 = time.time()
    
    # train and test
    gbm = xgboost.XGBClassifier(max_depth=3, n_estimators=300, learning_rate=0.05, nthread=12, subsample=1,                               max_delta_step=0).fit(x_train, y_train)
    predictions = gbm.predict(x_test)
    t3 = time.time()

    # confusion matrix, AUC
    conf, roc_auc = calculate_confusion_matrix(predictions, y_test)
    t4 = time.time()
    
    # confusion matrix, AUC for foursquare
    conf_fsq, roc_auc_fsq = calculate_confusion_matrix(state_fsq_all[i], y_test)
    
    #print t1-t0, t2-t1, t3-t2, t4-t3
    print np.unique(y_test)
    #print conf
    print 'model:'
    print roc_auc
    print 'foursquare:'
    print roc_auc_fsq
    #labels.append(np.unique(np.append(y_test, predictions)))
    labels.append(np.unique(y_test))
    confs.append(conf)
    aucs.append(roc_auc)
    confs_fsq.append(conf_fsq)
    aucs_fsq.append(roc_auc_fsq)
    
# saving the results
if save_results:
    with open('accuracy_new300_3_depth6_fsq2_distance2.dat','w') as f:
        pickle.dump([aucs, confs, labels, aucs_fsq, confs_fsq], f)
    f.close()

os._exit(0)


# In[4]:

import os
files = os.listdir('features_new/')
print files[31]


# In[ ]:

state7 = np.array(fsq_map.values()+['Unknown'])
print state7
le = preprocessing.LabelEncoder()
le.fit(state7)
enc = OneHotEncoder()
enc.fit(state7_code.reshape(-1, 1))

state_code = le.transform(np.array(['Unknown']))
state_bin =  enc.transform(state_code.reshape(-1,1)).toarray()
print state_bin[0]

