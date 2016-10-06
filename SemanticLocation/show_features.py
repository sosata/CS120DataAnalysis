
# coding: utf-8

# In[1]:

import os
import pickle
import pandas as pd
import numpy as np

ft_dir = 'features_long/'

# list feature files
files = os.listdir(ft_dir)
filename = files[0]

# reading top locations
with open('top_locations.dat') as f:
    location_top = pickle.load(f)
f.close()

with open(ft_dir+filename) as f:  
    feature, target = pickle.load(f)

    # only keeping top locations
    ind = np.array([], int)
    for (i,loc) in enumerate(target['location']):
        if loc in location_top:
            ind = np.append(ind, i)
    feature = feature.loc[ind,:]
    target = target.loc[ind]
    feature = feature.reset_index(drop=True)
    target = target.reset_index(drop=True)

f.close()
        


# In[1]:

from IPython.core.display import HTML, Javascript
from jinja2 import Template
import numpy as np
import json

points = np.array([[10,11,12,13],[10,10,10,10]])

pos = lambda x: {"lat": x[0], "lng": x[1]}
center = points.mean(axis=0)

html = Template("""
    <div id="heatmap" style="height: 500px" class="map-canvas"></div>
    <script>
        (function() {
            var map = new google.maps.Map(document.getElementById('heatmap'), {
                zoom: 4,
                center: {{center}},
            });
            var heatmap = new google.maps.visualization.HeatmapLayer({
                data: {{data}}.map(function(x) { return new google.maps.LatLng(x[0], x[1]); }),
                map: map
            });
            heatmap.set('radius', 30);
        })();
    </script>
""").render(
    center=json.dumps(pos(center)),
    data=json.dumps(points.tolist()),
)

HTML(html)

