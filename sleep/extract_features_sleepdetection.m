clear;
close all;

addpath('../functions');
addpath('../features');
load('../settings.mat');

probes = {'ems','fus','lgt','aud','act','scr','bat','wif'};

window_awake = 6*3600;  % time window before sleep and after wake to be considered as awake
window_sensor = 10*60;
overlap = 0;

save_results = true;

% cnt = 1;
feature = cell(length(subjects),1);
state = cell(length(subjects),1);

parfor i = 1:length(subjects),
    
    fprintf('%d/%d\n', i, length(subjects));
    
    % skip subject if there is no sleep data
    filename = [data_dir, subjects{i}, '/ems.csv'];
    if ~exist(filename, 'file'),
        disp(['No sleep data for ', subjects{i}]);
        continue;
    end
    
    % loading data
    %     empty_probe = false;
    data = [];
    for p = 1:length(probes),
        filename = [data_dir, subjects{i}, '/', probes{p}, '.csv'];
        if ~exist(filename, 'file'),
            disp(['No ', probes{p}, ' data for ', subjects{i}]);
            data.(probes{p}) = [];
            %             empty_probe = true;
            %             continue;
        else
            data.(probes{p}) = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
            % correcting timestamps for the time zone
            data.(probes{p}).Var1 = data.(probes{p}).Var1 + time_zone*3600;
        end
    end
    %     % skip if one of the probes is empty
    %     if empty_probe,
    %         continue;
    %     end
    
    % reported sleep times are in ms
    time_bed = data.ems.Var2/1000 + time_zone*3600;
    time_sleep = data.ems.Var3/1000 + time_zone*3600;
    time_wake = data.ems.Var4/1000 + time_zone*3600;
    time_up = data.ems.Var5/1000 + time_zone*3600;

    % extracting workday info
    workday = categorical(data.ems.Var7);
    workday_new = zeros(length(workday),1);
    workday_new(workday=='off') = 0;
    workday_new(workday=='partial') = 1;
    workday_new(workday=='normal') = 2;
    workday = workday_new;
    
    % sorting second columns which will be used for feature extraction
    %     data.fus.Var2 = sqrt((data.fus.Var2-mean(data.fus.Var2)).^2+(data.fus.Var3-mean(data.fus.Var3)).^2);
    %     data.act.Var2 = categorical(cellfun(@(x) x(x~='_'), data.act.Var2, 'uniformoutput', false));
    %     data.scr.Var2 = categorical(data.scr.Var2);
    %     data.bat.Var2 = data.bat.Var3;
    %     data.wif.Var2 = categorical(data.wif.Var2);
    
    for j = 1:length(time_bed),
        
        data.before = [];
        data.during = [];
        data.after = [];
        for p = 1:length(probes),
            data.before.(probes{p}) = clip_data(data.(probes{p}), time_sleep(j)-window_awake, time_bed(j));
            data.during.(probes{p}) = clip_data(data.(probes{p}), time_sleep(j), time_wake(j));
            data.after.(probes{p}) = clip_data(data.(probes{p}), time_wake(j), time_wake(j)+window_awake);
        end
        
        period = {'before', 'during', 'after'};
        
        for k = 1:length(period),
            
            data_int = combine_and_window2(data.(period{k}), window_sensor);
            
            % skip if no data
            if isempty(data_int),
                continue;
            end
            
            ft = [];
            for w=1:length(data_int.ems),
                ft_row = [];
                if ~isempty(data_int.act{w}),
                    ft_row = [ft_row, (sum(~strcmp(data_int.act{w}.Var2,'STILL'))==0)||isempty(data_int.act{w}.Var1)];
                else
                    ft_row = [ft_row, nan];
                end
                if ~isempty(data_int.lgt{w}),
                    ft_row = [ft_row, mean(data_int.lgt{w}.Var2), mean(range(data_int.lgt{w}.Var2))];
                else
                    ft_row = [ft_row, nan, nan];
                end
                if ~isempty(data_int.aud{w}),
                    ft_row = [ft_row, mean(data_int.aud{w}.Var2)];
                else
                    ft_row = [ft_row, nan];
                end
                if ~isempty(data_int.scr{w}),
                    ft_row = [ft_row, length(data_int.scr{w}.Var1)];
                else
                    ft_row = [ft_row, nan];
                end
                if ~isempty(data_int.fus{w}),
                    ft_row = [ft_row, estimate_variance(data_int.fus{w}.Var2,data_int.fus{w}.Var3)];
                else
                    ft_row = [ft_row, nan];
                end
                if ~isempty(data_int.bat{w}),
                    ft_row = [ft_row, mode(data_int.bat{w}.Var3)>0];
                else
                    ft_row = [ft_row, nan];
                end
                if ~isempty(data_int.wif{w}),
                    ft_row = [ft_row, sum(char(mode(categorical(data_int.wif{w}.Var2))))];
                else
                    ft_row = [ft_row, nan];
                end
                ft = [ft; ft_row];
                
%                 ft = [cell2mat(cellfun(@(x) (sum(~strcmp(x.Var2,'STILL'))>0)||isempty(x.Var1), data_int.act, 'uniformoutput', false))',...  %is there only still activity or no activity data?
%                     cellfun(@(x) mean(x.Var2), data_int.lgt)', ... %average light power
%                     cellfun(@(x) mean(range(x.Var2)), data_int.lgt)', ...  %range of light power
%                     cellfun(@(x) mean(range(x.Var2)), data_int.aud)', ...  %range of audio power
%                     cellfun(@(x) length(x.Var1), data_int.scr)', ...   %number of screen on/off
%                     cellfun(@(x) estimate_variance(x.Var2,x.Var3), data_int.fus)', ... %variance of distance from mean
%                     cellfun(@(x) mode(x.Var3)>0, data_int.bat)', ... %battery charging?
%                     cellfun(@(x) sum(char(mode(categorical(x.Var2)))), data_int.wif)']; ... %dominant wifi name
                    
            end
            
            % adding workday variable
            ft = [ft, workday(j)*ones(length(data_int.ems),1)];
            
            % adding to the main feature and state vectors
            feature{i} = [feature{i}; ft];
            if strcmp(period{k}, 'during'),
                state{i} = [state{i}; 2*ones(size(ft,1),1)];
            else
                state{i} = [state{i}; 1*ones(size(ft,1),1)];
            end
            
        end
        
    end
    
    % skipping subject if no features
    if size(feature{i},1)<=1,
        feature{i} = [];
        state{i} = [];
        continue;
    end
    
    % skipping subject if only one state is available
    if length(unique(state{i}))<2,
        feature{i} = [];
        state{i} = [];
    end
    
end

% removing empty subjects
ind = find(cellfun(@isempty, feature));
if sum(ind~=find(cellfun(@isempty, state)))>1,
    error('something is wrong');
end
feature(ind) = [];
state(ind) = [];
subject_sleep = subjects;
subject_sleep(ind) = [];

if save_results,
    save('features_sleepdetection.mat', 'feature', 'state', 'subject_sleep');
end
