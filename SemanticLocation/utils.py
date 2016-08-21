import numpy as np

def calculate_covariance(data):
    
    n = data.shape[1]

    data_cov = np.zeros([n, n])
    mean = np.zeros(n)
    std = np.zeros(n)
    for i in range(n):
        mean[i] = np.nanmean(data[:,i])
        std[i] = np.sqrt(np.nanvar(data[:,i]))

    for i in range(n):
        x = data[:,i]
        for j in range(n):
            y = data[:,j]
            data_cov[i,j] = np.nanmean(np.multiply((x-mean[i]),(y-mean[j])))/(std[i]*std[j])

    return data_cov

def stratify(x, y):
    
    import collections as col
    counts = col.Counter(y)
    n_max = np.max(counts.values())
    
    y_uniq = np.unique(y)
    y_out_class = [[] for i in range(y_uniq.size)]
    x_out_class = [[] for i in range(y_uniq.size)]
    for (i,y_u) in enumerate(y_uniq):
        inds = y==y_u
        y_class = y[inds]
        x_class = x[inds,:]
        inds = np.random.choice(np.arange(0,y_class.size), n_max, replace=True)
        y_out_class[i] = y_class[inds]
        x_out_class[i] = x_class[inds]
        
    y = np.concatenate(y_out_class)
    x = np.concatenate(x_out_class, axis=0)
    
    return x,y