clear;
close all;

addpath('../functions');
addpath('../features');
load('../settings.mat');

calculate_features = true; % if false, only caluclates states and pulls features from previously saved file
correct_sleep_times = true;
save_results = true;

window_size = 10*60;
overlap = 0;

% initializing feature and state vectors
if calculate_features,
    probes = {'ems','fus','lgt','aud','act','scr','bat','wif','coe'};
    feature = cell(length(subjects),1);
else
    probes = {'ems'};
    load('features_sleepdetection');
    clear subject_sleep;
end
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
    
    % correct potentially wrong reports
    if correct_sleep_times,
        [timestamp, time_bed, time_sleep, time_wake, time_up] = correct_reported_times(timestamp, time_bed, time_sleep, time_wake, time_up);
    end
    
    % extracting workday info
%     workday = categorical(data.ems.Var7);
%     workday_new = zeros(length(workday),1);
%     workday_new(workday=='off') = 0;
%     workday_new(workday=='partial') = 1;
%     workday_new(workday=='normal') = 2;
%     workday = workday_new;
    
    if calculate_features,
        % removing short-period (<=30) screen data
        data.scr = remove_short_screen(data.scr, 30);
        
        % windowing and combining all data
        data_win = combine_and_window_tc_speed(data, time_bed(1), time_up(end), window_size);
        n_samples = length(data_win.act);
    else
        n_samples = length(feature{i});
    end
    
    for w=1:n_samples,
        
        time_win = time_bed(1)+(w-.5)*10*60;
        
        if calculate_features,
            ft_row = [];
            % stillness
            if ~isempty(data_win.act{w}),
                %ft_row = [ft_row, (sum(~strcmp(data_win.act{w}.Var2,'STILL'))>0)&~isempty(data_win.act{w}.Var2)];
                ft_row = [ft_row, sum(strcmp(data_win.act{w}.Var2,'STILL'))/length(data_win.act{w}.Var2)];
                missing_act = 0;
            else
                ft_row = [ft_row, nan];
                missing_act = 1;
            end
            % light
            if ~isempty(data_win.lgt{w}),
                ft_row = [ft_row, nanmean(data_win.lgt{w}.Var2), nanmean(range(data_win.lgt{w}.Var2)), kurtosis(data_win.lgt{w}.Var2)];
                if length(data_win.lgt{w}.Var2)>=2,
                    ft_row = [ft_row, nanmean(((data_win.lgt{w}.Var2(2:end)-data_win.lgt{w}.Var2(1:end-1)).^2)./(data_win.lgt{w}.Var2(1:end-1).^2))];
                else
                    ft_row = [ft_row, nan];
                end
                missing_light = 0;
            else
                ft_row = [ft_row, nan, nan, nan, nan];
                missing_light = 1;
            end
            % audio
            if ~isempty(data_win.aud{w}),
                ft_row = [ft_row, nanmean(data_win.aud{w}.Var2), nanmin(data_win.aud{w}.Var3), nanmax(data_win.aud{w}.Var3)];
                missing_audio = 0;
            else
                ft_row = [ft_row, nan, nan, nan];
                missing_audio = 1;
            end
            % screen
            if ~isempty(data_win.scr{w}),
                ft_row = [ft_row, length(data_win.scr{w}.Var1)];
            else
                ft_row = [ft_row, 0];   % for the screen feature when there is no activity, the number of events should be 0
            end
            % location
            if ~isempty(data_win.fus{w}),
                ft_row = [ft_row, estimate_variance(data_win.fus{w}.Var2,data_win.fus{w}.Var3)];
                if length(data_win.fus{w}.Var2)>=2,
                    change_lat = nanmean(((data_win.fus{w}.Var2(2:end)-data_win.fus{w}.Var2(1:end-1)).^2)./(data_win.fus{w}.Var2(1:end-1).^2));
                    change_lng = nanmean(((data_win.fus{w}.Var3(2:end)-data_win.fus{w}.Var3(1:end-1)).^2)./(data_win.fus{w}.Var3(1:end-1).^2));
                    ft_row = [ft_row, nanmean([change_lat change_lng])];
                else
                    ft_row = [ft_row, nan];
                end
                missing_loc = 0;
            else
                ft_row = [ft_row, nan, nan];
                missing_loc = 1;
            end
            % battery charging
            if ~isempty(data_win.bat{w}),
                ft_row = [ft_row, nanmean(data_win.bat{w}.Var2)];
                ft_row = [ft_row, mode(data_win.bat{w}.Var3)>0, mode(data_win.bat{w}.Var3)==2];
                missing_bat = 0;
            else
                ft_row = [ft_row, nan, nan, nan];
                missing_bat = 1;
            end
            % wifi
            if ~isempty(data_win.wif{w}),
                ft_row = [ft_row, sum(char(mode(categorical(data_win.wif{w}.Var2))))];
                missing_wifi = 0;
            else
                ft_row = [ft_row, nan];
                missing_wifi = 1;
            end
            % communication
            if ~isempty(data_win.coe{w}),
                ft_row = [ft_row, sum(data_win.coe{w}.Var2{end}), sum(data_win.coe{w}.Var3{end}), ...
                    sum(strcmp(data_win.coe{w}.Var4,'PHONE')),sum(strcmp(data_win.coe{w}.Var4,'SMS')), ...
                    sum(strcmp(data_win.coe{w}.Var4,'PHONE')&strcmp(data_win.coe{w}.Var5,'OUTGOING')), ...
                    sum(strcmp(data_win.coe{w}.Var4,'SMS')&strcmp(data_win.coe{w}.Var5,'OUTGOING'))];
            else
                ft_row = [ft_row, nan, nan, 0, 0, 0, 0];
            end
            
            %adding missing feature indicators
            ft_row = [ft_row, missing_act, missing_audio, missing_bat, missing_light, missing_loc, missing_wifi];
            
            %time of day (midpoint in window)
            ft_row = [ft_row, mod(time_win,86400)/3600];
            
            %adding workday info
            %TODO (more complicated than before)
            
            % adding to the big feature matrix
            feature{i} = [feature{i}; ft_row];
            
        end
        
        % finding states
        ind_sleep_before = find(time_bed<time_win, 1, 'last');
        ind_wake_before = find(time_up<time_win, 1, 'last');
        ind_sleep_after = find(time_bed>time_win, 1, 'first');
        ind_wake_after = find(time_up>time_win, 1, 'first');
        
        if time_bed(ind_sleep_before)>time_up(ind_wake_before), % if they have gone to sleep
            % only call it asleep if report of wake up is on the same as report of sleep
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
    
    if calculate_features,
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
    else
        if isempty(feature{i}),
            state{i} = [];
        end
    end
    
end

subject_sleep = subjects;

% if calculate_features,
    %removing empty subjects
%     ind = find(cellfun(@isempty, feature));
%     if sum(ind~=find(cellfun(@isempty, state)))>1,
%         error('something is wrong');
%     end
%     if length(ind)>1,
%         fprintf('removing the following subjects with no data:\n');
%         subjects(ind)
%         fprintf('\n');
%     end
%     feature(ind) = [];
%     state(ind) = [];
%     subject_sleep(ind) = [];
% end

feature_label = {'stillness','lgt mean','lgt range','lgt kurtosis','lgt change','audio pwr','audio frq min','audio frq max',...
    'screen','loc var','loc change','bat level','charging','charging usb','wifi','last name','last number','call',...
    'sms','out call','out sms'};
feature_label = [feature_label, 'missing act', 'missing audio', 'missing bat', 'missing light', 'missing loc', 'missing wifi'];
feature_label = [feature_label, 'time'];

if save_results,
    save('features_sleepdetection.mat', 'feature', 'feature_label', 'state', 'subject_sleep');
end
