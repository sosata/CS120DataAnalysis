
# coding: utf-8

# In[167]:

# Visualizes the location visit durations across different demographic (e.g., emplotyment) and mental health (e.g. depression)
# groups


import pickle
import os
import numpy as np
import pandas as pd

ft_dir = 'features_long/'

# list feature files
files = os.listdir(ft_dir)
# files = [files[0]]

# reading top locations
with open('top_locations.dat') as f:
    location_top = pickle.load(f)
f.close()

# reading assessments
with open('../Assessment/assessment.dat') as f:
    data = pickle.load(f)
f.close()

# adding durations to the dataframe
for loc_top in location_top:
    data.insert(loc=len(data.columns), column=loc_top, value=np.nan)

for filename in files:
    with open(ft_dir+filename) as f:  
        feature, target = pickle.load(f)

        ind_subject = np.where(data['ID']==filename[:-4])[0][0]
        
        data.loc[ind_subject, location_top] = 0
        dur_all = 0
        for (i,loc) in enumerate(target['location']):
            if not np.isnan(feature['duration'][i]):
                if loc in location_top:
                    data.loc[ind_subject, loc] += feature['duration'][i]
                dur_all += feature['duration'][i]
        
        # normalize
        data.loc[ind_subject, location_top] /= dur_all
        
    f.close()


# In[168]:

data


# In[169]:

# all subjects

import matplotlib.pyplot as plt
get_ipython().magic(u'matplotlib inline')

data_loc = data.loc[:,location_top]
mean = np.mean(data_loc, axis=0)
ci = np.std(data_loc, axis=0)/np.sqrt(data_loc.shape[0])

plt.bar(np.arange(mean.size), mean, yerr=ci, width=.3, color=(0.7,0.7,0.7))
plt.xticks(np.arange(mean.size), data_loc.columns, rotation=270)
plt.legend(['n={}'.format(data_loc.shape[0])])


# In[174]:

# compare depressed to non-depressed

import matplotlib.pyplot as plt
get_ipython().magic(u'matplotlib inline')

# option 1: all <> 10
# ind_dep = np.where(np.logical_and(np.logical_and(data['PHQ9 W0']>=10, data['PHQ9 W3']>=10), data['PHQ9 W6']>=10))[0]
# ind_nodep = np.where(np.logical_and(np.logical_and(data['PHQ9 W0']<10, data['PHQ9 W3']<10), data['PHQ9 W6']<10))[0]

# option 2: average <> 10
ind_dep = np.where(data['PHQ9 W0']+data['PHQ9 W3']+data['PHQ9 W6']>=30)[0]
ind_nodep = np.where(data['PHQ9 W0']+data['PHQ9 W3']+data['PHQ9 W6']<30)[0]


data_dep = data.loc[ind_dep, list(location_top)]
data_nodep = data.loc[ind_nodep, list(location_top)]

mean_dep = np.mean(data_dep, axis=0)
mean_nodep = np.mean(data_nodep, axis=0)
ci_dep = np.std(data_dep, axis=0)/np.sqrt(data_dep.shape[0])
ci_nodep = np.std(data_nodep, axis=0)/np.sqrt(data_nodep.shape[0])

plt.bar(np.arange(mean_dep.size), mean_dep, yerr=ci_dep, width=.3, color=(1,0,0))
plt.bar(np.arange(mean_nodep.size)+.3, mean_nodep, yerr=ci_nodep, width=.3, color=(0,0,1))
plt.xticks(np.arange(mean_dep.size)+.3, data_dep.columns, rotation=270)
plt.legend(['depression (n={})'.format(data_dep.shape[0]),'no depression (n={})'.format(data_nodep.shape[0])])
plt.title('non-normalized')


# In[175]:

# same plot, normalized

plt.bar(np.arange(mean_dep.size), np.divide(mean_dep,mean_dep+mean_nodep), yerr=np.divide(ci_dep,mean_dep+mean_nodep), width=.3, color=(1,0,0))
plt.bar(np.arange(mean_nodep.size)+.3, np.divide(mean_nodep,mean_dep+mean_nodep), yerr=np.divide(ci_nodep,mean_dep+mean_nodep), width=.3, color=(0,0,1))
plt.xticks(np.arange(mean_dep.size)+.3, data_dep.columns, rotation=270)
plt.legend(['depression (n={})'.format(data_dep.shape[0]),'no depression (n={})'.format(data_nodep.shape[0])])
plt.title('normalized')


# In[176]:

# compare anxious to non-anxious

import matplotlib.pyplot as plt
get_ipython().magic(u'matplotlib inline')

# option 1: all <> 10
# ind_anx = np.where(np.logical_and(np.logical_and(data['GAD7 W0']>=10, data['GAD7 W3']>=10), data['GAD7 W6']>=10))[0]
# ind_noanx = np.where(np.logical_and(np.logical_and(data['GAD7 W0']<10, data['GAD7 W3']<10), data['GAD7 W6']<10))[0]

# option 2: average <> 10
ind_anx = np.where(data['GAD7 W0']+data['GAD7 W3']+data['GAD7 W6']>=30)[0]
ind_noanx = np.where(data['GAD7 W0']+data['GAD7 W3']+data['GAD7 W6']<30)[0]

data_anx = data.loc[ind_anx, list(location_top)]
data_noanx = data.loc[ind_noanx, list(location_top)]

mean_anx = np.mean(data_anx, axis=0)
mean_noanx = np.mean(data_noanx, axis=0)
ci_anx = np.std(data_anx, axis=0)/np.sqrt(data_anx.shape[0])
ci_noanx = np.std(data_noanx, axis=0)/np.sqrt(data_noanx.shape[0])

plt.bar(np.arange(mean_anx.size), mean_anx, yerr=ci_anx, width=.3, color=(1,0,0))
plt.bar(np.arange(mean_noanx.size)+.3, mean_noanx, yerr=ci_noanx, width=.3, color=(0,0,1))
plt.xticks(np.arange(mean_anx.size)+.3, data_anx.columns, rotation=270)
plt.legend(['anxiety (n={})'.format(data_dep.shape[0]),'no anxiety (n={})'.format(data_nodep.shape[0])])
plt.title('non-normalized')


# In[177]:

# same but normalized

plt.bar(np.arange(mean_anx.size), np.divide(mean_anx,mean_anx+mean_noanx), yerr=np.divide(ci_anx,mean_anx+mean_noanx), width=.3, color=(1,0,0))
plt.bar(np.arange(mean_noanx.size)+.3, np.divide(mean_noanx,mean_anx+mean_noanx), yerr=np.divide(ci_noanx,mean_anx+mean_noanx), width=.3, color=(0,0,1))
plt.xticks(np.arange(mean_anx.size)+.3, data_anx.columns, rotation=270)
plt.legend(['anxiety (n={})'.format(data_dep.shape[0]),'no anxiety (n={})'.format(data_nodep.shape[0])])
plt.title('normalized')


# In[138]:

data['GAD7 W0']+data['GAD7 W3']


# In[153]:

np.divide(mean_dep,mean_dep+mean_nodep)

