import numpy as np
#from sklearn.metrics import roc_curve, auc
from sklearn.metrics import roc_auc_score
#from sklearn.preprocessing import label_binarize
from sklearn import preprocessing
from sklearn.preprocessing import OneHotEncoder


def calculate_confusion_matrix(y, y_t):

    if len(y)!=len(y_t):
        print('error: vectors must have the same length!')
        return []

    # convert strings to codes
    # defining codes based on the target
    le = preprocessing.LabelEncoder()
    le.fit(np.unique(np.append(y,y_t)))
    y_t_new = le.transform(y_t)
    y_new = le.transform(y)
    y_t = y_t_new
    y = y_new

    y_uniq = np.unique(y)
    y_t_uniq = np.unique(y_t)
    y_union = np.unique(np.append(y,y_t))
    n_class = y_union.size
    
    # classes to be removed
    # (which are not in the target)
    ind_out = np.array([])
    for (i,y_u) in enumerate(y_union):
        if not y_u in y_t_uniq:
            ind_out = np.append(ind_out, i)

    # confusion matrix
    conf = np.zeros((n_class, n_class))
    for (i,s) in enumerate(y_t):
        conf[s, y[i]] += 1

    # ROC curve
    enc = OneHotEncoder()
    enc.fit(y_union.reshape(-1, 1))
    y_bin = enc.transform(y.reshape(-1,1)).toarray()
    y_t_bin = enc.transform(y_t.reshape(-1,1)).toarray()
    
    #roc_auc = np.zeros(n_class)
    roc_auc = np.array([])
    for i in range(n_class):
        if i in ind_out:
            continue
        #print(np.sum(y_t_bin[:, i]))
        roc_auc = np.append(roc_auc, roc_auc_score(y_t_bin[:, i], y_bin[:, i]))
        #fpr, tpr, _ = roc_curve(y_t_bin[:, i], y_bin[:, i])
        #if fpr.size>=2:
        #    roc_auc = np.append(roc_auc, auc(fpr, tpr))
        #    #roc_auc[i] = auc(fpr, tpr)
        #else:
        #    roc_auc = np.append(roc_auc, np.nan)
        #    #roc_auc[i] = np.nan
        #    print('ROC AUC set to nan due to lack of data')

    # removing classes that are not in the target
    #roc_auc = np.delete(roc_auc, ind_out)
    conf = np.delete(conf, ind_out, axis=0)
    conf = np.delete(conf, ind_out, axis=1)
    
    #print str(roc_auc.size)+' '+str(conf.shape)

    return conf, roc_auc
