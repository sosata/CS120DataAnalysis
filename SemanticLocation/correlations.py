
# coding: utf-8

# In[1]:

# reading location and reason data

import pandas as pd
import os
from preprocess import *
from soplata import *
from utils import *

data_dir = '/home/sohrob/Dropbox/Data/CS120FourSquare/'

subjects = os.listdir(data_dir)

reasons = []
locations = []
for (i,subject) in enumerate(subjects):
    print i,
    filename = data_dir+subject+'/fsq2.csv'
    if os.path.exists(filename):
        
        data = pd.read_csv(filename, delimiter='\t', header=None)

        # preprocessing and adding reasons
        reason = preprocess_reason(data.loc[:,7].tolist())
        reasons.append(reason)
        
        # preprocessing and adding locations
        location = preprocess_location(data.loc[:,6].tolist())
        locations.append(location)
        
    else:
        print 'subject {} skipped because no data.'.format(subject)


# In[2]:

# loading top locations
import pickle

with open('top10location.dat') as f:
    loc_top = pickle.load(f)
f.close()

for (i,s) in enumerate(loc_top):
    loc_top[i] = loc_top[i].replace('"','')

print loc_top

# finding location frequencies across subjects
loc_freq = pd.DataFrame(index=range(len(locations)),columns=loc_top)

for (i,loc_subject) in enumerate(locations):
    for loc_t in loc_top:
        loc_freq.loc[i,loc_t] = loc_subject.count(loc_t)/float(len(loc_subject))

print loc_freq.shape


# In[3]:

# finding top reasons
reason_all = [x for y in reasons for x in y]
reason_uniq = list(set(reason_all))

freq = []
for i in range(len(reason_uniq)):
    freq.append(0)
    for j in range(len(subjects)):
        if reason_uniq[i] in reasons[j]:
            freq[i] += 1

ind_sort = sorted(range(len(freq)), key=lambda k: freq[k], reverse=True)
freq_sorted = [freq[x] for x in ind_sort]
reason_uniq_sorted = [reason_uniq[x] for x in ind_sort]

freq_sorted_top = freq_sorted[:20]
reason_top = reason_uniq_sorted[:20]

print reason_top

# finding reason frequencies across subjects
reason_freq = pd.DataFrame(index=range(len(reasons)),columns=reason_top)

for (i,reason_subject) in enumerate(reasons):
    for reason_t in reason_top:
        reason_freq.loc[i,reason_t] = reason_subject.count(reason_t)/float(len(reason_subject))

print reason_freq.shape


# In[4]:

# adding in assessments

import numpy as np

# screener
xl = pd.ExcelFile('/home/sohrob/Dropbox/Data/CS120Clinical/CS120Final_Screener.xlsx')
df = xl.parse('Sheet1')
phq0 = pd.DataFrame(index=range(len(subjects)),columns=['PHQ9 W0'],dtype=object)
gad0 = pd.DataFrame(index=range(len(subjects)),columns=['GAD7 W0'],dtype=object)
for (i,subject) in enumerate(subjects):
    if subject in list(df['ID'].astype('str')):
        # PHQ-9
        phq_items = np.array(df.loc[df['ID'].astype('str')==subject, list(df.columns[64:72])])
        if 999 in phq_items:
            phq_items[phq_items==999] = 0
        phq0.loc[i] = np.sum(phq_items)
        # GAD-7
        gad_items = np.array(df.loc[df['ID'].astype('str')==subject, list(df.columns[73:80])])
        if 999 in gad_items:
            gad_items[gad_items==999] = 0
        gad0.loc[i] = np.sum(gad_items)
    else:
        phq0.loc[i] = np.nan
        gad0.loc[i] = np.nan

