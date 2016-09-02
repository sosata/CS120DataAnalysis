
# coding: utf-8

# In[14]:

# This code trains models to predict target assessments (PHQ-9, GAD-7) from semntaic location and reason data

import pickle
import pandas as pd
import numpy as np
import xgboost as xgb
from calculate_confusion_matrix import calculate_confusion_matrix
import time

save_results = False
do_stratify = False

with open('location_assessment.dat') as f:
    data = pickle.load(f)
f.close

# feature = data[['Shop or Store', 'Home', 'Food (Restaurant, Cafe)',\
#        "Another's Home", 'Professional or Medical Office', 'Work',\
#        'Arts & Entertainment (Theater, Music Venue, Etc.)',\
#        'Outdoors & Recreation', 'Spiritual (Church, Temple, Etc.)',\
#        'Nightlife Spot (Bar, Club)', 'DUR Shop or Store', 'DUR Home',\
#        'DUR Food (Restaurant, Cafe)', "DUR Another's Home",\
#        'DUR Professional or Medical Office', 'DUR Work',\
#        'DUR Arts & Entertainment (Theater, Music Venue, Etc.)',\
#        'DUR Outdoors & Recreation', 'DUR Spiritual (Church, Temple, Etc.)',\
#        'DUR Nightlife Spot (Bar, Club)', 'home', 'errand', 'dining',\
#        'socialize', 'work', 'entertainment', 'dining,socialize',\
#        'travelling / traffic', 'exercise', 'entertainment,socialize',\
#        'DUR home', 'DUR errand', 'DUR dining', 'DUR socialize',\
#        'DUR work', 'DUR entertainment', 'DUR dining,socialize',\
#        'DUR travelling / traffic', 'DUR exercise',\
#        'DUR entertainment,socialize','PHQ9 W0']].astype(float)

feature = data[['DUR Spiritual (Church, Temple, Etc.)',       'DUR entertainment','entropy','entropy norm']].astype(float)

target = data['PHQ9 W6']

# remove nans from target
ind = np.where(np.array(pd.isnull(target)))[0]
target = target.drop(ind)
feature = feature.drop(ind, axis=0)
target = target.reset_index(drop=True)
feature = feature.reset_index(drop=True)

# classification
target.loc[target<10] = 0
target.loc[target>=10] = 1

confs = []
aucs = []
labels = []

y_pred = np.zeros(feature.shape[0])

for i in range(feature.shape[0]):
    
    print i,
    
    # training set
    j_range = range(feature.shape[0])
    j_range.pop(i)
    
    x_train = feature.loc[j_range,:]
    y_train = target.loc[j_range]
    
    x_train = x_train.reset_index(drop=True)
    y_train = y_train.reset_index(drop=True)
    
#     if do_stratify:
#         x_train, y_train = stratify(x_train,y_train)
    
    # test set
    x_test = pd.DataFrame(feature.loc[i]).transpose()
    y_test = target.loc[i]
    
    # train (layer 1)
    #eta_list = np.array([0.05]*200+[0.02]*200+[0.01]*200)
    gbm = xgb.XGBClassifier(max_depth=2, n_estimators=1000, learning_rate=0.01, nthread=12, subsample=1,                               max_delta_step=0).fit(x_train, y_train)
    
    # train performance
#     y_pred = gbm.predict(x_train)
#     conf_train, roc_auc_train = calculate_confusion_matrix(y_pred, y_train)

    # test (layer 1)
    y_pred[i] = gbm.predict(x_test)
    
    # test performance
    
    
    # foursquare performance
    #conf_fsq, roc_auc_fsq = calculate_confusion_matrix(state_fsq_all[i], y_test)
    

conf, roc_auc = calculate_confusion_matrix(y_pred, np.array(target))

print
print 'AUC: {}'.format(roc_auc[0])
print 'confusion matrix:'
print conf

# saving the results
if save_results:
    with open('auc_location_sensor_fsq.dat','w') as f:
        #pickle.dump([aucs, confs, labels, aucs_fsq, confs_fsq], f)
        pickle.dump([aucs, confs, labels], f)
    f.close()





# In[3]:

data.columns

