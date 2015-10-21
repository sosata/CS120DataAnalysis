clear;
close all;

date_start = datenum(2015, 10, 15) - datenum(1970,1,1);
date_end = datenum(2015, 10, 20) - datenum(1970,1,1);

time_zone = -5;

timestamp_start = date_start*86400;
timestamp_end = (date_end+1)*86400;

gap_max = 7200;

data_dir = 'C:\Data\CS120\';

addpath('.\functions\');

subjects_info = 'C:\Users\sst485\Dropbox\Code\Python\PG2CSV_CS120\subject_info_cs120.csv';

save('settings.mat', 'date_start', 'date_end', 'time_zone', 'data_dir' , 'subjects_info', 'timestamp_start', 'timestamp_end', 'gap_max');