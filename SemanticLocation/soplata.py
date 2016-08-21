import matplotlib.pyplot as plt
import numpy as np

def plot_confusion_matrix(cm, labels, title='Correlation', cmap=plt.cm.RdYlGn):
    plt.figure(figsize=(12,12))
    plt.imshow(cm, interpolation='nearest', cmap=cmap, vmin=-1, vmax=1)
    plt.title(title)
    plt.colorbar()
    tick_marks = np.arange(len(labels))
    plt.xticks(tick_marks, labels, rotation=90)
    plt.yticks(tick_marks, labels)
    plt.tight_layout()