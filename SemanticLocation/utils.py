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

            #             print data[:,i].shape
#             print type(data[:,i])
#             datai = np.ma.masked_array(data[:,i],np.isnan(data[:,i]))
#             dataj = np.ma.masked_array(data[:,j],np.isnan(data[:,j]))
#             aa = np.ma.corrcoef(datai,dataj)
#             data_cov[i,j] = aa[0,1]
            
    return data_cov