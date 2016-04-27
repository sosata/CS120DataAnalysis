clear;
close all;

runtype = 'all'; %'all','weekend','weekday','workday','offday'

disp(['run type: ', runtype]);

save_results = true;
remove_duplicates = true;

load('../settings');
addpath('../features');
addpath('../functions');
clear date_start date_end timestamp_start;

% weather_dir = 'C:\Users\Sohrob\Dropbox\Data\CS120Weather\';
weather_dir = '~/Dropbox/Data/CS120Weather/';

probes = {'act', 'app', 'aud', 'bat', 'cal', 'coe', 'fus', 'lgt', 'scr', 'tch', 'wif', 'wtr', 'emc', 'eml', 'emm', 'ems'};
probes_remove_duplicate = {'fus'};  % probes for which duplicate timestamps data are removed

win_size = 14;
win_shift_size = 7;

% start and end time will be determined by the affect self-report data
cnt = 1;
for i = 1:length(subjects),
    filename = [data_dir, subjects{i}, '/', 'emm.csv'];
    if ~exist(filename, 'file'),
        disp(['No mood data for ', subjects{i}]);
        continue;
    end
    tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
    day_start(cnt) = floor(tab.Var1(1)/86400);
    day_end(cnt) = floor(tab.Var1(end)/86400);
    subjects_new{cnt} = subjects{i};
    cnt=cnt+1;
end

if length(subjects_new)~=length(subjects),
    fprintf('%d subject(s) removed because they did not have mood data\n', length(subjects)-length(subjects_new));
    subjects = subjects_new;
    clear subjects_new;
end

% reading data and extracting features
fprintf('reading data...\n');
feature = cell(length(subjects),1);
feature_label = cell(length(subjects),1);

parfor i = 1:length(subjects),
    
    fprintf('%d/%d\n',i,length(subjects));

    % loading data
    data = [];
    for j = 1:length(probes),
        if strcmp(probes{j},'wtr'),
            filename = [weather_dir, subjects{i}, '/',probes{j},'.csv'];
        else
            filename = [data_dir, subjects{i}, '/',probes{j},'.csv'];
        end
        if ~exist(filename, 'file'),
            disp(['No ',probes{j},' data for ', subjects{i}]);
            data.(probes{j}) = [];
        else
            tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
            if isempty(tab),
                data.(probes{j}) = [];
            else
                
                data.(probes{j}) = tab;
                data.(probes{j}).Var1 = data.(probes{j}).Var1 + time_zone*3600;
                
                if remove_duplicates&&sum(strcmp(probes_remove_duplicate,probes{j})),
                    ind = find(diff(data.(probes{j}).Var1)==0)+1;
                    data.(probes{j})(ind,:) = [];
                end
                
                % separating weekend and weekday data
                if strcmp(runtype, 'weekend'),
                    [~, data.(probes{j}), ~] = separate_day_type(data.(probes{j}));
                elseif strcmp(runtype, 'weekday'),
                    [data.(probes{j}), ~, ~] = separate_day_type(data.(probes{j}));
                    
                end
                
            end
        end
        
        
    end
    
    % separating work/off days out
    if strcmp(runtype, 'offday')||strcmp(runtype, 'workday'),
        if isempty(data.ems.Var1),
            fprintf('No workday (sleep) report data. Skipping subject.\n');
            for j = 1:length(probes),
                data.(probes{j}) = [];
            end
        else
            day_type = [];
            day_type.time = data.ems.Var1;
            day_type.type = categorical(data.ems.Var7);
            for j = 1:length(probes),
                if strcmp(runtype, 'offday'),
                    [~, data.(probes{j})] = separate_workday(data.(probes{j}), day_type);
                elseif strcmp(runtype, 'workday'),
                    [data.(probes{j}), ~] = separate_workday(data.(probes{j}), day_type);
                end
            end
        end
    end
    
    
    % bi-weekly windows
    day_range = day_start(i):win_shift_size:day_end(i);
    for d=day_range,
        
        % clipping data
        datac = [];
        for j = 1:length(probes),
            if isempty(data.(probes{j})),
                datac.(probes{j}) = [];
            else
                datac.(probes{j}) = clip_data(data.(probes{j}), d*86400, (d+win_size)*86400);
            end
        end
        
        % extracting features
        
        [ft, ft_lab] = extract_features_location(datac.fus);
        feature_win = ft;
        feature_win_lab = ft_lab;
        
        [ft, ft_lab] = extract_features_usage(datac.scr, 30, Inf);
        feature_win = [feature_win, ft];
        feature_win_lab = [feature_win_lab, ft_lab];
        
        [ft, ft_lab] = extract_features_weather(datac.wtr);
        feature_win = [feature_win, ft];
        feature_win_lab = [feature_win_lab, ft_lab];

        [ft, ft_lab] = extract_features_activity(datac.act);
        feature_win = [feature_win, ft];
        feature_win_lab = [feature_win_lab, ft_lab];
        
        [ft, ft_lab] = extract_features_communication(datac.coe);
        feature_win = [feature_win, ft];
        feature_win_lab = [feature_win_lab, ft_lab];
        
        [ft, ft_lab] = extract_features_audio(datac.aud);
        feature_win = [feature_win, ft];
        feature_win_lab = [feature_win_lab, ft_lab];

        [ft, ft_lab] = extract_features_light(datac.lgt);
        feature_win = [feature_win, ft];
        feature_win_lab = [feature_win_lab, ft_lab];
        
        [ft, ft_lab] = extract_features_app(datac.app);
        feature_win = [feature_win, ft];
        feature_win_lab = [feature_win_lab, ft_lab];

%         [ft, ft_lab] = extract_features_affect(datac.emm);
%         feature_win = [feature_win, ft];
%         feature_win_lab = [feature_win_lab, ft_lab];
        
        [ft, ft_lab] = extract_features_sleep(datac.ems);
        feature_win = [feature_win, ft];
        feature_win_lab = [feature_win_lab, ft_lab];

%         [ft, ft_lab] = extract_features_locationreport(datac.eml);
%         feature_win = [feature_win, ft];
%         feature_win_lab = [feature_win_lab, ft_lab];

        % adding all features to the main feature vector
        feature{i} = [feature{i}; feature_win];
        feature_label{i} = feature_win_lab;
        
    end
    
end

if save_results,
    feature_label = feature_label{1};
    subject_feature = subjects;
    save(sprintf('features_biweekly_%s.mat',runtype), 'feature', 'feature_label', 'subject_feature');
end