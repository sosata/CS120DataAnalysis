
# coding: utf-8

# In[33]:

import csv
import os
import numpy as np
from get_data_at_location import get_data_at_location
from calculate_confusion_matrix import calculate_confusion_matrix
import matplotlib.pyplot as plt
from sklearn import preprocessing
from sklearn.ensemble import RandomForestClassifier
from sklearn.cross_validation import cross_val_score
import math
import xgboost
import pickle
from sys import exit

get_ipython().magic(u'matplotlib inline')

n_folds = 5
save_results = False

data_dir = '/home/sohrob/Dropbox/Data/CS120/'

subjects = os.listdir(data_dir)
#48 skipped / this subject's eml.csv file contain lots of empty elements that should be removed
#52 as well
#subjects = subjects[154:] 

#subjects = [subjects[1]]
subjects = ['506107']

#print subjects

for subj in subjects:
    filename = data_dir + subj + '/eml.csv'
    if os.path.exists(filename):
        print filename
        loc = []
        lat_report = []
        lng_report = []
        t_report = []
        with open(filename) as file_in:
            data = csv.reader(file_in, delimiter='\t')
            for data_row in data:
                if data_row:
                    # reading location category (state)
                    loc_string = data_row[6]
                    loc_string = loc_string[1:len(loc_string)-1]
                    loc_string.split(',')
                    loc.append(loc_string)
                    
                    # reading lat. and long.
                    lat_report.append(float(data_row[2]))
                    lng_report.append(float(data_row[3]))
                    t_report.append(float(data_row[0]))
        file_in.close()
    else:
        print 'skipping subject '+subj+' without location report data.'
        continue
                       
    # looking into data between current and previous report
    filename = data_dir + subj + '/fus.csv'
    if os.path.exists(filename):
        with open(filename) as file_in:
            data_gps = csv.reader(file_in, delimiter='\t')
            t_gps = []
            lat_gps = []
            lng_gps = []
            for row_gps in data_gps:
                t_gps.append(float(row_gps[0]))
                lat_gps.append(float(row_gps[1]))
                lng_gps.append(float(row_gps[2]))
        file_in.close()
    else:
        print 'skipping subject '+subj+' without location data.'
        continue

    ############################################################################################################
    # creating feature and state matrices
    t_prev = 0
    feature = np.array([])
    state = []
    for i in range(len(t_report)):

        ft_row = np.array([])

        # location features
        #data_value = get_data_at_location(data_dir+subj, t_report[i], t_prev, lat_report[i], lng_report[i], 'fus')
        #for j in range(len(data_value)):
            #feature.append([float(data_value[j][1]), float(data_value[j][2])])
            #state.append(loc[i])

        # light features
        data_lgt = get_data_at_location(data_dir+subj, t_report[i], t_prev, lat_report[i], lng_report[i], 'lgt')
        if data_lgt.size:
            lgt = data_lgt[:,1]
            lgt = lgt.astype(np.float)
            ft_row = np.append(ft_row, [np.mean(lgt), np.std(lgt)])
        else:
            ft_row = np.append(ft_row, [np.nan, np.nan])

        # sound features
        data_aud = get_data_at_location(data_dir+subj, t_report[i], t_prev, lat_report[i], lng_report[i], 'aud')
        if data_aud.size:
            aud = data_aud[:,1]
            aud = aud.astype(np.float)
            ft_row = np.append(ft_row, [np.mean(aud), np.std(aud)])
        else:
            ft_row = np.append(ft_row, [np.nan, np.nan])

        # screen features
        data_scr = get_data_at_location(data_dir+subj, t_report[i], t_prev, lat_report[i], lng_report[i], 'scr')
        if data_scr.size:
            if len(data_scr[:,0])>=2:
                deltat = float(data_scr[len(data_scr)-1,0])-float(data_scr[0,0])
                if deltat!=0:
                    ft_row = np.append(ft_row, len(data_scr[:,0])/deltat)
                else:
                    ft_row = np.append(ft_row, np.nan)
            else:
                ft_row = np.append(ft_row, 0.0)
        else:
            ft_row = np.append(ft_row, 0.0)

        # activity features
        data_act = get_data_at_location(data_dir+subj, t_report[i], t_prev, lat_report[i], lng_report[i], 'act')
        if data_act.size:
            per_still = len(np.where(data_act[:,1]=='STILL')[0])/float(len(data_act[:,0]))
            per_tilt = len(np.where(data_act[:,1]=='TILTING')[0])/float(len(data_act[:,0]))
            per_onfoot = len(np.where(data_act[:,1]=='ONFOOT')[0])/float(len(data_act[:,0]))
            per_unknown = len(np.where(data_act[:,1]=='UNKNOWN')[0])/float(len(data_act[:,0]))
        else:
            per_still = 0
            per_tilt = 0
            per_onfoot = 0
            per_unknown = 0
        ft_row = np.append(ft_row, [per_still, per_tilt, per_onfoot, per_unknown])

        # app features
        data_app = get_data_at_location(data_dir+subj, t_report[i], t_prev, lat_report[i], lng_report[i], 'app')
        if data_app.size:
            n_mobilyze = len(np.where(data_app[:,2]=='Mobilyze')[0])
            n_phone = len(np.where(data_app[:,2]=='Phone')[0])
            n_contacts = len(np.where(data_app[:,2]=='Contacts')[0])
            n_messaging = len(np.where(data_app[:,2]=='Messaging')[0])
            n_chrome = len(np.where(data_app[:,2]=='Chrome')[0])
            n_facebook = len(np.where(data_app[:,2]=='Facebook')[0])
            n_messenger = len(np.where(data_app[:,2]=='Messenger')[0])
            n_twitter = len(np.where(data_app[:,2]=='Twitter')[0])
            n_video = len(np.where(data_app[:,2]=='Video Player')[0])
            n_camera = len(np.where(data_app[:,2]=='Camera')[0])
            ft_row = np.append(ft_row, [n_mobilyze, n_phone, n_contacts, n_messaging, n_chrome, n_facebook, n_messenger,                                    n_twitter, n_video, n_camera])
        else:
            ft_row = np.append(ft_row, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

        # communication events
        data_coe = get_data_at_location(data_dir+subj, t_report[i], t_prev, lat_report[i], lng_report[i], 'coe')
        if data_coe.size:
            n_call = len(np.where(data_coe[:,3]=='PHONE')[0])
            n_sms = len(np.where(data_coe[:,3]=='SMS')[0])
            n_missedcall = len(np.where(data_coe[:,4]=='MISSED')[0])
            ft_row = np.append(ft_row, [n_call, n_sms, n_missedcall])
        else:
            ft_row = np.append(ft_row, [0, 0, 0])

        # wifi
        data_wif = get_data_at_location(data_dir+subj, t_report[i], t_prev, lat_report[i], lng_report[i], 'wif')
        if data_wif.size:
            n_w = data_wif[:,3]
            n_w = n_w.astype(np.float)
            n_wifi = np.mean(n_w)
            ft_row = np.append(ft_row, n_wifi)
        else:
            ft_row = np.append(ft_row, np.nan)

        # general features
        ft_row = np.append(ft_row, [t_report[i]-t_prev, ((t_report[i]-t_prev)/2.0)%86400])

        # adding to feature vector
        if i==0:
            feature = np.array([ft_row])
            state = np.array(loc[i])
        else:
            feature = np.append(feature, [ft_row], axis=0)
            state = np.append(state, loc[i])
            
        #state.append(loc[i])

        if i<len(t_report)-1:
            if t_report[i]!=t_report[i+1]:
                t_prev = t_report[i]
                
    feature_label = np.array(['lgt mean','lgt std','aud mean','snd std','screen','still','tilt','foot','unknown',                             'mobilyze','phone','contacts','messaging','chrome','facebook','messenger','twitter',                             'video','camera','n call','n sms','n missed','n wifi','delta_t','mid hour'])

    # keeping only classes with more than 2 samples
    # inds = [i for (i,s) in enumerate(state) if state.count(state[i])>=n_folds]
    # feature = feature[inds,:]
    # state_label = [s for (i,s) in enumerate(loc_uniq) if state.count(s)>=n_folds]
    # state = [s for (i,s) in enumerate(state) if state.count(state[i])>=n_folds]

    # converting location categories to codes
    # le = preprocessing.LabelEncoder()
    # le.fit(state)
    # state = le.transform(state) 

    # saving features and states
    if save_results:
        with open('features/features_'+subj+'.dat', 'w') as file_out:
            pickle.dump([feature, state], file_out)
        file_out.close()

exit(0)


# In[37]:

print len(loc)
print len(t_report)
print loc


# In[43]:

# spatial visualization
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


# In[18]:

print subj
print len(subjects[26:])

