import numpy as np
import pandas as pd
import scipy.stats as stats

def calculate_covariance(data):
    
    n = data.shape[1]

    data_cov = np.zeros([n, n])
    pval = np.zeros([n, n])

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
            # calculating p-value
            nn = np.sum(np.logical_and(np.logical_not(np.isnan(x)),np.logical_not(np.isnan(y))))
            tt = data_cov[i,j]*np.sqrt(nn-2)/np.sqrt(1-data_cov[i,j]**2)
            pval[i,j] = stats.t.sf(np.abs(tt), nn-1)*2

    return data_cov, pval

# This function stratifies over target classes (y) by oversampling
def stratify(x, y):
    
    xarr = np.array(x)
    yarr = np.array(y)

    n_max = max(np.histogram(yarr)[0])
    
    y_uniq = np.unique(yarr)
    y_out_class = [[] for i in range(y_uniq.size)]
    x_out_class = [[] for i in range(y_uniq.size)]
    for (i,y_u) in enumerate(y_uniq):
        inds = np.where(yarr==y_u)[0]
        y_class = yarr[inds]
        x_class = xarr[inds,:]
        inds = np.random.choice(np.arange(0,y_class.size), n_max, replace=True)
        y_out_class[i] = y_class[inds]
        x_out_class[i] = x_class[inds]
        
    yarr = np.concatenate(y_out_class)
    xarr = np.concatenate(x_out_class, axis=0)

    x = pd.DataFrame(xarr, columns=x.columns)
    y = pd.Series(yarr)

    return x,y

def one_hot_encoder(x, xset):

    y = np.zeros(xset.size)
    ind = np.where(xset==x)[0]
    y[ind] = 1.0
    return y

def get_top(xs, n):
    
    x_all = [x_ for x in xs for x_ in x]
    x_uniq = list(set(x_all))
    
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