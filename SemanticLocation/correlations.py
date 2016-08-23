
# coding: utf-8

# In[14]:

import pandas as pd
import os
import pickle
from preprocess import *
from soplata import *
from utils import *

# read assessment data
with open('/home/sohrob/Dropbox/Code/MATLAB/CS120/Assessment/assessment.dat') as f:
    assessment = pickle.load(f)
f.close()
subjects = assessment['Subject']

# read location and reason data
data_dir = 'features/'

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


# In[19]:

# finding location frequencies across subjects

save_results = True

# getting top locations
loc_top, _ = get_top(locations, 10)

loc_top_dur = ['DUR '+lt for lt in loc_top]

loc_freq = pd.DataFrame(index=range(len(locations)),columns=loc_top)
loc_dur = pd.DataFrame(index=range(len(locations)),columns=loc_top_dur)
for (i,loc_subject) in enumerate(locations):
    for (j,loc_t) in enumerate(loc_top):
        loc_freq.loc[i,loc_t] = loc_subject.count(loc_t)/float(len(loc_subject))
        loc_dur.loc[i,loc_top_dur[j]] = np.mean(durations[i][np.array(loc_subject)==loc_t])

if save_results:
    with open('top_locations.dat','w') as f:
        pickle.dump(loc_top, f)
    f.close()


# In[21]:

# finding reason frequencies across subjects

save_results = True
# getting top reasons
reason_top, freq_top = get_top(reasons, 12)

reason_top_dur = ['DUR '+rt for rt in reason_top]

reason_freq = pd.DataFrame(index=range(len(reasons)),columns=reason_top)
reason_dur = pd.DataFrame(index=range(len(reasons)),columns=reason_top_dur)
for (i,reason_subject) in enumerate(reasons):
    for (j,reason_t) in enumerate(reason_top):
        reason_freq.loc[i,reason_t] = reason_subject.count(reason_t)/float(len(reason_subject))
        reason_dur.loc[i,reason_top_dur[j]] = np.mean(durations[i][np.array(reason_subject)==reason_t])

if save_results:
    with open('top_reasons.dat','w') as f:
        pickle.dump(reason_top, f)
    f.close()        


# In[23]:

print reason_top
print freq_top


# In[17]:

# accomplishment and pleasure means and vars

accomp = pd.DataFrame(index=range(len(locations)),columns=['accomplishment mean','accomplishment var'])
for (i,acc) in enumerate(accomplishments):
    accomp.loc[i,'accomplishment mean'] = np.nanmean(acc)
    accomp.loc[i,'accomplishment var'] = np.nanvar(acc)

pleas = pd.DataFrame(index=range(len(locations)),columns=['pleasure mean','pleasure var'])
for (i,pl) in enumerate(pleasures):
    pleas.loc[i,'pleasure mean'] = np.nanmean(pl)
    pleas.loc[i,'pleasure var'] = np.nanvar(pl)


# In[ ]:

# from numba import jit, autojit
# cov_numba = autojit(calculate_covariance)


# In[18]:

# correlation matrix

data_fm = pd.concat([loc_freq, loc_dur, reason_freq, reason_dur, accomp, pleas, assessment.drop(['Subject'],axis=1)], axis=1)

data_cov = calculate_covariance(data_fm.values.astype(float))

get_ipython().magic(u'matplotlib inline')

# truncate labels
labs = [lab[0:20] for lab in data_fm.columns]

plot_confusion_matrix(data_cov, labels=labs, cmap=plt.cm.bwr)


# In[ ]:

loc_dur

