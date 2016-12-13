
# coding: utf-8

# In[6]:

# loading gps locations (at the time of recruitment)
import os
import pandas as pd
import numpy as np

data_dir = '/home/sohrob/Dropbox/Data/CS120/'
dirs = os.listdir(data_dir)

lat = np.array([])
lng = np.array([])
ids = np.array([])
for i, d in enumerate(dirs):
    filename = data_dir + d + '/fus.csv'
    if os.path.exists(filename):
        data = pd.read_csv(filename,sep='\t',header=None)
        lat = np.append(lat, data.loc[0,1])
        lng = np.append(lng, data.loc[0,2])
        ids = np.append(ids, d)


# In[50]:

from bokeh.io import output_file, show
from bokeh.models import (
  GMapPlot, GMapOptions, ColumnDataSource, Circle, DataRange1d, PanTool, WheelZoomTool, BoxSelectTool, HoverTool, SaveTool
)
import collections
# import matplotlib.pyplot as plt
get_ipython().magic(u'matplotlib inline')

GMapPlot()

map_options = GMapOptions(lat=40, lng=-100, map_type="roadmap", zoom=4)

plot = GMapPlot(
    x_range=DataRange1d(), y_range=DataRange1d(), map_options=map_options, api_key='AIzaSyCBh8Nf-bojFno9AQyXUX48MjNcvRdL5oE',
    plot_height = 800, plot_width = 1500
)
plot.title.text = "United States"

source = ColumnDataSource(
    data=dict(
        lat=lat+0.01*np.random.normal(size=lat.size),
        lon=lng+0.01*np.random.normal(size=lng.size),
        ids=ids,
    )
)
circle = Circle(x="lon", y="lat", size=5, fill_color=(150,0,0), fill_alpha=1, line_color=None)
plot.add_glyph(source, circle)

hover = HoverTool()
hover.tooltips = collections.OrderedDict([
        ("ID", "@ids"),
        ])

plot.add_tools(hover, PanTool(), WheelZoomTool(), BoxSelectTool(), SaveTool())
output_file("gmap_plot.html", mode='inline')


show(plot) # opens a browser


# In[32]:

np.random.normal()

