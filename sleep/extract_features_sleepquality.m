clear;
close all;

extract_workday = false;

addpath('../functions');
addpath('../features');

load('../settings.mat');

% demo data


probes = {'ems','fus','lgt','aud','act','scr','bat','wif','coe','app'};

save_results = true;

% remove subjects with no sleep data
subjects_new = {};
for i = 1:length(subjects),
    filename = [data_dir, subjects{i}, '/ems.csv'];
    if ~exist(filename, 'file'),
        fprintf('No sleep data for %s. Subject removed from analysis.\n', subjects{i});
    else
        subjects_new = [subjects_new, subjects{i}];
    end
end
subjects = subjects_new;
clear subjects_new;

feature = cell(length(subjects),1);
state = cell(length(subjects),1);
feature_label = [];

parfor i = 1:length(subjects),
    
    fprintf('%d/%d\n', i, length(subjects));
    
    % loading data
    data = [];
    for p = 1:length(probes),
        filename = [data_dir, subjects{i}, '/', probes{p}, '.csv'];
        if ~exist(filename, 'file'),
            fprintf('No %s data for %s\n', probes{p}, subjects{i});
            if strcmp(probes{p},'act'),
                data.(probes{p}) = table([],[],[],'VariableNames',{'Var1','Var2','Var3'});
            else
                data.(probes{p}) = table([],{},[],'VariableNames',{'Var1','Var2','Var3'});
            end
        else
            data.(probes{p}) = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
            data.(probes{p}).Var1 = data.(probes{p}).Var1 + time_zone*3600;
        end
    end
    
    % adapting time zone (times are in ms)
    time_bed = data.ems.Var2/1000 + time_zone*3600;
    time_sleep = data.ems.Var3/1000 + time_zone*3600;
    time_wake = data.ems.Var4/1000 + time_zone*3600;
    time_up = data.ems.Var5/1000 + time_zone*3600;
    sleep_quality = data.ems.Var6;
    
    if extract_workday,
        workday = categorical(data.ems.Var7);
        workday_new = zeros(length(workday),1);
        workday_new(workday=='off') = 0;
        workday_new(workday=='partial') = 1;
        workday_new(workday=='normal') = 2;
        workday = workday_new;
    end
    
    for j = 1:length(sleep_quality),
        
        datasleep = [];
        for p = 1:length(probes),
            datasleep.(probes{p}) = clip_data(data.(probes{p}), time_sleep(j), time_wake(j));
        end
        datasleep.ems = table(0, time_bed(j), time_sleep(j), time_wake(j), time_up(j), sleep_quality(j),...
            'variablenames',{'Var1','Var2','Var3','Var4','Var5','Var6'});
        
        [ft, ft_label] = extract_features_slinter(datasleep);
        feature{i} = [feature{i}; ft];
        state{i} = [state{i}; sleep_quality(j)];
        
    end
    
    feature_label = ft_label;
    
end

if save_results,
    if extract_workday,
        save('features_sleepquality_workday.mat', 'feature', 'state', 'feature_label');
    else
        save('features_sleepquality.mat', 'feature', 'state', 'feature_label');
    end
end
