from sklearn import preprocessing
import numpy as np

def split_balanced(x, y, split):

    le = preprocessing.LabelEncoder()
    le.fit(y)
    y_code = le.transform(y)
    y_uniq = np.unique(y_code)
    
    x_train = np.array([])
    y_train = np.array([])
    x_test = np.array([])
    y_test = np.array([])


    for (i,s) in enumerate(y_uniq):

        inds = np.where(y_code==s)[0]
    
        ind_split = np.floor(inds.size*split)
        
        ind_train = inds[0:ind_split]
        ind_test = inds[ind_split:]
        
        y_train = np.append(y_train, y[ind_train])
        y_test = np.append(y_test, y[ind_test])

        if x_train.size==0:
            x_train = np.array(x[ind_train,:])
        else:
            x_train = np.append(x_train, x[ind_train,:], axis=0)

        if x_test.size==0:
            x_test = np.array(x[ind_test,:])
        else:
            x_test = np.append(x_test, x[ind_test,:], axis=0)

    return x_train, y_train, x_test, y_test