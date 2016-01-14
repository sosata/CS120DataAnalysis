clear;
close all;

save_results = true;

read_string = containers.Map({'fus', 'lgt', 'aud', 'act', 'scr', 'bat', 'wif', 'coe', 'app'}, ...
    {'%f%f%f%f%f', '%f%f%f', '%f%f%f%f', '%f%s%f', '%f%s', '%f%d%d', '%f%s%s%f', '%f%s%s%s%s', '%f%s%s%s'});

probes = {'fus', 'aud', 'act', 'scr', 'bat', 'coe', 'app'};

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
        fid = fopen(filename, 'r');
        eval(['data_', probes{j}, ' = textscan(fid, read_string(probes{j}), ''delimiter'', ''\t'');']);
        fclose(fid);
        eval(['data_',probes{j},'{1} = data_',probes{j},'{1} + time_zone*3600;']);
        eval(['t1 = data_', probes{j}, '{1}(1);']);
        eval(['t2 = data_', probes{j}, '{1}(end);']);
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
    
    for t = t_start:86400:t_end,
        
        for j = 1:length(probes),
%             eval(['data_',probes{j},'_clp = {};']);
%             eval(sprintf('if exist(''data_%s''),\ndata_%s_clp = clip_data(data_%s, t, t+86400);\nend',...
%                 probes{j},probes{j},probes{j}));
            eval(sprintf('data_%s_clp = clip_data(data_%s, t, t+86400);', probes{j},probes{j}));
        end
        
        [use_dur, use_freq] = estimate_usage(data_scr_clp{1}, data_scr_clp{2}, 30, Inf);
        
        ft = [exp(sum(strcmp(data_act_clp{2},'STILL'))/length(data_act_clp{2})),...  %stillness
            log(.001+sum(strcmp(data_act_clp{2},'ON_FOOT'))/length(data_act_clp{2})),...  %walking activity
            log(.001+sum(strcmp(data_act_clp{2},'IN_VEHICLE'))/length(data_act_clp{2})),...  %in vechicle 
            log(.001+mean(range(data_aud_clp{2}))), ...  %range of audio power
            log(.001+length(data_scr_clp{2})), ...   %number of screen on/off
            use_dur, ...  %phone usage
            use_freq, ...
            estimate_variance(data_fus_clp{2},data_fus_clp{3}), ... %location variance
            estimate_distance(data_fus_clp{2},data_fus_clp{3}), ... %total distance
            estimate_incoming(data_coe_clp, 'PHONE'), ...  %incoming phone ratio
            estimate_incoming(data_coe_clp, 'SMS'), ... %incoming sms ratio
            estimate_response_time(data_coe_clp), ... %sms response time mean
            mean(data_fus_clp{2}), ... %absolute latitude
            mean(data_fus_clp{3}), ... %absolute longitude
            length(data_app_clp{3}), ...   %no. launches
            sum(strcmp(data_app_clp{3},'Facebook')), ...   %facebook usage
            sum(~strcmp(data_app_clp{3},'Facebook')), ...   %non-facebook usage
            sum(strcmp(data_app_clp{3},'Gmail')|strcmp(data_app_clp{3},'Email')), ...   %email usage
            mode(data_bat_clp{3})>0, ... %battery charging?
            sum(strcmp(data_app_clp{3},'Maps'))];   %maps usage
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
    'sms','response','lat','long','apps',...
    'facebook','non-facebook','email','battery','maps'};

if save_results,
    save('features.mat', 'subject_feature', 'feature', 'time_feature', 'feature_labels');
end
