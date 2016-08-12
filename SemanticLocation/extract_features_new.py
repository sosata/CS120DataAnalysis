
# coding: utf-8

# In[2]:

import csv
import os
import numpy as np
from get_data_at_location import get_data_at_location
from calculate_confusion_matrix import calculate_confusion_matrix
import math
import pickle
import pandas as pd
import datetime
from scipy import stats
from count_transitions import count_transitions
from sklearn.preprocessing import OneHotEncoder
from sklearn import preprocessing

save_results = True

data_dir = 'data/'

feature_label = np.array(['lgt mean','lgt std','aud mean','aud std','frq mean','frq std','screen','still','tilt','foot','unknown',                         'still_onfoot','still_tilting','mobilyze','phone','contacts','messaging','chrome','facebook','messenger','twitter',                         'video','camera','n call','n sms','n missed','n wifi','lat','lng','loc var','temp','dew point','condition',                          'delta_t','mid hour','dow start','dow end'])

fsq_map = {'Nightlife Spot':'Nightlife Spot (Bar, Club)', 'Outdoors & Recreation':'Outdoors & Recreation',          'Arts & Entertainment':'Arts & Entertainment (Theater, Music Venue, Etc.)',          'Professional & Other Places':'Professional or Medical Office',          'Food':'Food (Restaurant, Cafe)', 'Residence':'Home', 'Shop & Service':'Shop or Store'}

# building one hot encoder for foursquare locations (as extra features)
state7 = np.array(fsq_map.values()+['Unknown'])
le = preprocessing.LabelEncoder()
le.fit(state7)
state7_code = le.transform(state7)
enc = OneHotEncoder()
enc.fit(state7_code.reshape(-1, 1))

subjects = os.listdir(data_dir)
#subjects = [subjects[0]]

