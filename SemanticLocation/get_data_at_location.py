import csv
import math
import os
import numpy as np

def get_data_at_location(path, t_start, t_end, sensor_name):

    filename = path + '/' + sensor_name + '.csv'
    if os.path.isfile(filename):
        with open(filename) as file_in:
            data = csv.reader(file_in, delimiter='\t')
            data_value = []
            for data_row in data:
                if data_row:
                    for i in range(len(t_start)):
                        if (float(data_row[0])>=t_start[i])and(float(data_row[0])<=t_end[i]):
                            #print 'data added'
                            data_value.append(data_row)
        file_in.close()
    else:
        print('warning: sensor '+sensor_name+' not found.')
        return []

    return data_value