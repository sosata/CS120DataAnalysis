
# coding: utf-8

# In[57]:

import pandas as pd
import numpy as np

data = pd.ExcelFile('/home/sohrob/Dropbox/Data/CS120Clinical/CS120Final_Baseline.xlsx')
data = data.parse('Sheet1')

ind_subject = np.where(data.loc[0:999,'ID'].astype(str)!='nan')[0]

n_job_loc1 = data.loc[ind_subject,'slabels04b_1'].astype(float)
n_job_loc2 = data.loc[ind_subject,'slabels04b_2'].astype(float)
n_job_loc3 = data.loc[ind_subject,'slabels04b_3'].astype(float)
n_job_loc4 = data.loc[ind_subject,'slabels04b_4'].astype(float)
n_job_loc5 = data.loc[ind_subject,'slabels04b_5'].astype(float)

n_job_loc1 = n_job_loc1.reset_index(drop=True)
n_job_loc2 = n_job_loc2.reset_index(drop=True)
n_job_loc3 = n_job_loc3.reset_index(drop=True)
n_job_loc4 = n_job_loc4.reset_index(drop=True)
n_job_loc5 = n_job_loc5.reset_index(drop=True)

np.sum(n_job_loc1==2)


# In[81]:

i = 2
print 'people who work in {} locations:'.format(i)
print np.sum(n_job_loc1==i)+np.sum(n_job_loc2==i)+np.sum(n_job_loc3==i)+np.sum(n_job_loc4==i)+np.sum(n_job_loc5==i)


# In[75]:

data = pd.ExcelFile('/home/sohrob/Dropbox/Data/CS120Clinical/CS120Final_Screener.xlsx')
data = data.parse('Sheet1')

ind_subject = np.where(data.loc[0:999,'ID'].astype(str)!='nan')[0]

mobility = data.loc[ind_subject,'mob01'].astype(float)


# In[79]:

print 'people not able to walk:'
print np.sum(mobility==2)

