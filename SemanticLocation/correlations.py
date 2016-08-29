
# coding: utf-8

# In[1]:

import pandas as pd
import os
import pickle
from preprocess import *
from soplata import *
from utils import *
import pickle

# read assessment data
with open('/home/sohrob/Dropbox/Code/MATLAB/CS120/Assessment/assessment.dat') as f:
    assessment = pickle.load(f)
f.close()
subjects = assessment['ID']

# read location and reason data
data_dir = 'features_breakloc/'

reasons = []
locations = []
durations = []
accomplishments = []
pleasures = []
ind_toremove = []
for (i,subject) in enumerate(subjects):
    print i,
    filename = data_dir+subject+'.dat'
    if os.path.exists(filename):
        
        with open(filename) as f:
            feature, target = pickle.load(f)
        f.close()
        
        reasons.append(list(target['reason']))
        locations.append(list(target['location']))
        durations.append(np.array(feature['duration']))
        accomplishments.append(np.array(target['accomplishment']))
        pleasures.append(np.array(target['pleasure']))
        
    else:
        ind_toremove.append(i)
        print 'subject {} skipped because no data.'.format(subject)

# remove assessments of subject which don't exist in sensor feature data
assessment = assessment.drop(ind_toremove, axis=0)
assessment = assessment.reset_index(drop=True)


# In[2]:

target


# In[3]:

# finding location frequencies across subjects

with open('top_locations.dat') as f:
    loc_top = pickle.load(f)
f.close()

loc_top_dur = ['DUR '+lt for lt in loc_top]

loc_freq = pd.DataFrame(index=range(len(locations)),columns=loc_top)
loc_dur = pd.DataFrame(index=range(len(locations)),columns=loc_top_dur)
for (i,loc_subject) in enumerate(locations):
    for (j,loc_t) in enumerate(loc_top):
        if loc_t in loc_subject:
            loc_freq.loc[i,loc_t] = loc_subject.count(loc_t)/float(len(loc_subject))
            loc_dur.loc[i,loc_top_dur[j]] = np.mean(durations[i][np.array(loc_subject)==loc_t])

loc_top


# In[4]:

# finding reason frequencies across subjects

with open('top_reasons.dat') as f:
    reason_top = pickle.load(f)
f.close()

reason_top_dur = ['DUR '+rt for rt in reason_top]

reason_freq = pd.DataFrame(index=range(len(reasons)),columns=reason_top)
reason_dur = pd.DataFrame(index=range(len(reasons)),columns=reason_top_dur)
for (i,reason_subject) in enumerate(reasons):
    for (j,reason_t) in enumerate(reason_top):
        if reason_t in reason_subject:
            reason_freq.loc[i,reason_t] = reason_subject.count(reason_t)/float(len(reason_subject))
            reason_dur.loc[i,reason_top_dur[j]] = np.mean(durations[i][np.array(reason_subject)==reason_t])



# In[5]:

# accomplishment and pleasure means and vars

accomp_all = pd.DataFrame(index=range(len(locations)),columns=['total accomp mean','total accomp var'])
for (i,acc) in enumerate(accomplishments):
    accomp_all.loc[i,'total accomp mean'] = np.nanmean(acc)
    accomp_all.loc[i,'total accomp var'] = np.nanvar(acc)

pleas_all = pd.DataFrame(index=range(len(locations)),columns=['total pleasure mean','total pleasure var'])
for (i,pl) in enumerate(pleasures):
    pleas_all.loc[i,'total pleasure mean'] = np.nanmean(pl)
    pleas_all.loc[i,'total pleasure var'] = np.nanvar(pl)


# In[6]:

# accomplishment and pleasure per location

accomp_mean = pd.DataFrame(index=range(len(locations)),columns=['acc m '+lt for lt in loc_top])
pleas_mean = pd.DataFrame(index=range(len(locations)),columns=['pls m '+lt for lt in loc_top])
for (i,_) in enumerate(accomplishments):
    for (j,l_top) in enumerate(loc_top):
        inds = np.where(np.array(locations[i])==l_top)[0]
        accomp_mean.loc[i,'acc m '+l_top] = np.nanmean(accomplishments[i][inds])
        pleas_mean.loc[i,'pls m '+l_top] = np.nanmean(pleasures[i][inds])
        


# In[12]:

# correlation matrix
save_data = True

data_fm = pd.concat([loc_freq, loc_dur, reason_freq, reason_dur, accomp_all, pleas_all, accomp_mean,                      pleas_mean, assessment.drop(['ID'],axis=1)], axis=1)

data_cov = calculate_covariance(data_fm.values.astype(float))

#%matplotlib inline
get_ipython().magic(u'matplotlib notebook')

# truncate labels
labs = [lab[0:20] for lab in data_fm.columns]

plot_confusion_matrix(data_cov, labels=labs, cmap=plt.cm.bwr, xsize=15, ysize=15)

if save_data:
    with open('location_assessment.dat','w') as f:
        pickle.dump(data_fm, f)
    f.close()


# In[8]:

data_fm


# In[9]:

from mpld3 import plugins

fig, ax = plt.subplots(subplot_kw=dict(axisbg='#EEEEEE'))
ax.grid(color='white', linestyle='solid')

N = 50
scatter = ax.scatter(np.random.normal(size=N),
                     np.random.normal(size=N),
                     c=np.random.random(size=N),
                     s = 1000 * np.random.random(size=N),
                     alpha=0.3,
                     cmap=plt.cm.jet)

# ax.set_title("D3 Scatter Plot (with tooltips!)", size=20)

labels = ['point {0}'.format(i + 1) for i in range(N)]
fig.plugins = [plugins.PointLabelTooltip(scatter, labels)]

