import numpy as np
import pandas as pd

def resample(x, n):
	if x.shape[0]==n:
		return x
	if x.shape[0]>n:
		ind = np.random.choice(np.arange(x.shape[0]), size=n, replace=False)
		return x.loc[ind,:]
	else:
		y = x
		for i in range(n/x.shape[0] - 1):
			y = pd.concat([y,x],axis=0,ignore_index=True)
		ind = np.random.choice(np.arange(x.shape[0]), size=np.mod(n,x.shape[0]), replace=False)
		return pd.concat([y, x.loc[ind,:]], axis=0, ignore_index=True)

def split_binary(x, y, split, oversample=True):

	x0 = x.loc[y==0,:]
	x1 = x.loc[y==1,:]

	if oversample:
		n_class = max([x0.shape[0], x1.shape[0]])
	else:
		n_class = min([x0.shape[0], x1.shape[0]])

	x0 = resample(x0, n_class)
	x1 = resample(x1, n_class)

	n_train_class = np.round(n_class*split)

	print x0.shape
	print x1.shape

	x0_train = x0.loc[:n_train_class]
	x0_test = x0.loc[n_train_class:]
	x1_train = x1.loc[:n_train_class]
	x1_test = x1.loc[n_train_class:]

	x_train = pd.concat([x0_train, x1_train], axis=0, ignore_index=True)
	y_train = pd.concat([pd.DataFrame(0,index=np.arange(x0_train.shape[0]),columns=y.columns),\
		pd.DataFrame(1,index=np.arange(x1_train.shape[0]),columns=y.columns)],axis=0,ignore_index=True)
	x_test = pd.concat([x0_test, x1_test], axis=0, ignore_index=True)
	y_test = pd.concat([pd.DataFrame(0,index=np.arange(x0_test.shape[0]),columns=y.columns),\
		pd.DataFrame(1,index=np.arange(x1_test.shape[0]),columns=y.columns)],axis=0,ignore_index=True)

	return x_train, y_train, x_test, y_test