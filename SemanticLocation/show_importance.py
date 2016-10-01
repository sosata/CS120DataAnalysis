
# coding: utf-8

# In[1]:

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
        


# In[104]:

import os
import pickle
import numpy as np
import xgboost as xgb
import pandas as pd

n_bootstrap = 100
do_stratify = False

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
        
        feature_all.append(feature)
        state_all.append(state)
        
    f.close()

# x_train = pd.concat(feature_all, axis=0)
# y_train = pd.concat(state_all)

if do_stratify:
    x_train, y_train = stratify(x_train,y_train)

inds = np.arange(0,len(feature_all),1)
inds_split = np.floor(0.7*len(feature_all))
    
gbm = [[] for _ in range(n_bootstrap)]
for sd in range(n_bootstrap):
    print 'bootstrap {}'.format(sd)
#     gbm[sd] = xgb.XGBClassifier(max_depth=3, n_estimators=300, learning_rate=0.05, nthread=12, subsample=1,\
#                                max_delta_step=0, seed=sd).fit(x_train, y_train)
    np.random.shuffle(inds)
    ind_train = inds[:inds_split]
    ind_test = inds[inds_split:]
    x_train = pd.concat([feature_all[j] for j in ind_train], axis=0)
    y_train = pd.concat([state_all[j] for j in ind_train], axis=0)

    gbm[sd] = xgb.XGBClassifier(max_depth=6, n_estimators=75, learning_rate=0.05, nthread=12, subsample=0.25,                         colsample_bytree=0.2, max_delta_step=0, gamma=3, objective='mlogloss', reg_alpha=0.5,                         missing=np.nan).fit(x_train, y_train)


# In[13]:

state_top10


# In[122]:

import matplotlib.pyplot as plt
import numpy as np

dic = {'lgt mean':'light intensity mean', 'lgt std':'light intensity std', 'lgt off':'% no light', 'lgt zcrossing':'light change',       'lgt skew':'light intensity skewness', 'lgt kurt':'light intensity kurtosis', 'aud mean':'sound amplitude mean',        'aud std':'sound amplitude std', 'aud skew':'sound amplitude skewness', 'aud kurt':'sound amplitude kurtosis',       'aud frq mean':'sound frequency mean', 'aud frq std':'sound frequency std', 'aud frq skew':'sound frequency skewness',       'aud frq kurt':'sound frequency kurtosis', 'scr frq':'screen on/off frequency', 'scr dur mean':'screen on duration mean',        'scr dur std':'screen on duration std', 'still':'% stillness', 'tilting':'% tilting', 'walking':'% walking',       'unknown act':'unknown activity', 'still-walking':'still to walking', 'still-tilting':'still to tilting',       'still-unknown':'still to unknown', 'walking-unknown':'walking to unknown', 'call in':'no incoming calls', 'call out':       'no outgoing calls', 'sms in':'no incoming sms', 'sms out':'no outgoing sms', 'call missed':'no missed calls', 'n wifi':       'no wifi nets', 'temperature':'outside temperature', 'dew point':'outside windchill', 'weather':'outside weather',        'lat mean':'latitude mean', 'lng mean':'longitude mean', 'loc var':'location variance', 'duration':'visit duration',       'midtime':'visit timestamp', 'midhour':'visit time of day', 'dow start':'arrive day of week', 'dow end':       'leave day of week', 'fsq 0':'Foursquare Nightlife Spot', 'fsq 1':'Foursquare Outdoors & Recreation', 'fsq 2':'Foursquare Arts & Entertainment'       , 'fsq 3':'Foursquare Professional or Medical Office', 'fsq 4':'Foursquare Food', 'fsq 5':'Foursquare Home',        'fsq 6':'Foursquare Shop or Store', 'fsq 7':'Foursquare Travel or Transport', 'fsq 8':'Foursquare Unknown', 'fsq distance':       'Foursquare distance', 'LT frequency':'visit frequency', 'LT interval mean':'mean time between visits'}

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
plt.figure(figsize=(10,15))
axes = plt.gca()
plt.barh(np.arange(val_sorted.size), val_sorted, xerr=ci_sorted, color=(.7,.7,1), align='center')
plt.yticks(np.arange(len(feature_label_short)), feature_label_short, fontsize=12, color=(0,0,0));
axes.set_ylim([-1, len(feature_label_short)-1.5])


# In[121]:

dic[feature_label_sorted[i]]

