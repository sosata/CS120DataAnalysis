# Extracts depression and anxiety related outcomes (PHQ-9, GAD-7, SPIN)

import numpy as np
import pandas as pd
import os
import pickle

#data_dir = '/home/sohrob/Dropbox/Data/CS120/'
#subjects = os.listdir(data_dir)
#subjects_df = pd.DataFrame(subjects, columns=['Subject'])

# screener
xl = pd.ExcelFile('/home/sohrob/Dropbox/Data/CS120Clinical/CS120Final_Screener.xlsx')
df = xl.parse('Sheet1')

ind_subject = np.where(df.loc[0:999,'ID'].astype(str)!='nan')[0]
subjects_df = df.loc[ind_subject, 'ID'].astype(str)
subjects_df.columns = ['Subject']
subjects_df = subjects_df.reset_index(drop=True)
subjects = list(subjects_df)

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

print subjects

assessment = pd.concat([subjects_df, phq0, gad0, spin0, phq3, gad3, spin3, phq6, gad6, spin6], axis=1)

with open('assessment.dat','w') as f:
	pickle.dump(assessment, f)
f.close()
