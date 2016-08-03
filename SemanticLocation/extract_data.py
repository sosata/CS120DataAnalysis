
# coding: utf-8

# In[13]:

import csv
import os
import numpy as np
from get_data_at_location import get_data_at_location
from get_time_from_gps import get_time_from_gps
from sys import exit
import shutil

#probes = ['act','app','aud','bat','cal','coe','fus','lgt','run','scr','tch','wif','wtr']
probes = ['wtr']

data_dir = '/home/sohrob/Dropbox/Data/CS120/'
weather_data_dir = '/home/sohrob/Dropbox/Data/CS120Weather/'
out_dir = 'data/'

subjects = os.listdir(data_dir)
subjects[0] = ''
subjects[48] = ''
subjects[52] = ''
#48 skipped / this subject's eml.csv file contain lots of empty elements that should be removed
#52 as well
#subjects = subjects[148:]

for subj in subjects:
    filename = data_dir + subj + '/eml.csv'
    if os.path.exists(filename):
        print filename
        loc = []
        lat_report = []
        lng_report = []
        t_report = []
        with open(filename) as file_in:
            data = csv.reader(file_in, delimiter='\t')
            eml = []
            for data_row in data:
                if data_row:
                    # reading location category (state)
                    loc_string = data_row[6]
                    loc_string = loc_string[1:len(loc_string)-1]
                    loc_string.split(',')
                    loc.append(loc_string)
                    
                    # reading lat. and long.
                    lat_report.append(float(data_row[2]))
                    lng_report.append(float(data_row[3]))
                    t_report.append(float(data_row[0]))
                    
                    # adding to eml
                    eml.append(data_row)
                    
        file_in.close()
    else:
        print 'skipping subject '+subj+' without location report data.'
        continue
                       
    # looking into data between current and previous report
    filename = data_dir + subj + '/fus.csv'
    if os.path.exists(filename):
        with open(filename) as file_in:
            data_gps = csv.reader(file_in, delimiter='\t')
            t_gps = []
            lat_gps = []
            lng_gps = []
            for row_gps in data_gps:
                if row_gps:
                    t_gps.append(float(row_gps[0]))
                    lat_gps.append(float(row_gps[1]))
                    lng_gps.append(float(row_gps[2]))
        file_in.close()
    else:
        print 'skipping subject '+subj+' without location data.'
        continue

    #if os.path.exists(out_dir+subj): # commented out for writing only weather data
    #    shutil.rmtree(out_dir+subj)
    #    os.makedirs(out_dir+subj)
    #else:
    #    os.makedirs(out_dir+subj)
    
    t_prev = 0
    
    for (i,eml_row) in enumerate(eml):

        # finding t_start and t_end from gps data
        t_start, t_end = get_time_from_gps(data_dir+subj, t_report[i], t_prev, lat_report[i], lng_report[i])

        # creating a dir and writing the eml row # commented out for writing only weather data
        loc_dir = out_dir+subj+'/'+str(i)
        #if not os.path.exists(loc_dir):
        #    os.makedirs(loc_dir)
        #with open(loc_dir+'/'+'eml.csv','w') as f:
        #    fwriter = csv.writer(f, delimiter='\t', quotechar='|',quoting=csv.QUOTE_MINIMAL)
        #    fwriter.writerow(eml_row)
        #f.close()
        
        # if there is any clusters found, extract sensor data and put in a separate file
        if len(t_start)>0:
            for probe in probes:
                if probe=='wtr':
                    data = get_data_at_location(weather_data_dir+subj, t_start, t_end, probe)
                else:
                    data = get_data_at_location(data_dir+subj, t_start, t_end, probe)
                if len(data)>0:
                    with open(loc_dir+'/'+probe+'.csv', 'w') as f:
                        fwriter = csv.writer(f, delimiter='\t', quotechar='|',quoting=csv.QUOTE_MINIMAL)
                        for (j,d) in enumerate(data):
                            fwriter.writerow(d)
                    f.close()
        else:
            print 'instance '+str(i)+' skipped'

        if i<len(t_report)-1:
            if t_report[i]!=t_report[i+1]:
                t_prev = t_report[i]
                


# In[14]:

import numpy as np
from scipy import stats
x = stats.mode(np.array(['b']))
print type(x[0][0])

