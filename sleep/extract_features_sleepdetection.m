clear;
close all;

addpath('../functions');
addpath('../features');
load('../settings.mat');

probes = {'ems','fus','lgt','aud','act','scr','bat','wif'};

% window_awake = 6*3600;  % time window before sleep and after wake to be considered as awake
window_size = 10*60;
overlap = 0;

save_results = true;

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
    data = [];
    for p = 1:length(probes),
        filename = [data_dir, subjects{i}, '/', probes{p}, '.csv'];
        if ~exist(filename, 'file'),
            disp(['No ', probes{p}, ' data for ', subjects{i}]);
            data.(probes{p}) = [];
        else
            data.(probes{p}) = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
            
            % correcting timestamps for the time zone
            data.(probes{p}).Var1 = data.(probes{p}).Var1 + time_zone*3600;
        end
    end
    
    % reported sleep times are in ms
    timestamp = data.ems.Var1 + time_zone*3600;
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
    
    % removing short-period (<=30) screen data
    data.scr = remove_short_screen(data.scr, 30);
    
    % windowing and combining all data
    data_win = combine_and_window_tc_speed(data, time_sleep(1), time_wake(end), window_size);
    
    
    for w=1:length(data_win.act),
        
        time_win = time_sleep(1)+(w-.5)*10*60;
        
        ft_row = [];
        if ~isempty(data_win.act{w}),
            ft_row = [ft_row, (sum(~strcmp(data_win.act{w}.Var2,'STILL'))>0)&~isempty(data_win.act{w}.Var2)];
        else
            ft_row = [ft_row, nan];
        end
        if ~isempty(data_win.lgt{w}),
            ft_row = [ft_row, mean(data_win.lgt{w}.Var2), mean(range(data_win.lgt{w}.Var2))];
        else
            ft_row = [ft_row, nan, nan];
        end
        if ~isempty(data_win.aud{w}),
            ft_row = [ft_row, mean(data_win.aud{w}.Var2)];
        else
            ft_row = [ft_row, nan];
        end
        if ~isempty(data_win.scr{w}),
            ft_row = [ft_row, length(data_win.scr{w}.Var1)];
        else
            ft_row = [ft_row, 0];   % for the screen feature when there is no activity, the number of events should be 0
        end
        if ~isempty(data_win.fus{w}),
            ft_row = [ft_row, estimate_variance(data_win.fus{w}.Var2,data_win.fus{w}.Var3)];
        else
            ft_row = [ft_row, nan];
        end
        if ~isempty(data_win.bat{w}),
            ft_row = [ft_row, mode(data_win.bat{w}.Var3)>0];
        else
            ft_row = [ft_row, nan];
        end
        if ~isempty(data_win.wif{w}),
            ft_row = [ft_row, sum(char(mode(categorical(data_win.wif{w}.Var2))))];
        else
            ft_row = [ft_row, nan];
        end
        %adding absolute time (midpoint in window)
        ft_row = [ft_row, mod(time_win,86400)/3600];
    
        %adding workday info
        %TODO (more complicated than before)
        
        % adding to the big feature matrix
        feature{i} = [feature{i}; ft_row];

        % finding states
        ind_sleep_before = find(time_sleep<time_win, 1, 'last');
        ind_wake_before = find(time_wake<time_win, 1, 'last');
        ind_sleep_after = find(time_sleep>time_win, 1, 'first');
        ind_wake_after = find(time_wake>time_win, 1, 'first');
        
        if time_sleep(ind_sleep_before)>time_wake(ind_wake_before), % if they have gone to sleep
            % only call it asleep if report of wake up the same as report of sleep
            if floor(timestamp(ind_wake_after)/86400)==floor(timestamp(ind_sleep_before)/86400),
                state{i} = [state{i}; 1];
            else
                state{i} = [state{i}; NaN];
            end
        else    % if they have waken up
            % only call it awake if report of sleep is one day after report of wake up
            if floor(timestamp(ind_sleep_after)/86400)-floor(timestamp(ind_wake_before)/86400)==1,
                state{i} = [state{i}; 0];
            else
                state{i} = [state{i}; NaN];
            end
        end
        

    end
    
    
