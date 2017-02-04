
# coding: utf-8

# In[23]:

import pickle
import numpy as np

with open('accuracy_personal.dat') as f:
    aucs, confs, labels = pickle.load(f)
f.close()

auc = np.array([])
auc_home = np.array([])
for (i,a) in enumerate(aucs):
    auc = np.append(auc, np.nanmean(a))
    ind_home = np.where(labels[i]=='Home')
    auc_home = np.append(auc_home, a[ind_home])

# removing nans
auc = auc[~np.isnan(auc)]
auc_home = auc_home[~np.isnan(auc_home)]


# In[28]:

import matplotlib.pyplot as plt
get_ipython().magic(u'matplotlib inline')
plt.figure(figsize=(12,5))
n, bins, patches = plt.hist(auc, 20, normed=0, facecolor='green', alpha=0.75)
plt.title('Mean AUC over all categories across the subjects')
plt.xlabel('AUC',fontsize=15)
plt.ylabel('number of subjects',fontsize=15)
plt.plot([np.mean(auc), np.mean(auc)], [0, 25],color=(0,0,0),linestyle='--')
axes = plt.gca()
axes.set_xlim([0, 1])
print np.mean(auc)


# In[29]:

import matplotlib.pyplot as plt
get_ipython().magic(u'matplotlib inline')
plt.figure(figsize=(12,5))
n, bins, patches = plt.hist(auc_home, 20, normed=0, facecolor='green', alpha=0.75)
plt.title('Home detection AUC across subjects')
plt.xlabel('AUC',fontsize=15)
plt.ylabel('number of subjects',fontsize=15)
plt.plot([np.mean(auc_home), np.mean(auc_home)], [0, 40],color=(0,0,0),linestyle='--')
axes = plt.gca()
axes.set_xlim([0, 1])
print np.mean(auc_home)

