
# coding: utf-8

# In[6]:

# extract top locations and reasons from feature files
import pandas as pd
import numpy as np

def get_top(xs, n):
    
    x_all = [x_ for x in xs for x_ in x]
    x_uniq = list(set(x_all))
    
    freq_subject = pd.DataFrame()
    for i in range(len(x_uniq)):
        for j in range(len(xs)):
            freq_subject.loc[i,j] = xs[j].count(x_uniq[i])/float(len(xs[j]))

    freq = list(np.array(np.mean(freq_subject,axis=0)))
    
    ind_sort = sorted(range(len(freq)), key=lambda k: freq[k], reverse=True)
    freq_sorted = [freq[i] for i in ind_sort]
    x_uniq_sorted = [x_uniq[i] for i in ind_sort]

    freq_top = freq_sorted[:n]
    x_top = x_uniq_sorted[:n]

    return x_top, freq_top


# In[7]:

# extract top locations
import os
import pickle

# TODO: deep dish instead of pickle

data_dir = 'features/'
files = os.listdir(data_dir)

reasons = []
locations = []
for (i,filename) in enumerate(files):
    with open(data_dir+filename) as f:
        feature, target = pickle.load(f)
    f.close()
    reasons.append(list(target['reason']))
    locations.append(list(target['location']))
    
loc_top, loc_freq = get_top(locations, 10)
# reason_top, reason_freq = get_top(reasons, 10)

# with open('top_locations.dat', 'w') as f:
#     pickle.dump(loc_top, f)
# f.close()
# with open('top_reasons.dat', 'w') as f:
#     pickle.dump(reason_top, f)
# f.close()


# In[8]:

loc_top


# In[4]:

print sorted(['socialize','dining'])