for (cnt,subj) in enumerate(subjects):
    subject_dir = data_dir + subj + '/'
    samples = os.listdir(subject_dir)
    print str(cnt) + ' ' + subj
    feature = np.array([])
    state = np.array([])
    state_fsq = np.array([])
    for (i,samp) in enumerate(samples):
        sensor_dir = subject_dir + samp + '/'
        sensors = os.listdir(sensor_dir)
        if not ('eml.csv' in sensors):
            print 'subject '+subj+' does not have location report data at '+samp
            continue
        else:
            filename = sensor_dir+'eml.csv'
            data_eml = pd.read_csv(filename, delimiter='\t', header=None)
            loc = data_eml[6][0]
            loc = loc[1:len(loc)-1]
            loc = loc.replace('"','')
        
        if 'fsq2.csv' in sensors:
            data_fsq = pd.read_csv(sensor_dir+'fsq2.csv', delimiter='\t', header=None)
            loc_fsq = data_fsq.loc[10,1]
            distance_fsq = data_fsq.loc[11,1]
            
            # converting foursquare category name to standard name
            if loc_fsq in fsq_map:
                loc_fsq = fsq_map[loc_fsq]
            else:
                loc_fsq = 'Unknown'
                
        else:
            loc_fsq = 'Unknown'
            distance_fsq = np.nan
        
        ft_row = np.array([])
        
        # light
        if 'lgt.csv' in sensors:
            data = pd.read_csv(sensor_dir+'lgt.csv', delimiter='\t', header=None)
            lgt = data[:][1]
            ft_row = np.append(ft_row, [np.nanmean(lgt), np.nanstd(lgt), np.sum(lgt==0)/float(lgt.size),                                        np.sum(np.diff(np.sign(lgt-np.nanmean(lgt))))/float(lgt.size),                                       stats.skew(lgt), stats.kurtosis(lgt)]) # prop. zero-crossings
        else:
            ft_row = np.append(ft_row, [np.nan, np.nan, np.nan, np.nan, np.nan, np.nan])

        # audio
        if 'aud.csv' in sensors:
            data = pd.read_csv(sensor_dir+'aud.csv', delimiter='\t', header=None)
            ft_row = np.append(ft_row, [np.nanmean(data[:][1]), np.nanstd(data[:][1]),                                         stats.skew(data[:][1]), stats.kurtosis(data[:][1]),                                        np.nanmean(data[:][2]), np.nanstd(data[:][2]),                                        stats.skew(data[:][2]), stats.kurtosis(data[:][2])])
        else:
            ft_row = np.append(ft_row, [np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan])

        # screen
        if 'scr.csv' in sensors:
            data = pd.read_csv(sensor_dir+'scr.csv', delimiter='\t', header=None)
            if data[:][0].size>=2:
                deltat = data[0][data[0][:].size-1] - data[0][0]
                if deltat!=0:
                    scr_dur = np.array([])
                    scr_frq = 0
                    for j in range(data[1][:].size-1):
                        if data[1][j]=='True' and data[1][j+1]=='False':
                            scr_dur = np.append(scr_dur, data[0][j+1]-data[0][j])
                            scr_frq += 1
                    ft_row = np.append(ft_row, [scr_frq/float(deltat), np.mean(scr_dur), np.std(scr_dur)])
                else:
                    ft_row = np.append(ft_row, [np.nan,np.nan,np.nan])
            else:
                ft_row = np.append(ft_row, [0,0,0])
        else:
            ft_row = np.append(ft_row, [0,0,0])
        
        # activity
        if 'act.csv' in sensors:
            data = pd.read_csv(sensor_dir+'act.csv', delimiter='\t', header=None)
            n = float(data[0][:].size)
            per_still = np.sum(data[1][:]=='STILL')/n
            per_tilt = np.sum(data[1][:]=='TILTING')/n
            per_onfoot = np.sum(data[1][:]=='ONFOOT')/n
            per_unknown = np.sum(data[1][:]=='UNKNOWN')/n
            n_trans1 = count_transitions(data[1][:],'STILL','ONFOOT')/n
            n_trans2 = count_transitions(data[1][:],'STILL','TILTING')/n
            n_trans3 = count_transitions(data[1][:],'STILL','UNKNOWN')/n
            n_trans4 = count_transitions(data[1][:],'ONFOOT','UNKNOWN')/n
            ft_row = np.append(ft_row, [per_still, per_tilt, per_onfoot, per_unknown, n_trans1, n_trans2,                                       n_trans3, n_trans4])
        else:
            ft_row = np.append(ft_row, [np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan])
        
        # apps
        if 'app.csv' in sensors:
            data = pd.read_csv(sensor_dir+'app.csv', delimiter='\t', header=None)
            ft_row = np.append(ft_row, [np.sum(data[2][:]=='Messaging'),                                        np.sum(data[2][:]=='Facebook'),                                        np.sum(data[2][:]=='Chrome'),                                        np.sum(data[2][:]=='Mobilyze'),                                        np.sum(data[2][:]=='Phone'),                                        np.sum(data[2][:]=='Gmail'),                                        np.sum(data[2][:]=='Contacts'),                                        np.sum(data[2][:]=='Internet'),                                        np.sum(data[2][:]=='Gallery'),                                        np.sum(data[2][:]=='Email'),                                        np.sum(data[2][:]=='Settings'),                                        np.sum(data[2][:]=='Messenger'),                                        np.sum(data[2][:]=='Camera'),                                        np.sum(data[2][:]=='Clock'),                                        np.sum(data[2][:]=='Maps'),                                        np.sum(data[2][:]=='Calendar'),                                        np.sum(data[2][:]=='Youtube'),                                        np.sum(data[2][:]=='Calculator'),                                        np.sum(data[2][:]=='Purple Robot'),                                        np.sum(data[2][:]=='System UI')])
        else:
            ft_row = np.append(ft_row, np.zeros([1,20]))
            
        # communication
        if 'coe.csv' in sensors:
            data = pd.read_csv(sensor_dir+'coe.csv', delimiter='\t', header=None)
            n_call_in = np.sum(np.logical_and(data[3][:]=='PHONE',data[4][:]=='INCOMING'))
            n_call_out = np.sum(np.logical_and(data[3][:]=='PHONE',data[4][:]=='OUTGOING'))
            n_sms_in = np.sum(np.logical_and(data[3][:]=='SMS',data[4][:]=='INCOMING'))
            n_sms_out = np.sum(np.logical_and(data[3][:]=='SMS',data[4][:]=='OUTGOING'))
            n_missedcall = np.sum(data[4][:]=='MISSED')
            ft_row = np.append(ft_row, [n_call_in,n_call_out,n_sms_in,n_sms_out,n_missedcall])
        else:
            ft_row = np.append(ft_row, [0, 0, 0, 0, 0])
        
        # wifi
        if 'wif.csv' in sensors:
            data = pd.read_csv(sensor_dir+'wif.csv', delimiter='\t', header=None)
            ft_row = np.append(ft_row, np.mean(data[3][:]))
        else:
            ft_row = np.append(ft_row, np.nan)
        
        # GPS 
        if 'fus.csv' in sensors:
            data = pd.read_csv(sensor_dir+'fus.csv', delimiter='\t', header=None)
            t_start = data[0][0]
            t_end = data[0][data[0][:].size-1]
            lat = data[1][:]
            lng = data[2][:]
            ft_row = np.append(ft_row, [np.mean(lat), np.mean(lng), np.log(np.var(lat)+np.var(lng)+1e-16)])
        else:
            ft_row = np.append(ft_row,[np.nan, np.nan, np.nan])
        
        # weather
        if 'wtr.csv' in sensors:
            data = pd.read_csv(sensor_dir+'wtr.csv', delimiter='\t', header=None)
            ft_row = np.append(ft_row, [np.mean(data[1][:]), np.mean(data[3][:]), stats.mode(data[9][:])[0][0]])
        else:
            ft_row = np.append(ft_row, [np.nan, np.nan, np.nan])
        
        # time
        dow_start = datetime.datetime.fromtimestamp(t_start).weekday()
        dow_end = datetime.datetime.fromtimestamp(t_end).weekday()
        ft_row = np.append(ft_row, [t_end-t_start, ((t_end+t_start)/2.0)%86400, dow_start, dow_end])
        
        # adding foursquare location
        loc_fsq_code = le.transform(loc_fsq)
        loc_fsq_bin = enc.transform(loc_fsq_code.reshape(-1,1)).toarray()            
        ft_row = np.append(ft_row, loc_fsq_bin[0])
        
        # adding distance to closest foursquare location (m)
        ft_row = np.append(ft_row, distance_fsq)

        # adding to feature matrix
        if i==0:
            feature = np.array([ft_row])
            state = np.array(loc)
            state_fsq = np.array(loc_fsq)
        else:
            feature = np.append(feature, [ft_row], axis=0)
            state = np.append(state, loc)
            state_fsq = np.append(state_fsq, loc_fsq)
        
    if save_results:
        with open('features_new/features_'+subj+'.dat', 'w') as file_out:
            pickle.dump([feature, state, state_fsq, feature_label], file_out)
        file_out.close()

os._exit(0)


# In[8]:

print state_fsq[0:9]
print feature[0:9,:]


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


# In[13]:

# temporal visualization
plt.figure(figsize=(12,6))
plt.plot(state_code,'.k',markersize=10)
plt.yticks(range(len(loc_uniq)), loc_uniq)
axes = plt.gca()
axes.set_xlim([0, len(state_code)])
axes.set_ylim([-1, len(loc_uniq)])
print loc_uniq


# In[18]:

# distribution of features across locations
ft = 0
plt.figure(figsize=(18,8))
plt.plot(state_code+np.random.uniform(-.1,.1,len(state_code)), feature[:,ft],'.',markersize=20, alpha=.5)
axes = plt.gca()
axes.set_xlim([-.5, len(loc_uniq)-.5])
plt.xticks(range(len(loc_uniq)), loc_uniq)


# In[14]:



