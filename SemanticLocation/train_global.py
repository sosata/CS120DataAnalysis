
# coding: utf-8

# In[2]:

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
        


# In[29]:

import os
import pickle
import numpy as np
import xgboost
from calculate_confusion_matrix import calculate_confusion_matrix
import time

do_stratify = False

fsq_map = {'Nightlife Spot':'Nightlife Spot (Bar, Club)', 'Outdoors & Recreation':'Outdoors & Recreation',          'Arts & Entertainment':'Arts & Entertainment (Theater, Music Venue, Etc.)',          'Professional & Other Places':'Professional or Medical Office',          'Food':'Food (Restaurant, Cafe)', 'Residence':'Home', 'Shop & Service':'Shop or Store'}

ft_dir = 'features_new/'

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
for filename in files:
    with open(ft_dir+filename) as f:  
        feature, state, feature_label = pickle.load(f)

        for (i,s) in enumerate(state):
            state[i] = state[i].replace('"','')
            state[i] = state[i].replace('[','')
            state[i] = state[i].replace(']','')
        
        # only keeping top 10 states
        ind = np.array([], int)
        for (i,st) in enumerate(state):
            if st in state_top10:
                ind = np.append(ind, i)
        feature = feature[ind,:]
        state = state[ind]
        
        # This is a temporary solution, to turn sky conditions into numbers
        # The original feature extraction file needs to change to solve this problem
        # (XGBoost does not accept string input)
        for (i,ft_row) in enumerate(feature):
            if isinstance(feature[i,56], basestring):
                feature[i,56] = sum(ord(c) for c in feature[i,56])
        feature_all.append(feature)
        state_all.append(state)
    f.close()

    
confs = []
aucs = []
labels = []

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
    gbm = xgboost.XGBClassifier(max_depth=6, n_estimators=100, learning_rate=0.05, nthread=12, subsample=1,                               max_delta_step=0).fit(x_train, y_train)
    predictions = gbm.predict(x_test)
    t3 = time.time()

    # confusion matrix, AUC
    conf, roc_auc = calculate_confusion_matrix(predictions, y_test)
    t4 = time.time()
    
    print t1-t0, t2-t1, t3-t2, t4-t3
    print np.unique(np.append(y_test, predictions))
    #print conf
    print roc_auc
    labels.append(np.unique(np.append(y_test, predictions)))
    confs.append(conf)
    aucs.append(roc_auc)
    
# saving the results
with open('accuracy_new100_3_depth6.dat','w') as f:
    pickle.dump([aucs, confs, labels], f)
f.close()


# In[32]:

print state_top10

