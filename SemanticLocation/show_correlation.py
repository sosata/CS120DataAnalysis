
# coding: utf-8

# In[1]:

# Visualizes the location visit durations across different demographic (e.g., emplotyment) and mental health (e.g. depression)
# groups

import pickle
import os
import numpy as np
import pandas as pd

# reading top locations
with open('top_locations.dat') as f:
    location_top = pickle.load(f)
f.close()

# reading assessments
with open('../Assessment/assessment.dat') as f:
    data = pickle.load(f)
f.close()

# reading demographics
with open('../Demographics/demo.dat') as f:
    demo = pickle.load(f)
f.close()

# adding demo to dataframe
data.insert(loc=len(data.columns), column='gender', value=np.nan)
data.insert(loc=len(data.columns), column='age', value=np.nan)
data.insert(loc=len(data.columns), column='employment', value=np.nan)

for (i,subj) in enumerate(data['ID']):
    ind = np.where(demo['ID']==subj)[0][0]
    data.loc[i,'gender'] = demo.loc[ind, 'gender']
    data.loc[i,'age'] = demo.loc[ind, 'age']
    data.loc[i,'employment'] = demo.loc[ind, 'employment']

# adding durations to dataframes
for loc_top in location_top:
    data.insert(loc=len(data.columns), column=loc_top, value=np.nan)

folders = os.listdir('data/')
for fol in folders:
    ind_subject = np.where(data['ID']==fol)[0][0]
    subfolders = os.listdir('data/'+fol)
    data.loc[ind_subject, location_top] = 0
    dur_all = 0
    for subf in subfolders:
        file_eml = 'data/'+fol+'/'+subf+'/eml.csv'
        file_fus = 'data/'+fol+'/'+subf+'/fus.csv'
        if os.path.exists(file_eml) and os.path.exists(file_fus):
            df = pd.read_csv(file_eml, sep='\t', header=None)
            loc = df.loc[0,6][2:-2]
            df = pd.read_csv(file_fus, sep='\t', header=None)
            t = np.array(df.loc[:,0])
            tdiff = t[1:]-t[:-1]
            tdiff = tdiff[tdiff<600]
            dur = np.sum(tdiff)

            if loc in location_top:
                data.loc[ind_subject, loc] += dur
            dur_all += dur
    data.loc[ind_subject, location_top] /= dur_all #normalize


# In[2]:

def remove_parentheses(ss):
    ss = np.array(ss)
    for i in range(ss.size):
        s = ss[i].split('(')
        s = s[0]
        ss[i] = s
    return ss


# In[4]:

# correlation matrix

from soplata import *
from utils import *

data_new = data.drop(['ID','SPIN W0','SPIN W3','SPIN W6','gender','employment','age'],axis=1)
data_cov, pval = calculate_covariance(data_new.values.astype(float))

#%matplotlib inline
get_ipython().magic(u'matplotlib notebook')

# truncate labels
# labs = [lab[0:20] for lab in data_new.columns]
labs = remove_parentheses(data_new.columns)

data_cov[pval>=0.05]=0

plot_confusion_matrix(data_cov, labels=labs, cmap=plt.cm.bwr, xsize=7, ysize=7, title='Pearson\'s r')


# In[26]:

plot_confusion_matrix(pval<0.05, labels=labs, cmap=plt.cm.bwr, xsize=5, ysize=5)


# In[9]:

# only mental health vars vs semantic locaiton

from scipy.stats import pearsonr, spearmanr

target = data_new[['PHQ9 W0','PHQ9 W3','PHQ9 W6','GAD7 W0','GAD7 W3','GAD7 W6']]
location = data_new.drop(['PHQ9 W0','PHQ9 W3','PHQ9 W6','GAD7 W0','GAD7 W3','GAD7 W6'],axis=1)

r = pd.DataFrame(index=location.columns, columns=target.columns)
p = pd.DataFrame(index=location.columns, columns=target.columns)
tab = pd.DataFrame(index=location.columns, columns=target.columns, dtype=str)
for tar in target.columns:
    for loc in location.columns:
        x = target.loc[:,tar].astype(float)
        y = location.loc[:,loc].astype(float)
        indnan = np.where(np.logical_or(np.isnan(x),np.isnan(y)))[0]
        x = x.drop(indnan)
        y = y.drop(indnan)
        x = x.reset_index(drop=True)
        y = y.reset_index(drop=True)
        rr,pp = pearsonr(x,y)
        r.loc[loc,tar] = rr
        p.loc[loc,tar] = pp


# In[32]:

# only mental health vars vs semantic locaiton - with bootstrap

from scipy.stats import pearsonr, spearmanr

n_bs = 1000

corr_med = pd.DataFrame(index=location.columns, columns=target.columns)
corr_hi = pd.DataFrame(index=location.columns, columns=target.columns)
corr_lo = pd.DataFrame(index=location.columns, columns=target.columns)
for tar in target.columns:
    for loc in location.columns:
        x = target.loc[:,tar].astype(float)
        y = location.loc[:,loc].astype(float)
        indnan = np.where(np.logical_or(np.isnan(x),np.isnan(y)))[0]
        x = x.drop(indnan)
        y = y.drop(indnan)
        x = x.reset_index(drop=True)
        y = y.reset_index(drop=True)
        r = np.zeros([n_bs])
        p = np.zeros([n_bs])
        for bs in range(n_bs):
            ind = np.random.choice(np.arange(x.size), size=x.size, replace=True)
            x_s = x.loc[ind]
            y_s = y.loc[ind]
            r[bs],p[bs] = pearsonr(x_s,y_s)
        corr_med.loc[loc,tar] = np.median(r)
        corr_hi.loc[loc,tar] = np.percentile(r, 99.9)
        corr_lo.loc[loc,tar] = np.percentile(r, 0.1)


# In[24]:

get_ipython().magic(u'matplotlib inline')
plt.hist(r,25)


# In[11]:

# print the table
corr_med


# In[33]:

np.sign(corr_lo)+np.sign(corr_hi)


# In[18]:

np.max(corr_hi, keepdims=False)


# In[19]:

np.min(corr_lo, keepdims=False)


# In[35]:

.05/66

