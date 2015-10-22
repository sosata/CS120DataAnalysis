clear;
close all;

date_start = datenum(2015, 10, 19) - datenum(1970,1,1);
date_end = datenum(2015, 10, 20) - datenum(1970,1,1);

time_zone = -5;

timestamp_start = date_start*86400;
timestamp_end = (date_end+1)*86400;

gap_max = 2*3600;
gap_max_activity = 12*3600;

data_dir = 'C:\Data\CS120\';

addpath('.\functions\');

subjects_info = 'C:\Users\sst485\Dropbox\Code\Python\PG2CSV_CS120\subject_info_cs120.csv';

% finding start times

fid = fopen(subjects_info,'r');
subjects = textscan(fid, '%s%s','delimiter',';');
fclose(fid);
subjects = subjects{:,1};

timestamp_senddata = ones(1,length(subjects))*inf;
for i = 1:length(subjects),
    files = dir([data_dir, subjects{i}, '\*.csv']);
    if ~isempty(files),
        for j = 1:length(files),
            data = readtable([data_dir, subjects{i}, '\', files(j).name], 'delimiter', '\t', 'readvariablenames', false);
            start = data.Var1(1) + time_zone*3600;
            if timestamp_senddata(i) > start,
                timestamp_senddata(i) = start;
            end
        end
    end
end

date_senddata = zeros(size(timestamp_senddata));
for i = 1:length(timestamp_senddata),
    date_senddata(i) = floor(timestamp_senddata(i)/86400);
end

save('settings.mat', 'date_start', 'date_end', 'time_zone', 'data_dir' , 'subjects', 'timestamp_start', ...
    'timestamp_end', 'gap_max', 'gap_max_activity', 'timestamp_senddata', 'date_senddata');