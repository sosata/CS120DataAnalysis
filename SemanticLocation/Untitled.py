
# coding: utf-8

# In[28]:

from ipyparallel import Client

rc = Client()
dv = rc[:]

@dv.parallel(block = True)
def func(x):
    import time
    return x, time.time()


# In[27]:

func(range(48))