%     for j = 1:length(time_bed),
%         
%                 data.before = [];
%                 data.during = [];
%                 data.after = [];
%                 for p = 1:length(probes),
%                     data.before.(probes{p}) = clip_data(data.(probes{p}), time_sleep(j)-window_awake, time_sleep(j));
%                     data.during.(probes{p}) = clip_data(data.(probes{p}), time_sleep(j), time_wake(j));
%                     data.after.(probes{p}) = clip_data(data.(probes{p}), time_wake(j), time_wake(j)+window_awake);
%                 end
%         
%                 data_int = [];
%                 data_int.before = combine_and_window3(data.before, time_sleep(j)-window_awake, time_sleep(j), window_size);
%                 data_int.during = combine_and_window3(data.during, time_sleep(j), time_wake(j), window_size);
%                 data_int.after = combine_and_window3(data.after, time_wake(j), time_wake(j)+window_awake, window_size);
%         
%         period = {'before', 'during', 'after'};
%         % saving timestart to calculate absolute time later as a feature
%         timestart = [time_sleep(j)-window_awake, time_sleep(j),  time_wake(j)+window_awake];
%         
%         for k = 1:length(period),
%             
%             % Filling in empty activity bins with last activity
%             last_activity='STILL';
%             for w=1:length(data_int.(period{k}).act),
%                 if isempty(data_int.(period{k}).act{w}),
%                     data_int.(period{k}).act{w} = table(0, {last_activity}, 100);
%                 else
%                     last_activity = data_int.(period{k}).act{w}.Var2{end};
%                 end
%             end
%             
%             % Building the feature vector
%             ft = [];
%             for w=1:length(data_int.(period{k}).act),
%                 ft_row = [];
%                 if ~isempty(data_int.(period{k}).act{w}),
%                     ft_row = [ft_row, (sum(~strcmp(data_int.(period{k}).act{w}.Var2,'STILL'))>0)&~isempty(data_int.(period{k}).act{w}.Var2)];
%                 else
%                     ft_row = [ft_row, nan];
%                 end
%                 if ~isempty(data_int.(period{k}).lgt{w}),
%                     ft_row = [ft_row, mean(data_int.(period{k}).lgt{w}.Var2), mean(range(data_int.(period{k}).lgt{w}.Var2))];
%                 else
%                     ft_row = [ft_row, nan, nan];
%                 end
%                 if ~isempty(data_int.(period{k}).aud{w}),
%                     ft_row = [ft_row, mean(data_int.(period{k}).aud{w}.Var2)];
%                 else
%                     ft_row = [ft_row, nan];
%                 end
%                 if ~isempty(data_int.(period{k}).scr{w}),
%                     ft_row = [ft_row, length(data_int.(period{k}).scr{w}.Var1)];
%                 else
%                     ft_row = [ft_row, 0];   % for the screen feature when there is no activity, the number of events should be 0
%                 end
%                 if ~isempty(data_int.(period{k}).fus{w}),
%                     ft_row = [ft_row, estimate_variance(data_int.(period{k}).fus{w}.Var2,data_int.(period{k}).fus{w}.Var3)];
%                 else
%                     ft_row = [ft_row, nan];
%                 end
%                 if ~isempty(data_int.(period{k}).bat{w}),
%                     ft_row = [ft_row, mode(data_int.(period{k}).bat{w}.Var3)>0];
%                 else
%                     ft_row = [ft_row, nan];
%                 end
%                 if ~isempty(data_int.(period{k}).wif{w}),
%                     ft_row = [ft_row, sum(char(mode(categorical(data_int.(period{k}).wif{w}.Var2))))];
%                 else
%                     ft_row = [ft_row, nan];
%                 end
%                 %adding absolute time (midpoint in window)
%                 ft_row = [ft_row, mod((timestart(k)+(w-.5)*10*60),86400)/3600];
%                 
%                 % adding the row to the matrix
%                 ft = [ft; ft_row];
%                 
%             end
%             
%             % adding workday variable (this will always be the last
%             % feature)
%             ft = [ft, workday(j)*ones(length(data_int.(period{k}).ems),1)];
%             
%             % adding to the main feature and state vectors
%             feature{i} = [feature{i}; ft];
%             if strcmp(period{k}, 'during'),
%                 state{i} = [state{i}; ones(size(ft,1),1)];    % asleep
%             else
%                 state{i} = [state{i}; zeros(size(ft,1),1)];    % awake
%             end
%             
%         end
%         
%     end
    
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
if length(ind)>1,
    fprintf('removing the following subjects with no data:\n');
    subjects(ind)
    fprintf('\n');
end
feature(ind) = [];
state(ind) = [];
subject_sleep = subjects;
subject_sleep(ind) = [];

if save_results,
    save('features_sleepdetection.mat', 'feature', 'state', 'subject_sleep');
end
