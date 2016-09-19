
# coding: utf-8

# In[1]:

# This code trains models to predict target assessments (PHQ-9, GAD-7) from semntaic location and reason data

import pickle
import pandas as pd
import numpy as np
import xgboost as xgb
from calculate_confusion_matrix import calculate_confusion_matrix
import time
from crossvalidation import split_binary

# from keras.models import Sequential
# from keras.layers import Dense, Activation
# model = Sequential()
# model.add(Dense(32, input_dim=784))
# model.add(Activation('relu'))

save_results = False
do_stratify = False

n_bootstrap = 1

with open('location_assessment.dat') as f:
    data = pickle.load(f)
f.close

feature = data[['entropy 3','entropy 4','entropy 5','circadian 2','circadian 3','circadian 4',               'change']]

# feature = data.drop(['PHQ9 W0','GAD7 W0','SPIN W0','PHQ9 W3','GAD7 W3','SPIN W3','PHQ9 W6','GAD7 W6','SPIN W6'],axis=1)

feature = feature.astype(float)

target = data['SPIN W6']

# remove nans from target
ind = np.where(np.array(pd.isnull(target)))[0]
target = target.drop(ind)
feature = feature.drop(ind, axis=0)
target = target.reset_index(drop=True)
feature = feature.reset_index(drop=True)

# classification
target.loc[target<19] = 0
target.loc[target>=19] = 1

confs = []
aucs_train = np.zeros(n_bootstrap)
aucs = np.zeros(n_bootstrap)
labels = []

y_pred = np.zeros(feature.shape[0])
ind0 = np.where(target==0)[0]
ind1 = np.where(target==1)[0]
split0 = np.round(ind0.size*0.9)
split1 = np.round(ind1.size*0.9)

for i in range(n_bootstrap):
    print '.',
    
#     # training set
#     inds = np.arange(feature.shape[0])
#     np.random.shuffle(inds)
#     x_train = feature.loc[inds[:split],:]
#     y_train = target.loc[inds[:split]]
#     x_train = x_train.reset_index(drop=True)
#     y_train = y_train.reset_index(drop=True)

#     # test set
#     x_test = feature.loc[inds[split:],:]
#     y_test = target.loc[inds[split:]]
#     x_test = x_test.reset_index(drop=True)
#     y_test = y_test.reset_index(drop=True)

    x_train, y_train, x_test, y_test = split_binary(feature, target, 0.9, oversample=True)

    # train (layer 1)
    #eta_list = np.array([0.05]*200+[0.02]*200+[0.01]*200)
    gbm = xgb.XGBClassifier(max_depth=20, n_estimators=400, learning_rate=0.001, nthread=12, subsample=.1,                            colsample_bytree=np.sqrt(feature.shape[1])/float(feature.shape[1]),                            colsample_bylevel=1, max_delta_step=20, seed=0, objective='binary:logistic').fit(x_train, y_train)
    # TODO: cgb.cv(///)
    
    # train performance
    y_pred = gbm.predict(x_train)
    conf, auc = calculate_confusion_matrix(y_pred, y_train)
    aucs_train[i] = auc[0]

    # test (layer 1)
    y_pred = gbm.predict(x_test)
    
    # test performance
    conf, auc = calculate_confusion_matrix(y_pred, y_test)
    aucs[i] = auc[0]
    confs.append(conf)
    

# conf, roc_auc = calculate_confusion_matrix(y_pred, np.array(target))

print
print 'Train AUC: {}'.format(np.nanmean(aucs_train))
print 'Test AUC: {}'.format(np.nanmean(aucs))
print auc
print conf

# saving the results
if save_results:
    with open('auc_location_sensor_fsq.dat','w') as f:
        #pickle.dump([aucs, confs, labels, aucs_fsq, confs_fsq], f)
        pickle.dump([aucs, confs, labels], f)
    f.close()


# In[ ]:

import matplotlib.pyplot as plt
get_ipython().magic(u'matplotlib inline')
plt.hist(aucs, bins=50, range=(0,1))


# In[ ]:

a = pd.DataFrame(0,index=np.arange(5),columns=['asd'])
b = pd.DataFrame(0,index=np.arange(5),columns=['asd'])
pd.

