% This function extracts features for each day separately

clear;
close all;

n_days = Inf;
overlap = Inf;
days_min = 14;

remove_duplicate_timestamps = true;
save_results = true;

read_string = containers.Map({'fus', 'lgt', 'aud', 'act', 'scr', 'bat', 'wif', 'coe', 'app'}, ...
    {'%f%f%f%f%f', '%f%f%f', '%f%f%f%f', '%f%s%f', '%f%s', '%f%d%d', '%f%s%s%f', '%f%s%s%s%s', '%f%s%s%s'});

probes = {'fus', 'aud', 'act', 'scr', 'bat', 'coe', 'wif', 'app'};

addpath('functions');
addpath('features');

load('settings.mat');

cnt = 1;
for i = 1:length(subjects),
    
    fprintf('%d/%d\n',i,length(subjects));

    % loading data
    t_start = Inf;
    t_end = -Inf;
    has_empty_probe = false;
    for j = 1:length(probes),
        eval(['clear data_',probes{j},';']);
        filename = [data_dir, subjects{i}, '\',probes{j},'.csv'];
        if ~exist(filename, 'file'),
            disp(['No ',probes{j},' data for ', subjects{i}]);
            has_empty_probe = true;
            continue;
        end
        tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
        for k=1:size(tab,2),
            sensor.(probes{j}){k} = tab.(sprintf('Var%d',k));
        end
        sensor.(probes{j}){1} = sensor.(probes{j}){1} + time_zone*3600;
        
        % reading normal/off day self-report
        filename = [data_dir, subjects{i}, '\ems.csv'];
        if ~exist(filename, 'file'),
            disp(['No normal/off day report data for ', subjects{i}]);
            has_empty_probe = true;
            continue;
        end
        tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
        day_type.time = tab.Var1;
        day_type.type = categorical(tab.Var7);

        % removing data collected during holidays
%         t_cut = (datenum(2015,12,20)-datenum(1970,1,1))*86400;
%         ind = find(sensor.(probes{j}){1}>t_cut, 1, 'first');
%         if ~isempty(ind),
%             sensor.(probes{j}) = clip_data(sensor.(probes{j}), sensor.(probes{j}){1}(1), sensor.(probes{j}){1}(ind));
%         end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        t1 = sensor.(probes{j}){1}(1);
        t2 = sensor.(probes{j}){1}(end);
        if floor((t2-t1)/86400)<days_min,
            has_empty_probe = true;
            continue;
        end
        if t1<t_start,
            t_start = t1;
        end
        if t2>t_end,
            t_end = t2;
        end
    end
    if isinf(t_start)||has_empty_probe,
        continue;
    end
    
    t_start = floor(t_start/86400)*86400;
    t_end = floor(t_end/86400)*86400;
    
    feature{cnt} = [];
    time_feature{cnt} = [];
    
    for t = t_start:overlap*86400:t_end,
        
        for j = 1:length(probes),
            sensor_clp.(probes{j}) = clip_data(sensor.(probes{j}), t, t+n_days*86400);
%             [sensor_normal.(probes{j}), sensor_off.(probes{j})] = separate_workday(sensor.(probes{j}), day_type);
%             sensor_off.(probes{j}) = sensor_clp.(probes{j});%%%%%%%%%%%%%%%%%%%%%%%
            if remove_duplicate_timestamps,
                inds = (diff(sensor_clp.(probes{j}){1})==0);
                for k = 1:length(sensor_clp.(probes{j})),
                    sensor_clp.(probes{j}){k}(inds) = [];
                end
%                 inds = (diff(sensor_off.(probes{j}){1})==0);
%                 for k = 1:length(sensor_off.(probes{j})),
%                     sensor_off.(probes{j}){k}(inds) = [];
%                 end
            end
        end
        
        [screen, use_dur, use_freq] = estimate_usage(sensor_clp.scr{1}, sensor_clp.scr{2}, 30, Inf);
        
%         inds = find(diff(sensor_clp.fus{1})==0);
%         sensor_clp.fus{1}(inds) = [];
%         sensor_clp.fus{2}(inds) = [];
%         sensor_clp.fus{3}(inds) = [];
%         sensor_clp.fus{4}(inds) = [];
%         sensor_clp.fus{5}(inds) = [];
        if length(sensor_clp.fus{1})>1,
            % removing duplicate timestamps as they cause problem for the
            % circadian movement function
            [ft_location, ~] = extract_features_location(sensor_clp.fus{1}, sensor_clp.fus{2}, sensor_clp.fus{3});
            ent = ft_location(5);
            ent_norm = ft_location(6);
            circ_mov = ft_location(3);
            clus_circ_mov = ft_location(10);
            loc_var = ft_location(2);
        else
            ent = NaN;
            ent_norm = NaN;
            circ_mov = NaN;
            loc_var = NaN;
            clus_circ_mov = NaN;
        end
        
        ft = [sum(strcmp(sensor_clp.act{2},'STILL'))/length(sensor_clp.act{2}),...  %stillness
            sum(strcmp(sensor_clp.act{2},'ON_FOOT'))/length(sensor_clp.act{2}),...  %walking activity
            sum(strcmp(sensor_clp.act{2},'IN_VEHICLE'))/length(sensor_clp.act{2}),...  %in vechicle 
            mean(range(sensor_clp.aud{2})), ...  %range of audio power
            screen, ...   %number of screen on/off per hour
            use_dur, ...  %phone usage duration
            use_freq, ...   % phone usage frequency
            loc_var, ... %location variance
            estimate_distance(sensor_clp.fus{1},sensor_clp.fus{2},sensor_clp.fus{3}), ... %total distance per hour
            estimate_incoming(sensor_clp.coe, 'PHONE'), ...  %incoming phone ratio
            estimate_incoming(sensor_clp.coe, 'SMS'), ... %incoming sms ratio
            estimate_response_time(sensor_clp.coe), ... %sms response time mean
            mean(sensor_clp.fus{2}), ... %absolute latitude
            mean(sensor_clp.fus{3}), ... %absolute longitude
            ent, ... % entropy
            ent_norm, ... % normalized entropy
            clus_circ_mov, ... % circadian movement
            estimate_entropy(categorical(sensor_clp.wif{2})), ...   %entropy of wifi nets
            estimate_launches(sensor_clp.app), ...   %no. launches per day
            sum(strcmp(sensor_clp.app{3},'Facebook'))/length(sensor_clp.app{3}), ...   %facebook usage
            sum(~strcmp(sensor_clp.app{3},'Facebook'))/length(sensor_clp.app{3}), ...   %non-facebook usage
            sum(strcmp(sensor_clp.app{3},'Gmail')|strcmp(sensor_clp.app{3},'Email'))/length(sensor_clp.app{3}), ...   %email usage
            sum(strcmp(sensor_clp.app{3},'Maps'))/length(sensor_clp.app{3}), ...   %maps usage
            sum(strcmp(sensor_clp.app{3},'Mobilyze'))/length(sensor_clp.app{3}), ...   % Mobilyze usage
            mean(sensor_clp.bat{3})]; % phone plugged percentage
%             mean(data_lgt_clp{2}), ... %average light power
%             mean(range(data_lgt_clp{2})), ...  %range of light power
%             sum(char(mode(data_wif_clp{2}))), ... %dominant wifi name
        
        if sum(isnan(ft))>0,
            fprintf('NaN value in the feature vector (#%d). Skipping...\n',find(isnan(ft)));
            continue;
        end
        
        feature{cnt} = [feature{cnt}; ft];
        time_feature{cnt} = [time_feature{cnt}; t];
        
    end
    
    if size(feature{cnt},1)==0,
        continue;
    end
    
    subject_feature{cnt} = subjects{i};
    
    cnt = cnt+1;
    
end

feature_labels = {'stillness','walking','vehicle','sound change','screen',...
    'duration','frequency','loc variance','distance','call',...
    'sms','response','lat','long','entropy','norm entropy','circ mov',...
    'wifi ent','launches','facebook','non-facebook','email','maps','mobilyze','battery'};

if save_results,
    save(sprintf('features_%ddays.mat',n_days), 'subject_feature', 'feature', 'time_feature', 'feature_labels');
end
