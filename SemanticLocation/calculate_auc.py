# This function calculates the ROC curve AUC from predicted probabilities (y_p) and grond truth labels (y_t).
# Predicted labels (y) are used to calculate the confusion matrix.
# It assumes that y and y_t are integer codes from 0 to n_class-1

import numpy as np
from sklearn.metrics import roc_auc_score
from sklearn import preprocessing
from sklearn.preprocessing import OneHotEncoder

def calculate_auc(y, y_t, y_p, n_class):

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
    #y_bin = enc.transform(y.reshape(-1,1)).toarray()
    y_t_bin = enc.transform(y_t.reshape(-1,1)).toarray()
    
    roc_auc = np.zeros(n_class)
    for i in range(n_class):
        if np.sum(y_t_bin[:, i])>0:
            #roc_auc[i] = roc_auc_score(y_t_bin[:, i], y_bin[:, i])
            roc_auc[i] = roc_auc_score(y_t_bin[:, i], y_p[:, i])
        else:
            roc_auc[i] = np.nan

    return conf, roc_auc