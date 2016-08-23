
# coding: utf-8

# In[1]:

# extract top locations and reasons from feature files

def get_top(xs, n):
    
    x_all = [x_ for x in xs for x_ in x]
    x_uniq = list(set(x_all))
    
    print x_uniq
    
    freq = []
    for i in range(len(x_uniq)):
        freq.append(0)
        for j in range(len(xs)):
            if x_uniq[i] in xs[j]:
                freq[i] += 1

    ind_sort = sorted(range(len(freq)), key=lambda k: freq[k], reverse=True)
    freq_sorted = [freq[i] for i in ind_sort]
    x_uniq_sorted = [x_uniq[i] for i in ind_sort]

    freq_top = freq_sorted[:n]
    x_top = x_uniq_sorted[:n]

    return x_top, freq_top


# In[2]:

# extract top locations
import os
import pickle

data_dir = 'features/'
files = os.listdir(data_dir)

reasons = []
locations = []
for (i,filename) in enumerate(files):
#     print i,
    with open(data_dir+filename) as f:
        feature, target = pickle.load(f)
    f.close()

    reasons.append(list(target['reason']))
    locations.append(list(target['location']))
        
loc_top, loc_freq = get_top(locations, 10)
reason_top, reason_freq = get_top(reasons, 10)

with open('top_locations.dat','w') as f:
    pickle.dump(loc_top, f)
f.close()
with open('top_reaons.dat','w') as f:
    pickle.dump(reason_top, f)
f.close()


# In[3]:

print loc_top
print loc_freq
print reason_top
print reason_freq


# In[4]:

print sorted(['socialize','dining'])

