import numpy as np
from sklearn.metrics import roc_curve, auc
from sklearn.preprocessing import label_binarize

def calculate_confusion_matrix(y, y_t):

	if len(y)!=len(y_t):
		print 'error: vectors must have the same length'
		return []

	n_class = np.max(y_t)+1

	# confusion matrix
	conf = np.zeros((n_class, n_class))
	for (i,s) in enumerate(y_t):
		conf[s, y[i]] += 1

	# ROC curve
	y_bin = label_binarize(y, classes=range(n_class))
	y_t_bin = label_binarize(y_t, classes=range(n_class))
	roc_auc = np.zeros(n_class)
	for i in range(n_class):
		fpr, tpr, _ = roc_curve(y_bin[:, i], y_t_bin[:, i])
		roc_auc[i] = auc(fpr, tpr)

	return conf, roc_auc
