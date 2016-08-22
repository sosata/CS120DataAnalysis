
# coding: utf-8

# In[4]:

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
from preprocess import *

save_results = True

data_dir = 'data/'
data_dir_orig = '/home/sohrob/Dropbox/Data/CS120/'

fsq_map = {'Nightlife Spot':'Nightlife Spot (Bar, Club)', 'Outdoors & Recreation':'Outdoors & Recreation',          'Arts & Entertainment':'Arts & Entertainment (Theater, Music Venue, Etc.)',          'Professional & Other Places':'Professional or Medical Office',          'Food':'Food (Restaurant, Cafe)', 'Residence':'Home', 'Shop & Service':'Shop or Store'}

# building one hot encoder for foursquare locations (as extra features)
state7 = np.array(fsq_map.values()+['Unknown'])
le = preprocessing.LabelEncoder()
le.fit(state7)
state7_code = le.transform(state7)
enc = OneHotEncoder()
enc.fit(state7_code.reshape(-1, 1))

subjects = os.listdir(data_dir)
# subjects = [subjects[0]]

for (cnt,subj) in enumerate(subjects):
    
    print str(cnt) + ' ' + subj
    
    subject_dir = data_dir + subj + '/'
    samples = os.listdir(subject_dir)
    
    # checking in the original directory if the subject has app data
    sensors = os.listdir(data_dir_orig+subj)
    if 'app.csv' in sensors:
        has_app_data = True
    else:
        has_app_data = False
    
    # initialization
    feature = pd.DataFrame()
    target = pd.DataFrame()
    
    ind_last = 0
    
    for (i,samp) in enumerate(samples):
        
        sensor_dir = subject_dir + samp + '/'
        sensors = os.listdir(sensor_dir)
        
        # reading semantic location data and skipping if it does not exist
        if 'eml.csv' in sensors:
            filename = sensor_dir+'eml.csv'
            data = pd.read_csv(filename, delimiter='\t', header=None)
            target.loc[ind_last, 'location'] = preprocess_location(data.loc[0,6], parse=False)
            target.loc[ind_last, 'reason'] = preprocess_reason(data.loc[0,7], parse=False)
            target.loc[ind_last, 'accomplishment'] = data.loc[0,8]
            target.loc[ind_last, 'pleasure'] = data.loc[0,9]
        else:
            print 'subject {} does not have location report data at i. skipping'.format(subject,samp)
            continue
        
        if 'fsq2.csv' in sensors:
            data_fsq = pd.read_csv(sensor_dir+'fsq2.csv', delimiter='\t', header=None)
            loc_fsq = data_fsq.loc[10,1]
            distance_fsq = float(data_fsq.loc[11,1])
            
            # converting foursquare category name to standard name
            if loc_fsq in fsq_map:
                loc_fsq = fsq_map[loc_fsq]
            else:
                loc_fsq = 'Unknown'
                
        else:
            loc_fsq = 'Unknown'
            distance_fsq = np.nan
        
        target.loc[ind_last, 'fsq'] = loc_fsq
        
        ## sensor features
        # light
        if 'lgt.csv' in sensors:
            data = pd.read_csv(sensor_dir+'lgt.csv', delimiter='\t', header=None)
            lgt = data[:][1]
            feature.loc[ind_last, 'lgt mean'] = np.nanmean(lgt)
            feature.loc[ind_last, 'lgt std'] = np.nanstd(lgt)
            feature.loc[ind_last, 'lgt off'] = np.sum(lgt==0)/float(lgt.size)
            feature.loc[ind_last, 'lgt zcrossing'] = np.sum(np.diff(np.sign(lgt-np.nanmean(lgt))))/float(lgt.size)
            feature.loc[ind_last, 'lgt skew'] = stats.skew(lgt)
            feature.loc[ind_last, 'lgt kurt'] = stats.kurtosis(lgt)
        else:
            feature.loc[ind_last, 'lgt mean'] = np.nan
            feature.loc[ind_last, 'lgt std'] = np.nan
            feature.loc[ind_last, 'lgt off'] = np.nan
            feature.loc[ind_last, 'lgt zcrossing'] = np.nan
            feature.loc[ind_last, 'lgt skew'] = np.nan
            feature.loc[ind_last, 'lgt kurt'] = np.nan

        # audio
        if 'aud.csv' in sensors:
            data = pd.read_csv(sensor_dir+'aud.csv', delimiter='\t', header=None)
            feature.loc[ind_last, 'aud mean'] = np.nanmean(data[:][1])
            feature.loc[ind_last, 'aud std'] = np.nanstd(data[:][1])
            feature.loc[ind_last, 'aud skew'] = stats.skew(data[:][1])
            feature.loc[ind_last, 'aud kurt'] = stats.kurtosis(data[:][1])
            feature.loc[ind_last, 'aud frq mean'] = np.nanmean(data[:][2])
            feature.loc[ind_last, 'aud frq std'] = np.nanstd(data[:][2])
            feature.loc[ind_last, 'aud frq skew'] = stats.skew(data[:][2])
            feature.loc[ind_last, 'aud frq kurt'] = stats.kurtosis(data[:][2])
        else:
            feature.loc[ind_last, 'aud mean'] = np.nan
            feature.loc[ind_last, 'aud std'] = np.nan
            feature.loc[ind_last, 'aud skew'] = np.nan
            feature.loc[ind_last, 'aud kurt'] = np.nan
            feature.loc[ind_last, 'aud frq mean'] = np.nan
            feature.loc[ind_last, 'aud frq std'] = np.nan
            feature.loc[ind_last, 'aud frq skew'] = np.nan
            feature.loc[ind_last, 'aud frq kurt'] = np.nan


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
                    feature.loc[ind_last, 'scr frq'] = scr_frq/float(deltat)
                    feature.loc[ind_last, 'scr dur mean'] = np.mean(scr_dur)
                    feature.loc[ind_last, 'scr dur std'] = np.std(scr_dur)
                else:
                    feature.loc[ind_last, 'scr frq'] = np.nan
                    feature.loc[ind_last, 'scr dur mean'] = np.nan
                    feature.loc[ind_last, 'scr dur std'] = np.nan
            else:
                feature.loc[ind_last, 'scr frq'] = 0
                feature.loc[ind_last, 'scr dur mean'] = 0
                feature.loc[ind_last, 'scr dur std'] = np.nan
        else:
            feature.loc[ind_last, 'scr frq'] = 0
            feature.loc[ind_last, 'scr dur mean'] = 0
            feature.loc[ind_last, 'scr dur std'] = np.nan
        
        # activity
        if 'act.csv' in sensors:
            data = pd.read_csv(sensor_dir+'act.csv', delimiter='\t', header=None)
            n = float(data[0][:].size)
            feature.loc[ind_last, 'still'] = np.sum(data[1][:]=='STILL')/n
            feature.loc[ind_last, 'tilting'] = np.sum(data[1][:]=='TILTING')/n
            feature.loc[ind_last, 'walking'] = np.sum(data[1][:]=='ONFOOT')/n
            feature.loc[ind_last, 'unknown act'] = np.sum(data[1][:]=='UNKNOWN')/n
            feature.loc[ind_last, 'still-walking'] = count_transitions(data[1][:],'STILL','ONFOOT')/n
            feature.loc[ind_last, 'still-tilting'] = count_transitions(data[1][:],'STILL','TILTING')/n
            feature.loc[ind_last, 'still-unknown'] = count_transitions(data[1][:],'STILL','UNKNOWN')/n
            feature.loc[ind_last, 'walking-unknown'] = count_transitions(data[1][:],'ONFOOT','UNKNOWN')/n
        else:
            feature.loc[ind_last, 'still'] = np.nan
            feature.loc[ind_last, 'tilting'] = np.nan
            feature.loc[ind_last, 'walking'] = np.nan
            feature.loc[ind_last, 'unknown act'] = np.nan
            feature.loc[ind_last, 'still-walking'] = np.nan
            feature.loc[ind_last, 'still-tilting'] = np.nan
            feature.loc[ind_last, 'still-unknown'] = np.nan
            feature.loc[ind_last, 'walking-unknown'] = np.nan
            
        # apps
        if 'app.csv' in sensors:
            data = pd.read_csv(sensor_dir+'app.csv', delimiter='\t', header=None)
            feature.loc[ind_last, 'messaging'] = np.sum(data[2][:]=='Messaging')
            feature.loc[ind_last, 'facebook'] = np.sum(data[2][:]=='Facebook')
            feature.loc[ind_last, 'chrome'] = np.sum(data[2][:]=='Chrome')
            feature.loc[ind_last, 'mobilyze'] = np.sum(data[2][:]=='Mobilyze')
            feature.loc[ind_last, 'phone'] = np.sum(data[2][:]=='Phone')
            feature.loc[ind_last, 'gmail'] = np.sum(data[2][:]=='Gmail')
            feature.loc[ind_last, 'contacts'] = np.sum(data[2][:]=='Contacts')
            feature.loc[ind_last, 'internet'] = np.sum(data[2][:]=='Internet')
            feature.loc[ind_last, 'gallery'] = np.sum(data[2][:]=='Gallery')
            feature.loc[ind_last, 'email'] = np.sum(data[2][:]=='Email')
            feature.loc[ind_last, 'settings'] = np.sum(data[2][:]=='Settings')
            feature.loc[ind_last, 'messenger'] = np.sum(data[2][:]=='Messenger')
            feature.loc[ind_last, 'camera'] = np.sum(data[2][:]=='Camera')
            feature.loc[ind_last, 'clock'] = np.sum(data[2][:]=='Clock')
            feature.loc[ind_last, 'maps'] = np.sum(data[2][:]=='Maps')
            feature.loc[ind_last, 'calendar'] = np.sum(data[2][:]=='Calendar')
            feature.loc[ind_last, 'youtube'] = np.sum(data[2][:]=='Youtube')
            feature.loc[ind_last, 'calculator'] = np.sum(data[2][:]=='Calculator')
            feature.loc[ind_last, 'purple robot'] = np.sum(data[2][:]=='Purple Robot')
            feature.loc[ind_last, 'system ui'] = np.sum(data[2][:]=='System UI')
        else:
            if has_app_data: # if not, leave them as NaN
                feature.loc[ind_last, 'messaging'] = 0
                feature.loc[ind_last, 'facebook'] = 0
                feature.loc[ind_last, 'chrome'] = 0
                feature.loc[ind_last, 'mobilyze'] = 0
                feature.loc[ind_last, 'phone'] = 0
                feature.loc[ind_last, 'gmail'] = 0
                feature.loc[ind_last, 'contacts'] = 0
                feature.loc[ind_last, 'internet'] = 0
                feature.loc[ind_last, 'gallery'] = 0
                feature.loc[ind_last, 'email'] = 0
                feature.loc[ind_last, 'settings'] = 0
                feature.loc[ind_last, 'messenger'] = 0
                feature.loc[ind_last, 'camera'] = 0
                feature.loc[ind_last, 'clock'] = 0
                feature.loc[ind_last, 'maps'] = 0
                feature.loc[ind_last, 'calendar'] = 0
                feature.loc[ind_last, 'youtube'] = 0
                feature.loc[ind_last, 'calculator'] = 0
                feature.loc[ind_last, 'purple robot'] = 0
                feature.loc[ind_last, 'system ui'] = 0
            else:
                feature.loc[ind_last, 'messaging'] = np.nan
                feature.loc[ind_last, 'facebook'] = np.nan
                feature.loc[ind_last, 'chrome'] = np.nan
                feature.loc[ind_last, 'mobilyze'] = np.nan
                feature.loc[ind_last, 'phone'] = np.nan
                feature.loc[ind_last, 'gmail'] = np.nan
                feature.loc[ind_last, 'contacts'] = np.nan
                feature.loc[ind_last, 'internet'] = np.nan
                feature.loc[ind_last, 'gallery'] = np.nan
                feature.loc[ind_last, 'email'] = np.nan
                feature.loc[ind_last, 'settings'] = np.nan
                feature.loc[ind_last, 'messenger'] = np.nan
                feature.loc[ind_last, 'camera'] = np.nan
                feature.loc[ind_last, 'clock'] = np.nan
                feature.loc[ind_last, 'maps'] = np.nan
                feature.loc[ind_last, 'calendar'] = np.nan
                feature.loc[ind_last, 'youtube'] = np.nan
                feature.loc[ind_last, 'calculator'] = np.nan
                feature.loc[ind_last, 'purple robot'] = np.nan
                feature.loc[ind_last, 'system ui'] = np.nan
            
        # communication
        if 'coe.csv' in sensors:
            data = pd.read_csv(sensor_dir+'coe.csv', delimiter='\t', header=None)
            feature.loc[ind_last, 'call in'] = np.sum(np.logical_and(data[3][:]=='PHONE',data[4][:]=='INCOMING'))
            feature.loc[ind_last, 'call out'] = np.sum(np.logical_and(data[3][:]=='PHONE',data[4][:]=='OUTGOING'))
            feature.loc[ind_last, 'sms in'] = np.sum(np.logical_and(data[3][:]=='SMS',data[4][:]=='INCOMING'))
            feature.loc[ind_last, 'sms out'] = np.sum(np.logical_and(data[3][:]=='SMS',data[4][:]=='OUTGOING'))
            feature.loc[ind_last, 'call missed'] = np.sum(data[4][:]=='MISSED')
        else:
            feature.loc[ind_last, 'call in'] = 0
            feature.loc[ind_last, 'call out'] = 0
            feature.loc[ind_last, 'sms in'] = 0
            feature.loc[ind_last, 'sms out'] = 0
            feature.loc[ind_last, 'call missed'] = 0
        
        # wifi
        if 'wif.csv' in sensors:
            data = pd.read_csv(sensor_dir+'wif.csv', delimiter='\t', header=None)
            feature.loc[ind_last, 'n wifi'] = np.mean(data[3][:])
        else:
            feature.loc[ind_last, 'n wifi'] = np.nan
        
        # weather
        if 'wtr.csv' in sensors:
            data = pd.read_csv(sensor_dir+'wtr.csv', delimiter='\t', header=None)
            wtr_cond = stats.mode(data[9][:])[0][0]
            if not isinstance(wtr_cond, basestring):
                wtr_cond = str(wtr_cond)
            feature.loc[ind_last, 'temperature'] = np.mean(data[1][:])
            feature.loc[ind_last, 'dew point'] = np.mean(data[3][:])
            feature.loc[ind_last, 'weather'] = sum(ord(c) for c in wtr_cond)
        else:
            feature.loc[ind_last, 'temperature'] = np.nan
            feature.loc[ind_last, 'dew point'] = np.nan
            feature.loc[ind_last, 'weather'] = np.nan
        
        # GPS and time
        if 'fus.csv' in sensors:
            data = pd.read_csv(sensor_dir+'fus.csv', delimiter='\t', header=None)
            t_start = data[0][0]
            t_end = data[0][data[0][:].size-1]
            feature.loc[ind_last, 'lat mean'] = np.mean(data[1][:])
            feature.loc[ind_last, 'lng mean'] = np.mean(data[2][:])
            feature.loc[ind_last, 'loc var'] = np.log(np.var(data[1][:])+np.var(data[2][:])+1e-16)
            feature.loc[ind_last, 'duration'] = t_end-t_start
            feature.loc[ind_last, 'midtime'] = ((t_end+t_start)/2.0)%86400
            feature.loc[ind_last, 'dow start'] = datetime.datetime.fromtimestamp(t_start).weekday()
            feature.loc[ind_last, 'dow end'] = datetime.datetime.fromtimestamp(t_end).weekday()
        else:
            feature.loc[ind_last, 'lat mean'] = np.nan
            feature.loc[ind_last, 'lng mean'] = np.nan
            feature.loc[ind_last, 'loc var'] = np.nan
            feature.loc[ind_last, 'duration'] = np.nan
            feature.loc[ind_last, 'midtime'] = np.nan
            feature.loc[ind_last, 'dow start'] = np.nan
            feature.loc[ind_last, 'dow end'] = np.nan
        
        # foursquare location in binary form
        loc_fsq_code = le.transform(loc_fsq)
        loc_fsq_bin = enc.transform(loc_fsq_code.reshape(-1,1)).toarray()
        loc_fsq_bin = loc_fsq_bin[0]
        for j in range(loc_fsq_bin.size):
            feature.loc[ind_last, 'fsq {}'.format(j)] = loc_fsq_bin[j]
        
        # distance to closest foursquare location (m)
        feature.loc[ind_last, 'fsq distance'] = distance_fsq
        
        ind_last += 1

    print feature.shape, target.shape
    if save_results:
        with open('features/'+subj+'.dat', 'w') as file_out:
            pickle.dump([feature, target], file_out)
        file_out.close()

os._exit(0)


# In[3]:

feature


# In[ ]:

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


# In[ ]:

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


# In[ ]:

# temporal visualization
plt.figure(figsize=(12,6))
plt.plot(state_code,'.k',markersize=10)
plt.yticks(range(len(loc_uniq)), loc_uniq)
axes = plt.gca()
axes.set_xlim([0, len(state_code)])
axes.set_ylim([-1, len(loc_uniq)])
print loc_uniq


# In[ ]:

# distribution of features across locations
ft = 0
plt.figure(figsize=(18,8))
plt.plot(state_code+np.random.uniform(-.1,.1,len(state_code)), feature[:,ft],'.',markersize=20, alpha=.5)
axes = plt.gca()
axes.set_xlim([-.5, len(loc_uniq)-.5])
plt.xticks(range(len(loc_uniq)), loc_uniq)


# In[ ]:



