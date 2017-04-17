
# coding: utf-8

# In[1]:

import pickle

with open('assessment.dat') as f:
    ass = pickle.load(f)


# In[47]:

import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np

a_noise = .2
msize= 5

np.random.seed(seed=866)

get_ipython().magic(u'matplotlib inline')
plt.figure(figsize=[6,6])
plt.plot([10,10],[-1,25],color=(.3,.8,.3))
plt.plot([-1,25],[10,10],color=(.3,.8,.3))
# cmap = cm.hsv(np.arange(ass.shape[0]))
plt.plot(ass['PHQ9 W0']+a_noise*np.random.randn(ass.shape[0]),ass['GAD7 W0']+a_noise*np.random.randn(ass.shape[0]),'.', color=(0,0,0), markersize=msize)
plt.plot(ass['PHQ9 W3']+a_noise*np.random.randn(ass.shape[0]),ass['GAD7 W3']+a_noise*np.random.randn(ass.shape[0]),'.', color=(0,0,0), markersize=msize)
plt.plot(ass['PHQ9 W6']+a_noise*np.random.randn(ass.shape[0]),ass['GAD7 W6']+a_noise*np.random.randn(ass.shape[0]),'.', color=(0,0,0), markersize=msize)
plt.xlabel('Depression (PHQ-9)')
plt.ylabel('Anxiety(GAD-7)')
plt.xlim([-1,25])
plt.ylim([-1,25])


# In[43]:

np.random.randn(10,2)


# In[2]:

plt.figure(figsize=[6,6])
plt.plot([10,10],[-1,25],color=(.3,.8,.3))
plt.plot([-1,25],[10,10],color=(.3,.8,.3))
# cmap = cm.hsv(np.arange(ass.shape[0]))
for i in range(ass.shape[0]):
    plt.plot(np.nanmean(ass.loc[i,['PHQ9 W0','PHQ9 W3','PHQ9 W6']]),np.nanmean(ass.loc[i,['GAD7 W0','GAD7 W3','GAD7 W6']]),'.', color=(0,0,0))
plt.xlabel('Depression (PHQ-9)')
plt.ylabel('Anxiety(GAD-7)')
plt.xlim([-1,25])
plt.ylim([-1,25])


# In[45]:

plt.figure(figsize=[6,6])
plt.plot([10,10],[-1,25],color=(.3,.8,.3))
plt.plot([-1,25],[10,10],color=(.3,.8,.3))
# cmap = cm.hsv(np.arange(ass.shape[0]))
noise_phq = a_noise*np.random.randn(ass.shape[0],3)
noise_gad = a_noise*np.random.randn(ass.shape[0],3)
for i in range(ass.shape[0]):
    plt.plot(ass.loc[i,['PHQ9 W0','PHQ9 W3','PHQ9 W6']]+noise_phq[i,:],             ass.loc[i,['GAD7 W0','GAD7 W3','GAD7 W6']]+noise_gad[i,:],lw=.5,color=(0,0,0))
    plt.plot(ass.loc[i,'PHQ9 W0']+noise_phq[i,0],ass.loc[i,'GAD7 W0']+noise_gad[i,0],'.',color=(0,0,0))
plt.xlabel('Depression (PHQ-9)')
plt.ylabel('Anxiety(GAD-7)')
plt.xlim([-1,25])
plt.ylim([-1,25])


# In[91]:

a_noise = .2
plt.figure(figsize=[6,6])
plt.plot([10,10],[-1,25],color=(.3,.6,.3),linestyle='-')
plt.plot([-1,25],[10,10],color=(.3,.6,.3),linestyle='-')
noise_phq = a_noise*np.random.randn(ass.shape[0],2)
noise_gad = a_noise*np.random.randn(ass.shape[0],2)
ax = plt.axes()
for i in range(ass.shape[0]):
    ax.arrow(ass.loc[i,'PHQ9 W0']+a_noise*np.random.randn(),             ass.loc[i,'GAD7 W0']+a_noise*np.random.randn(),             ass.loc[i,'PHQ9 W6']-ass.loc[i,'PHQ9 W0']+a_noise*np.random.randn(),             ass.loc[i,'GAD7 W6']-ass.loc[i,'GAD7 W0']+a_noise*np.random.randn(), head_width=0.35, head_length=.6, fc='k', ec='k',             alpha=.8, linewidth=.25)
plt.xlabel('Depression (PHQ-9)')
plt.ylabel('Anxiety(GAD-7)')
plt.xlim([-1,25])
plt.ylim([-1,25])


# In[55]:

ass.loc[i,'PHQ9 W0']+a_noise*np.random.randn()


# In[24]:

step = 1
n_max = 7
edges = np.arange(0, 25, step)
cent = np.arange(step/2.0, 25, step)

plt.figure(figsize=[10,10])
plt.subplot(2,2,1)
plt.plot([10,10],[0,25],color=(0,.5,0))
plt.plot([0,25],[10,10],color=(0,.5,0))
hst = np.histogram2d(np.array(ass['PHQ9 W0'],dtype=float), np.array(ass['GAD7 W0'],dtype=float), bins=[edges,edges])
plt.imshow(hst[0], origin='lower', vmin=0, vmax=n_max, interpolation='none', cmap=cm.afmhot, extent=(edges[0], edges[-1], edges[0], edges[-1]))
plt.colorbar()
plt.xlabel('Depression (PHQ-9)')
plt.ylabel('Anxiety(GAD-7)')

plt.subplot(2,2,2)
plt.plot([10,10],[0,25],color=(0,.5,0))
plt.plot([0,25],[10,10],color=(0,.5,0))
hst = np.histogram2d(np.array(ass['PHQ9 W3'],dtype=float), np.array(ass['GAD7 W3'],dtype=float), bins=[edges,edges])
plt.imshow(hst[0], origin='lower', vmin=0, vmax=n_max, interpolation='none', cmap=cm.afmhot, extent=(edges[0], edges[-1], edges[0], edges[-1]))
plt.colorbar()
plt.xlabel('Depression (PHQ-9)')
plt.ylabel('Anxiety(GAD-7)')

plt.subplot(2,2,3)
plt.plot([10,10],[0,25],color=(0,.5,0))
plt.plot([0,25],[10,10],color=(0,.5,0))
hst = np.histogram2d(np.array(ass['PHQ9 W6'],dtype=float), np.array(ass['GAD7 W6'],dtype=float), bins=[edges,edges])
plt.imshow(hst[0], origin='lower', vmin=0, vmax=n_max, interpolation='none', cmap=cm.afmhot, extent=(edges[0], edges[-1], edges[0], edges[-1]))
plt.colorbar()
plt.xlabel('Depression (PHQ-9)')
plt.ylabel('Anxiety(GAD-7)')


# In[23]:

step = 1
n_max = 7
edges = np.arange(0, 25, step)
cent = np.arange(step/2.0, 25, step)

plt.figure(figsize=[5,5])
plt.plot([10,10],[0,25],color=(0,.5,0))
plt.plot([0,25],[10,10],color=(0,.5,0))
hst = np.histogram2d(np.array(np.mean(ass[['PHQ9 W0','PHQ9 W3', 'PHQ9 W6']],axis=1)),                      np.array(np.mean(ass[['GAD7 W0','GAD7 W3', 'GAD7 W6']],axis=1)), bins=[edges,edges])
plt.imshow(hst[0], origin='lower', vmin=0, vmax=n_max, interpolation='none', cmap=cm.afmhot,            extent=(edges[0], edges[-1], edges[0], edges[-1]))
plt.colorbar()
plt.xlabel('Mean Depression (PHQ-9)')
plt.ylabel('Mean Anxiety(GAD-7)')
plt.title('number of participants')