# week 0 (baseline)
xl = pd.ExcelFile('/home/sohrob/Dropbox/Data/CS120Clinical/CS120Final_Baseline.xlsx')
df = xl.parse('Sheet1')
spin0 = pd.DataFrame(index=range(len(subjects)),columns=['SPIN W0'],dtype=object)
for (i,subject) in enumerate(subjects):
    if subject in list(df['ID'].astype('str')):
        # SPIN
        spin_items = np.array(df.loc[df['ID'].astype('str')==subject, list(df.columns[217:234])])
        if 999 in spin_items:
            spin_items[spin_items==999] = 0
        spin0.loc[i] = np.sum(spin_items)
    else:
        spin0.loc[i] = np.nan
        
# week 3
xl = pd.ExcelFile('/home/sohrob/Dropbox/Data/CS120Clinical/CS120Final_3week.xlsx')
df = xl.parse('Sheet1')
phq3 = pd.DataFrame(index=range(len(subjects)),columns=['PHQ9 W3'],dtype=object)
gad3 = pd.DataFrame(index=range(len(subjects)),columns=['GAD7 W3'],dtype=object)
spin3 = pd.DataFrame(index=range(len(subjects)),columns=['SPIN W3'],dtype=object)
for (i,subject) in enumerate(subjects):
    if subject in list(df['ID'].astype('str')):
        # PHQ-9
        phq_items = np.array(df.loc[df['ID'].astype('str')==subject, list(df.columns[61:69])])
        if 999 in phq_items:
            phq_items[phq_items==999] = 0
        phq3.loc[i] = np.sum(phq_items)
        # GAD-7
        gad_items = np.array(df.loc[df['ID'].astype('str')==subject, list(df.columns[44:51])])
        if 999 in gad_items:
            gad_items[gad_items==999] = 0
        gad3.loc[i] = np.sum(gad_items)
        # SPIN
        spin_items = np.array(df.loc[df['ID'].astype('str')==subject, list(df.columns[27:44])])
        if 999 in spin_items:
            spin_items[spin_items==999] = 0
        spin3.loc[i] = np.sum(spin_items)
    else:
        phq3.loc[i] = np.nan
        gad3.loc[i] = np.nan
        spin3.loc[i] = np.nan

# week 6
xl = pd.ExcelFile('/home/sohrob/Dropbox/Data/CS120Clinical/CS120Final_6week.xlsx')
df = xl.parse('Sheet1')
phq6 = pd.DataFrame(index=range(len(subjects)),columns=['PHQ9 W6'],dtype=object)
gad6 = pd.DataFrame(index=range(len(subjects)),columns=['GAD7 W6'],dtype=object)
spin6 = pd.DataFrame(index=range(len(subjects)),columns=['SPIN W6'],dtype=object)
for (i,subject) in enumerate(subjects):
    if subject in list(df['ID'].astype('str')):
        # PHQ-9
        phq_items = np.array(df.loc[df['ID'].astype('str')==subject, list(df.columns[61:69])])
        if 999 in phq_items:
            phq_items[phq_items==999] = 0
        phq6.loc[i] = np.sum(phq_items)
        # GAD-7
        gad_items = np.array(df.loc[df['ID'].astype('str')==subject, list(df.columns[44:51])])
        if 999 in gad_items:
            gad_items[gad_items==999] = 0
        gad6.loc[i] = np.sum(gad_items)
        # SPIN
        spin_items = np.array(df.loc[df['ID'].astype('str')==subject, list(df.columns[27:44])])
        if 999 in spin_items:
            spin_items[spin_items==999] = 0
        spin6.loc[i] = np.sum(spin_items)
    else:
        phq6.loc[i] = np.nan
        gad6.loc[i] = np.nan
        spin6.loc[i] = np.nan
        
#df[['ID'] + list(df.columns[61:69])].iloc[100:105]


# In[5]:

# from numba import jit, autojit
# cov_numba = autojit(calculate_covariance)


# In[6]:

# showing the correlation matrix

data_fm = pd.concat([loc_freq, reason_freq, phq0, gad0, spin0, phq3, gad3, spin3, phq6, gad6, spin6], axis=1)

data_cov = calculate_covariance(data_fm.values.astype(float))

get_ipython().magic(u'matplotlib inline')
plot_confusion_matrix(data_cov, labels=data_fm.columns)



# In[ ]:



