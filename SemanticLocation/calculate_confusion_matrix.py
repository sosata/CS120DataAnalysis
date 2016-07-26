import numpy as np
from sklearn.metrics import roc_curve, auc
#from sklearn.preprocessing import label_binarize
from sklearn import preprocessing
from sklearn.preprocessing import OneHotEncoder


def calculate_confusion_matrix(y, y_t):

	if len(y)!=len(y_t):
		print 'error: vectors must have the same length'
		return []

	# convert strings to codes
	# defining codes based on the target
	le = preprocessing.LabelEncoder()
	le.fit(np.append(y,y_t))
	y_t = le.transform(y_t)
	y = le.transform(y)

	y_uniq = np.unique(np.append(y,y_t))
	n_class = y_uniq.size

	# confusion matrix
	conf = np.zeros((n_class, n_class))
	for (i,s) in enumerate(y_t):
		conf[s, y[i]] += 1

	# ROC curve
	#y_bin = label_binarize(y, classes=range(n_class))
	#y_t_bin = label_binarize(y_t, classes=range(n_class))
	enc = OneHotEncoder()
	y_union = np.array(np.append(y,y_t))
	enc.fit(y_union.reshape(-1, 1))
	y_bin = enc.transform(y.reshape(-1,1)).toarray()
	y_t_bin = enc.transform(y_t.reshape(-1,1)).toarray()

	#print y_bin
	#print y_t_bin

	roc_auc = np.zeros(n_class)
	for i in range(n_class):
		fpr, tpr, _ = roc_curve(y_bin[:, i], y_t_bin[:, i])
		roc_auc[i] = auc(fpr, tpr)

	return conf, roc_auc
