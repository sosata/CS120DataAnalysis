import matplotlib.pyplot as plt
import numpy as np

def onpick3(event):
    ind = event.ind
    print 'hello'
    #print 'onpick3 scatter:', ind, npy.take(x, ind), npy.take(y, ind)

def plot_confusion_matrix(cm, labels, title='Correlation', cmap=plt.cm.seismic, xsize=12, ysize=12):

    fig = plt.figure(figsize=(xsize,ysize))
    plt.imshow(cm, interpolation='nearest', cmap=cmap, vmin=-1, vmax=1, picker=True)
    plt.title(title)
    plt.colorbar()
    tick_marks = np.arange(len(labels))
    plt.xticks(tick_marks, labels, rotation=90)
    plt.yticks(tick_marks, labels)
    plt.tight_layout()

    # fig.canvas.mpl_connect('pick_event', onpick3)

    # plt.show()
