%% This function calculates daily averages of mood variables and sleep duration and quality

clear;
close all;

save_results = true;

addpath('functions');

load('settings.mat');

cnt = 1;
for i = 1:length(subjects),
    
    fprintf('%d/%d\n',i,length(subjects));

    % loading data
    filename = [data_dir, subjects{i}, '\ems.csv'];
    if ~exist(filename, 'file'),
        disp(['No sleep data for ', subjects{i}]);
        continue;
    end
    data = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
    time_bed = data.Var2/1000 + time_zone*3600;
    time_sleep = data.Var3/1000 + time_zone*3600;
    time_wake = data.Var4/1000 + time_zone*3600;
    time_up = data.Var5/1000 + time_zone*3600;
    
    time_ems{cnt} = floor((data.Var1 + time_zone*3600)/86400-1)*86400;
    sleep_time{cnt} = mod(time_sleep, 86400);
    wake_time{cnt} = mod(time_wake, 86400);
    sleep_duration{cnt} = time_wake - time_sleep;
    bed_duration{cnt} = time_up - time_bed;
    sleep_quality{cnt} = data.Var6;
    
    subject_ems{cnt} = subjects{i};
    
    cnt = cnt+1;
    
end

if save_results,
    save('ems.mat', 'subject_ems', 'time_ems', 'sleep_duration', 'bed_duration', 'sleep_quality', 'sleep_time', 'wake_time');
end
