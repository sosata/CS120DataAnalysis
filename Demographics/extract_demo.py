
# coding: utf-8

# In[2]:

def convert_date_to_age(date):
    y_study = 2015
    m_study = 10
    d_study = 15
    date,_ = date.split(' ')
    y,m,d = date.split('-')
    age = (y_study-float(y)) + (m_study-float(m))/12.0 + (d_study-float(d))/365.0
    return age


# In[4]:

import pandas as pd
import os
import pickle
import numpy as np

xl = pd.ExcelFile('/data/CS120Clinical/CS120Final_Baseline.xlsx')
df = xl.parse('Sheet1')

ind_subject = np.where(df.loc[0:999,'ID'].astype(str)!='nan')[0]
subjects = df.loc[ind_subject, 'ID'].astype(str)
gender = df.loc[ind_subject, 'demo09'].astype(int)
age = df.loc[ind_subject, 'demo08'].astype(str)
age = age.apply(convert_date_to_age)
employment = df.loc[ind_subject, 'slabels02'].astype(int)
education = df.loc[ind_subject, 'demo12'].astype(int)

demo = pd.concat([subjects, gender, age, employment, education], axis=1)
demo.columns = ['ID','gender','age','employment','education']
demo = demo.reset_index(drop=True)

with open('demo.dat','w') as f:
    pickle.dump(demo, f)
f.close()


# In[5]:

demo


# In[23]:

np.sum(demo['education']==9)

