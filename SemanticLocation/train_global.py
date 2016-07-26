
# coding: utf-8

# In[23]:

import os
import pickle
import numpy as np
import xgboost
from calculate_confusion_matrix import calculate_confusion_matrix

ft_dir = 'features/'

files = os.listdir(ft_dir)

feature_all = []
state_all = []
for filename in files:
    with open(ft_dir+filename) as f:  
        feature, state = pickle.load(f)
        feature_all.append(feature)
        state_all.append(state)
    f.close()

with open('top10.dat') as f:
    state_top10 = pickle.load(f)
f.close()
for (i,s) in enumerate(state_top10):
    state_top10[i] = s.replace('"','')
    state_top10[i] = s.replace('[','')
    state_top10[i] = s.replace(']','')
    
print state_top10

confs = []
aucs = []
labels = []

for i in range(len(feature_all)):
    
    print '------------------'
    print i
    if i==6:
        print 'subject skipped because of lack of data'
        continue
    
    #creating train and test sets
    x_train = np.array([])
    y_train = np.array([])
    for j in range(len(feature_all)):
        if j!=i:
            for k in range(len(state_all[j])):
                if state_all[j][k] in state_top10:
                    if x_train.size==0:
                        x_train = np.array([feature_all[j][k,:]])
                        y_train = np.array(state_all[j][k])
                    else:
                        x_train = np.append(x_train, [feature_all[j][k,:]], axis=0)
                        y_train = np.append(y_train, state_all[j][k])
    
    x_test = np.array([])
    y_test = np.array([])
    for j in range(len(state_all[i])):
        if state_all[i][j] in state_top10:
            if x_test.size==0:
                x_test = np.array([feature_all[i][j,:]])
                y_test = np.array(state_all[i][j])
            else:
                x_test = np.append(x_test, [feature_all[i][j,:]], axis=0)
                y_test = np.append(y_test, state_all[i][j])

    #train
    gbm = xgboost.XGBClassifier(max_depth=3, n_estimators=300, learning_rate=0.05).fit(x_train, y_train)

    #test
    predictions = gbm.predict(x_test)

    conf, roc_auc = calculate_confusion_matrix(predictions, y_test)
    print np.unique(np.append(y_test, predictions))
    print conf
    print roc_auc
    labels.append(np.unique(np.append(y_test, predictions)))
    confs.append(conf)
    aucs.append(roc_auc)


# In[25]:

# save the results
with open('accuracy.dat','w') as f:
    pickle.dump([aucs, confs, labels], f)
f.close()
    

