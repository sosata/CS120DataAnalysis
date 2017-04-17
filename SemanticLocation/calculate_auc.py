# This code assumes that output variables are encoded, from 0 to nclass-1

import numpy as np
from sklearn.metrics import roc_curve, auc
from sklearn.metrics import roc_auc_score
#from sklearn.preprocessing import label_binarize
from sklearn import preprocessing
from sklearn.preprocessing import OneHotEncoder


def calculate_auc(y, y_t, n_class):

    y = np.array(y)
    y_t = np.array(y_t)

    if y.size!=y_t.size:
        print('error: vectors must have the same length!')
        return []

    # confusion matrix
    conf = np.zeros((n_class, n_class))
    for (i,s) in enumerate(y_t):
        conf[s, y[i]] += 1

    # binarizing
    enc = OneHotEncoder()
    enc.fit(np.arange(0,n_class).reshape(-1, 1))
    y_bin = enc.transform(y.reshape(-1,1)).toarray()
    y_t_bin = enc.transform(y_t.reshape(-1,1)).toarray()
    
    roc_auc = np.zeros(n_class)
    for i in range(n_class):
        #if np.sum(y_t_bin[:,i])>=2:
            #roc_auc = np.append(roc_auc, roc_auc_score(y_bin[:, i], y_t_bin[:, i])) #incorrect
        if np.sum(y_t_bin[:, i])>0:
            roc_auc[i] = roc_auc_score(y_t_bin[:, i], y_bin[:, i]) #correct
        else:
            roc_auc[i] = np.nan

    return conf, roc_auc