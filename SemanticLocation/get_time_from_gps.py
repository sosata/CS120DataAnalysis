import csv
import math
import os
import numpy as np

def get_time_from_gps(path, time_now, time_prev, lat_report, lng_report):

    filename = path + '/fus.csv'
    t = []
    lat = []
    lng = []
    if os.path.isfile(filename):
        with open(filename) as file_in:
            data = csv.reader(file_in, delimiter='\t')
            for data_row in data:
                if data_row:
                    t.append(float(data_row[0]))
                    lat.append(float(data_row[1]))
                    lng.append(float(data_row[2]))
        file_in.close()
    else:
        print 'error: location file not found'
        return np.array([]), np.array([])

    # filtering gps data based on time
    dif = [abs(x-time_prev) for x in t]
    ind_start = dif.index(min(dif))
    dif = [abs(x-time_now) for x in t]
    ind_end = dif.index(min(dif))
    t = t[ind_start:ind_end]
    lat = lat[ind_start:ind_end]
    lng = lng[ind_start:ind_end]
    
    # filtering gps data based on location
    d = [math.sqrt((lat[i]-lat_report)**2+(lng[i]-lng_report)**2) for i in range(len(lat))]
    ind_within = [i for i in range(len(d)) if d[i]<.001]
    t = [t[i] for i in ind_within]
    #lat = [lat[i] for i in ind_within]
    #lng = [lng[i] for i in ind_within]

    if not t:
        print 'no data - instance skipped'
        return np.array([]), np.array([])

    # finding isolated t's
    inds = [i for i in range(len(t)-1) if t[i+1]-t[i]>600]
    t_end = []
    t_start = [t[0]]
    for i in range(len(inds)):
        t_end.append(t[inds[i]])
        t_start.append(t[inds[i]+1])
    t_end.append(t[len(t)-1])
    
    if not t:
        print 'no data - instance skipped'
        return np.array([]), np.array([])
        
    return t_start, t_end