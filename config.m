clear;
close all;

extract_time_senddata = false;

date_start = datenum(2015, 10, 28) - datenum(1970,1,1);
date_end = datenum(2016, 1, 25) - datenum(1970,1,1);

time_zone = -5;

timestamp_start = date_start*86400;
timestamp_end = (date_end+1)*86400;

gap_max = 1*3600;
gap_max_activity = 10*3600;
gap_max_wifi = 10*3600;

% data_dir = 'C:\Data\CS120\';
% data_dir = 'C:\Users\Sohrob\Dropbox\Data\CS120\';
% data_dir = '~/Dropbox/Data/CS120/';
data_dir = 'C:\Users\cbits\Dropbox\Data\CS120\';

addpath('functions');

% subjects_info = 'C:\Users\sst485\Dropbox\Code\Python\PG2CSV_CS120\subject_info_cs120.csv';
% subjects_info = 'C:\Users\Sohrob\Dropbox\Code\Python\PG2CSV_CS120\subject_info_cs120.csv';
% subjects_info = '~/Dropbox/Code/Python/PG2CSV_CS120/subject_info_cs120.csv';
subjects_info = 'C:\Users\cbits\Dropbox\Code\Python\PG2CSV_CS120\subject_info_cs120.csv';

% finding start times

fid = fopen(subjects_info,'r');
subjects = textscan(fid, '%s%s','delimiter',';');
fclose(fid);
subjects = subjects{:,1};

%%%%%%%%%%%%%%%%%% due to a problem with this subject's app data %%%%%%%%
subjects(127) = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save('settings.mat', 'date_start', 'date_end', 'time_zone', 'data_dir' , 'subjects', 'timestamp_start', ...
    'timestamp_end', 'gap_max', 'gap_max_activity', 'gap_max_wifi');

if extract_time_senddata,
    
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
    
    save('time_senddata.mat', 'timestamp_senddata', 'date_senddata');
    
end