
# coding: utf-8

# In[113]:

import csv
import os
import numpy as np
from get_data_at_location import get_data_at_location
from calculate_confusion_matrix import calculate_confusion_matrix
import math
import pickle
from sys import exit
import pandas as pd
import datetime
from scipy import stats
from count_transitions import count_transitions

save_results = True

data_dir = 'data/'

subjects = os.listdir(data_dir)
#subjects = [subjects[0]]

for subj in subjects:
    subject_dir = data_dir + subj + '/'
    samples = os.listdir(subject_dir)
    #print samples
    #samples = [samples[0]]
    loc = []
    feature = np.array([])
    state = np.array([])
    for (i,samp) in enumerate(samples):
        sensor_dir = subject_dir + samp + '/'
        sensors = os.listdir(sensor_dir)
        if not ('eml.csv' in sensors):
            print 'subject '+subj+' does not have location report data at '+samp
            continue
        else:
            filename = sensor_dir+'eml.csv'
            data_eml = pd.read_csv(filename, delimiter='\t', header=None)
            loc_string = data_eml[6][0]
            loc_string = loc_string[1:len(loc_string)-1]
            loc.append(loc_string)
            
        ft_row = np.array([])
        
        if 'lgt.csv' in sensors:
            data = pd.read_csv(sensor_dir+'lgt.csv', delimiter='\t', header=None)
            lgt = data[:][1]
            ft_row = np.append(ft_row, [np.nanmean(lgt), np.nanstd(lgt), np.sum(lgt==0)/float(lgt.size),                                        np.sum(np.diff(np.sign(lgt-np.nanmean(lgt))))/float(lgt.size)]) # prop. zero-crossings
        else:
            ft_row = np.append(ft_row, [np.nan, np.nan, np.nan, np.nan])

        if 'aud.csv' in sensors:
            data = pd.read_csv(sensor_dir+'aud.csv', delimiter='\t', header=None)
            ft_row = np.append(ft_row, [np.nanmean(data[:][1]), np.nanstd(data[:][1]), np.nanmean(data[:][2]), np.nanstd(data[:][2])])
        else:
            ft_row = np.append(ft_row, [np.nan, np.nan, np.nan, np.nan])

        if 'scr.csv' in sensors:
            data = pd.read_csv(sensor_dir+'scr.csv', delimiter='\t', header=None)
            if data[:][0].size>=2:
                deltat = data[0][data[0][:].size-1] - data[0][0]
                if deltat!=0:
                    ft_row = np.append(ft_row, data[0][:].size/float(deltat))
                else:
                    ft_row = np.append(ft_row, np.nan)
            else:
                ft_row = np.append(ft_row, 0)
        else:
            ft_row = np.append(ft_row, 0)
        
        if 'act.csv' in sensors:
            data = pd.read_csv(sensor_dir+'act.csv', delimiter='\t', header=None)
            n = float(data[0][:].size)
            per_still = np.sum(data[1][:]=='STILL')/n
            per_tilt = np.sum(data[1][:]=='TILTING')/n
            per_onfoot = np.sum(data[1][:]=='ONFOOT')/n
            per_unknown = np.sum(data[1][:]=='UNKNOWN')/n
            n_trans1 = count_transitions(data[1][:],'STILL','ONFOOT')/n
            n_trans2 = count_transitions(data[1][:],'STILL','TILTING')/n
            ft_row = np.append(ft_row, [per_still, per_tilt, per_onfoot, per_unknown, n_trans1, n_trans2])
        else:
            ft_row = np.append(ft_row, [np.nan, np.nan, np.nan, np.nan, np.nan, np.nan])
        
        if 'app.csv' in sensors:
            data = pd.read_csv(sensor_dir+'app.csv', delimiter='\t', header=None)
            n_mobilyze = np.sum(data[2][:]=='Mobilyze')
            n_phone = np.sum(data[2][:]=='Phone')
            n_contacts = np.sum(data[2][:]=='Contacts')
            n_messaging = np.sum(data[2][:]=='Messaging')
            n_chrome = np.sum(data[2][:]=='Chrome')
            n_facebook = np.sum(data[2][:]=='Facebook')
            n_messenger = np.sum(data[2][:]=='Messenger')
            n_twitter = np.sum(data[2][:]=='Twitter')
            n_video = np.sum(data[2][:]=='Video')
            n_camera = np.sum(data[2][:]=='Camera')
            ft_row = np.append(ft_row, [n_mobilyze, n_phone, n_contacts, n_messaging, n_chrome, n_facebook, n_messenger,                                         n_twitter, n_video, n_camera])            
        else:
            ft_row = np.append(ft_row, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
            
        if 'coe.csv' in sensors:
            data = pd.read_csv(sensor_dir+'coe.csv', delimiter='\t', header=None)
            n_call = np.sum(data[3][:]=='PHONE')
            n_sms = np.sum(data[3][:]=='SMS')
            n_missedcall = np.sum(data[4][:]=='MISSED')
            ft_row = np.append(ft_row, [n_call, n_sms, n_missedcall])
        else:
            ft_row = np.append(ft_row, [0, 0, 0])
            
        if 'wif.csv' in sensors:
            data = pd.read_csv(sensor_dir+'wif.csv', delimiter='\t', header=None)
            ft_row = np.append(ft_row, np.mean(data[3][:]))
        else:
            ft_row = np.append(ft_row, np.nan)
            
        if 'fus.csv' in sensors:
            data = pd.read_csv(sensor_dir+'fus.csv', delimiter='\t', header=None)
            t_start = data[0][0]
            t_end = data[0][data[0][:].size-1]
            lat = data[1][:]
            lng = data[2][:]
            ft_row = np.append(ft_row, [np.mean(lat), np.mean(lng), np.log(np.var(lat)+np.var(lng)+1e-16)])
        else:
            ft_row = np.append(ft_row,[np.nan, np.nan, np.nan])
        
        if 'wtr.csv' in sensors:
            data = pd.read_csv(sensor_dir+'wtr.csv', delimiter='\t', header=None)
            ft_row = np.append(ft_row, [np.mean(data[1][:]), np.mean(data[3][:]), stats.mode(data[9][:])[0][0]])
        else:
            ft_row = np.append(ft_row, np.nan, np.nan, np.nan)
        
        # time features
        dow_start = datetime.datetime.fromtimestamp(t_start).weekday()
        dow_end = datetime.datetime.fromtimestamp(t_end).weekday()
        ft_row = np.append(ft_row, [t_end-t_start, ((t_end+t_start)/2.0)%86400, dow_start, dow_end])

        # adding to feature vector
        if i==0:
            feature = np.array([ft_row])
            state = np.array(loc[i])
        else:
            feature = np.append(feature, [ft_row], axis=0)
            state = np.append(state, loc[i])
        
    feature_label = np.array(['lgt mean','lgt std','aud mean','aud std','frq mean','frq std','screen','still','tilt','foot','unknown',                             'still_onfoot','still_tilting','mobilyze','phone','contacts','messaging','chrome','facebook','messenger','twitter',                             'video','camera','n call','n sms','n missed','n wifi','lat','lng','loc var','temp','dew point','condition',                              'delta_t','mid hour','dow start','dow end'])
    if save_results:
        with open('features_new/features_'+subj+'.dat', 'w') as file_out:
            pickle.dump([feature, state, feature_label], file_out)
        file_out.close()

exit


# In[39]:

import datetime
a = datetime.datetime.fromtimestamp(1000).weekday()


# In[43]:

# spatial visualization
import matplotlib.pyplot as plt
get_ipython().magic(u'matplotlib inline')
colors = plt.cm.jet(np.linspace(0,1,len(loc_uniq)))
plt.figure(figsize=(18,15))
plt.rcParams['figure.figsize'] = (10, 6)
plt.plot(np.array(lng_gps),np.array(lat_gps),'ko',alpha=0.1, markersize=12)
for i in range(len(loc_uniq)):
    inds = loc.index(loc_uniq[i])
    plt.plot(np.array(lng_report[inds]), np.array(lat_report[inds]), 'o', color=colors[i], alpha=1, markersize=12)
plt.legend(['gps']+loc_uniq, frameon=False, loc='center left', bbox_to_anchor=(0.6, 0.8))
plt.box()


# In[83]:

# temporal visualization
from sklearn import preprocessing
print loc
le = preprocessing.LabelEncoder()
le.fit(loc)
loc_code = le.transform(loc)
plt.figure(figsize=(12,6))
plt.plot(loc_code,'.k',markersize=10)
plt.yticks(range(len(loc_uniq)), loc_uniq)
axes = plt.gca()
axes.set_xlim([0, len(loc_code)])
axes.set_ylim([-1, len(loc_uniq)])
print t_report


# In[3]:




# In[12]:




# In[13]:

# temporal visualization
plt.figure(figsize=(12,6))
plt.plot(state_code,'.k',markersize=10)
plt.yticks(range(len(loc_uniq)), loc_uniq)
axes = plt.gca()
axes.set_xlim([0, len(state_code)])
axes.set_ylim([-1, len(loc_uniq)])
print loc_uniq


# In[15]:

plt.figure(figsize=(18,15))
plt.plot(np.array(lng_gps),np.array(lat_gps),'k.', markersize=12, alpha=.6)
plt.plot(feature[:,1],feature[:,0],'r.', markersize=12, alpha=.6)
#plt.plot(np.array(lng_report),np.array(lat_report),'r.', markersize=12, alpha=.6)


# In[18]:

# distribution of features across locations
ft = 0
plt.figure(figsize=(18,8))
plt.plot(state_code+np.random.uniform(-.1,.1,len(state_code)), feature[:,ft],'.',markersize=20, alpha=.5)
axes = plt.gca()
axes.set_xlim([-.5, len(loc_uniq)-.5])
plt.xticks(range(len(loc_uniq)), loc_uniq)


# In[14]:

#creating train and test sets
split = np.floor(state_code.size/2)
x_train = feature[0:split,:]
x_test = feature[(split+1):,:]
y_train = state_code[0:split]
y_test = state_code[(split+1):]

#train
gbm = xgboost.XGBClassifier(max_depth=3, n_estimators=300, learning_rate=0.05).fit(x_train, y_train)

#test
predictions = gbm.predict(x_test)

#print predictions
#print y_test
conf, roc_auc = calculate_confusion_matrix(predictions, y_test)
print loc_uniq
print conf
print roc_auc

#clf = RandomForestClassifier(n_estimators=100)
#scores = cross_val_score(clf, feature, state_code, cv=n_folds)
#print scores.mean()


# In[14]:



