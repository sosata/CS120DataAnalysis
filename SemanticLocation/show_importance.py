
# coding: utf-8

# In[21]:

import os
import pickle
import numpy as np
import xgboost as xgb
import pandas as pd

n_bootstrap = 100

ft_dir = 'features_long/'

# list feature files
files = os.listdir(ft_dir)

with open('top_locations.dat') as f:
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
        feature, state = pickle.load(f)
        
        # only keeping top 10 states
        ind = np.array([], int)
        for (i,st) in enumerate(state['location']):
            if st in state_top10:
                ind = np.append(ind, i)
        feature = feature.loc[ind,:]
        state = state.loc[ind,'location']
        
        feature = feature.reset_index(drop = True)
        state = state.reset_index(drop = True)
        
        feature_all.append(feature)
        state_all.append(state)
        
    f.close()

inds = np.arange(0,len(feature_all),1)
inds_split = np.floor(0.7*len(feature_all))
    
gbm = [[] for _ in range(n_bootstrap)]
for sd in range(n_bootstrap):
    print 'bootstrap {}'.format(sd)
#     np.random.shuffle(inds)
#     ind_train = inds[:inds_split]
#     x_train = pd.concat([feature_all[j] for j in ind_train], axis=0)
#     y_train = pd.concat([state_all[j] for j in ind_train], axis=0)

    x_train = pd.DataFrame(columns=feature_all[0].columns)
    y_train = pd.Series(name=state_all[0].name)
    for i in range(len(feature_all)):
        ind = np.random.choice(np.arange(feature_all[i].shape[0]),size=1)
        x_train = pd.concat([x_train, feature_all[i].loc[ind,:]], axis=0)
        y_train = pd.concat([y_train, state_all[i].loc[ind]], axis=0)
        x_train = x_train.reset_index(drop = True)
        y_train = y_train.reset_index(drop = True)

    gbm[sd] = xgb.XGBClassifier(max_depth=6, n_estimators=75, learning_rate=0.05, nthread=12, subsample=0.25,                         colsample_bytree=0.2, max_delta_step=0, gamma=3, objective='mlogloss', reg_alpha=0.5,                         missing=np.nan).fit(x_train, y_train)


# In[42]:

import matplotlib.pyplot as plt
import numpy as np

dic = {'lgt mean':'light intensity mean', 'lgt std':'light intensity variance', 'lgt off':'darkness duration', 'lgt zcrossing':'light change',       'lgt skew':'light intensity skewness', 'lgt kurt':'light intensity kurtosis', 'aud mean':'sound amplitude mean',        'aud std':'sound amplitude variance', 'aud skew':'sound amplitude skewness', 'aud kurt':'sound amplitude kurtosis',       'aud frq mean':'sound frequency mean', 'aud frq std':'sound frequency variance', 'aud frq skew':'sound frequency skewness',       'aud frq kurt':'sound frequency kurtosis', 'scr frq':'screen on/off frequency', 'scr dur mean':'screen on time',        'scr dur std':'screen on time variance', 'still':'stillness time', 'tilting':'tilting time', 'walking':'walking time',       'unknown act':'unknown activity time', 'still-walking':'still/walking transition', 'still-tilting':'still/tilting transition',       'still-unknown':'still/unknown transition', 'walking-unknown':'walking/unknown transition', 'call in':'no incoming calls', 'call out':       'no outgoing calls', 'sms in':'no incoming sms', 'sms out':'no outgoing sms', 'call missed':'no missed calls', 'n wifi':       'no wifi nets', 'temperature':'outside temperature', 'dew point':'outside windchill', 'weather':'outside weather',        'lat mean':'latitude mean', 'lng mean':'longitude mean', 'loc var':'location variance', 'duration':'visit timespan',       'midtime':'visit timestamp', 'midhour':'visit time of day', 'dow start':'arrive day of week', 'dow end':       'leave day of week', 'fsq 0':'Foursquare Nightlife Spot', 'fsq 1':'Foursquare Outdoors & Recreation', 'fsq 2':'Foursquare Arts & Entertainment'       , 'fsq 3':'Foursquare Professional or Medical Office', 'fsq 4':'Foursquare Food', 'fsq 5':'Foursquare Home',        'fsq 6':'Foursquare Shop or Store', 'fsq 7':'Foursquare Travel or Transport', 'fsq 8':'Foursquare Unknown', 'fsq distance':       'Foursquare distance', 'LT frequency':'visit frequency', 'LT interval mean':'mean time between visits', 'n gps':'visit duration'}

# extracting means and CIs
feature_label = x_train.columns

fscore = pd.DataFrame(index=np.arange(n_bootstrap), columns=feature_label)
for i in range(n_bootstrap):
    keys = np.array(gbm[i].booster().get_fscore().keys())
    vals = np.array(gbm[i].booster().get_fscore().values()).astype(float)
    for lab in feature_label:
        ind = np.where(keys==lab)[0]
        if ind.size>0:
            fscore.loc[i,lab] = vals[ind[0]]
fscore_mean = np.array(fscore.mean(axis=0))
fscore_ci = np.array(fscore.std(axis=0)/np.sqrt(n_bootstrap))
ind_sort = np.array(np.argsort(fscore_mean))
val_sorted = fscore_mean[ind_sort]
ci_sorted = fscore_ci[ind_sort]
feature_label_sorted = feature_label[ind_sort]
feature_label_short = []
for i in range(feature_label_sorted.size):
    feature_label_short.append(dic[feature_label_sorted[i]])
    
get_ipython().magic(u'matplotlib inline')
plt.figure(figsize=(10,12))
axes = plt.gca()
plt.barh(np.arange(val_sorted.size), val_sorted, xerr=ci_sorted, height=.7, color=(.4,.4,.8), align='center', ecolor=(0,0,0))
plt.yticks(np.arange(len(feature_label_short)), feature_label_short, fontsize=12, color=(0,0,0));
axes.set_ylim([3.5, len(feature_label_short)-9.5])
plt.box(on=False)
plt.xlabel('Feature Importance',fontsize=14)
plt.grid()


# In[18]:

feature_all[0].columns

