
# coding: utf-8

# In[15]:

import os
import pickle
import numpy as np
import xgboost
from calculate_confusion_matrix import calculate_confusion_matrix


ft_dir = 'features/'

files = os.listdir(ft_dir)

for filename in files:
    with open(ft_dir+filename) as f:  
        feature, state, state_label = pickle.load(f)

        #creating train and test sets
        split = np.floor(state.size/2)
        x_train = feature[0:split,:]
        x_test = feature[(split+1):,:]
        y_train = state[0:split]
        y_test = state[(split+1):]

        #train
        gbm = xgboost.XGBClassifier(max_depth=3, n_estimators=300, learning_rate=0.05).fit(x_train, y_train)

        #test
        predictions = gbm.predict(x_test)

        conf, roc_auc = calculate_confusion_matrix(predictions, y_test)
        print filename
        print state_label
        print conf
        print roc_auc
        print '------------------'


# In[13]:



