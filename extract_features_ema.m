clear;
close all;

% assumptions:
% 1. 

% TODO
% probes = ...
% features = ...

% run_mode = 'focus';
window_sensor = 48*3600;
overlap = 0;
anomaly_threshold_low = 1.5; % times the std
anomaly_threshold_high = 1.3;   % chosen such that data is balanced
save_results = true;

% targets = containers.Map({'calm','mood','energy','focus'}, [2 3 4 5]);
% if sum(ismember(targets.keys, run_mode))~=1,
%     error('run mode not known.');
% end

addpath('functions');
addpath('features');

load('settings.mat');

cnt = 1;
for i = 1:length(subjects),%[80:115,117:125,127:145,147:length(subjects)],
    
    fprintf('%d/%d\n',i,length(subjects));
    
    % loading focus data
    filename = [data_dir, subjects{i}, '\emm.csv'];
    if ~exist(filename, 'file'),
        disp(['No sleep data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data_ema = textscan(fid, '%f%f%f%f%f%d%s', 'delimiter', '\t');
    fclose(fid);
    data_ema{1} = data_ema{1} + time_zone*3600;
    
    time_ema = data_ema{1};
    %ema{cnt} = data_ema{targets(run_mode)};
    ema_stress = data_ema{2};
    ema_calm = data_ema{3};
    ema_energy = data_ema{4};
    ema_focus = data_ema{5};

    % calculating daily averages
%     t = floor(data_ema{1}(1)/86400)*86400;
%     cnt2 = 1;
%     time{cnt} = [];
%     ema{cnt} = [];
%     while t<=data_ema{1}(end),
%        ind = find((data_ema{1}>=t)&(data_ema{1}<t+86400));
% %        %time{cnt}(cnt2) = t;
%        if ~isempty(ind),
% %            %target = mean(data_ema{targets(run_mode)}(ind)); % 2:calm, 3:mood, 4:energy, 5:focus
%            target = mean(data_ema{targets(run_mode)}(ind(1))); % 2:calm, 3:mood, 4:energy, 5:focus
%            if ~isnan(target),
%                ema{cnt}(cnt2) = target;
%                time{cnt}(cnt2) = data_ema{1}(ind(1));%t;
%                cnt2 = cnt2+1;
%            end
%        end
%        t = t+86400;
%     end
    clear data_ema;
    
    % loading location data
    filename = [data_dir, subjects{i}, '\fus.csv'];
    if ~exist(filename, 'file'),
        disp(['No location data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data_loc = textscan(fid, '%f%f%f%f%f', 'delimiter', '\t');
    fclose(fid);
    data_loc{1} = data_loc{1} + time_zone*3600;
    data_lat = {data_loc{1},data_loc{2}};
    data_lng = {data_loc{1},data_loc{3}};
    clear data_loc;

    % loading light data
%     filename = [data_dir, subjects{i}, '\lgt.csv'];
%     if ~exist(filename, 'file'),
%         disp(['No light data for ', subjects{i}]);
%         continue;
%     end
%     fid = fopen(filename, 'r');
%     data_lgt = textscan(fid, '%f%f%f', 'delimiter', '\t');
%     fclose(fid);
%     data_lgt{1} = data_lgt{1} + time_zone*3600;
%     data_lgt(3) = [];

    % loading audio data
    filename = [data_dir, subjects{i}, '\aud.csv'];
    if ~exist(filename, 'file'),
        disp(['No audio data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data_aud = textscan(fid, '%f%f%f%f', 'delimiter', '\t');
    fclose(fid);
    data_aud{1} = data_aud{1} + time_zone*3600;
    data_aud(4) = [];
    data_aud(3) = [];
    
    % loading activity data
    filename = [data_dir, subjects{i}, '\act.csv'];
    if ~exist(filename, 'file'),
        disp(['No activity data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data_act = textscan(fid, '%f%s%f', 'delimiter', '\t');
    fclose(fid);
    data_act{1} = data_act{1} + time_zone*3600;
    data_act{2} = categorical(cellfun(@(x) x(x~='_'), data_act{2}, 'uniformoutput', false));
    data_act(3) = [];

    % loading screen data
    filename = [data_dir, subjects{i}, '\scr.csv'];
    if ~exist(filename, 'file'),
        disp(['No screen data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data_scr = textscan(fid, '%f%s', 'delimiter', '\t');
    fclose(fid);
    data_scr{1} = data_scr{1} + time_zone*3600;
    data_scr{2} = categorical(data_scr{2});

    % loading battery data
%     filename = [data_dir, subjects{i}, '\bat.csv'];
%     if ~exist(filename, 'file'),
%         disp(['No battery data for ', subjects{i}]);
%         continue;
%     end
%     fid = fopen(filename, 'r');
%     data_bat = textscan(fid, '%f%d%d', 'delimiter', '\t');
%     fclose(fid);
%     data_bat{1} = data_bat{1} + time_zone*3600;
%     data_bat{2} = data_bat{3};   %charge level
%     data_bat(3) = [];

    % loading wifi data
    filename = [data_dir, subjects{i}, '\wif.csv'];
    if ~exist(filename, 'file'),
        disp(['No wifi data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data_wif = textscan(fid, '%f%s%s%f', 'delimiter', '\t');
    fclose(fid);
    data_wif{1} = data_wif{1} + time_zone*3600;
    data_wif{2} = categorical(data_wif{2});
    data_wif(4) = [];
    data_wif(3) = [];

    % loading communication events data
    filename = [data_dir, subjects{i}, '\coe.csv'];
    if ~exist(filename, 'file'),
        disp(['No wifi data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data_coe = textscan(fid, '%f%s%s%s%s', 'delimiter', '\t');
    fclose(fid);
    data_coe{1} = data_coe{1} + time_zone*3600;
    data_coe{2} = categorical(data_coe{4});
    data_coe{3} = categorical(data_coe{5});
    data_coe(5) = [];
    data_coe(4) = [];
    
    %loading app usage data
    filename = [data_dir, subjects{i}, '\app.csv'];
    if ~exist(filename, 'file'),
        disp(['No app usage data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data_app = textscan(fid, '%f%s%s%s', 'delimiter', '\t');
    fclose(fid);
    data_app{1} = data_app{1} + time_zone*3600;
    data_app{2} = categorical(data_app{3});
    data_app{3} = categorical(data_app{4});
    data_app(4) = [];    

    feature{cnt} = [];
%     state{cnt} = [];
    calm{cnt} = [];
    mood{cnt} = [];
    energy{cnt} = [];
    focus{cnt} = [];
    time{cnt} = [];
    
    for j = 2:length(time_ema),
        
%         if (ema_mood{cnt}(j)<mean(ema_mood{cnt})+anomaly_threshold_high*std(ema_mood{cnt}))&&...
%                 (ema_mood{cnt}(j)>mean(ema_mood{cnt})-anomaly_threshold_low*std(ema_mood{cnt})),
%             continue;
%         end
        
        data_act_clp = clip_data(data_act, time_ema(j)-window_sensor, time_ema(j));
%         data_lgt_clp = clip_data(data_lgt, time{cnt}(j)-window_sensor, time{cnt}(j));
        data_aud_clp = clip_data(data_aud, time_ema(j)-window_sensor, time_ema(j));
        data_scr_clp = clip_data(data_scr, time_ema(j)-window_sensor, time_ema(j));
        data_lat_clp = clip_data(data_lat, time_ema(j)-window_sensor, time_ema(j));
        data_lng_clp = clip_data(data_lng, time_ema(j)-window_sensor, time_ema(j));
%         data_bat_clp = clip_data(data_bat, time{cnt}(j)-window_sensor, time{cnt}(j));
%         data_wif_clp = clip_data(data_wif, time{cnt}(j)-window_sensor, time{cnt}(j));
        data_coe_clp = clip_data(data_coe, time_ema(j)-window_sensor, time_ema(j));
        data_app_clp = clip_data(data_app, time_ema(j)-window_sensor, time_ema(j));
        
        [use_dur, use_freq] = estimate_usage(data_scr_clp{1}, data_scr_clp{2}, 30, Inf);  

        ft = [exp(sum(data_act_clp{2}=='STILL')/length(data_act_clp{2})),...  %stillness
            log(.001+sum(data_act_clp{2}=='ONFOOT')/length(data_act_clp{2})),...  %walking activity
            log(.001+sum(data_act_clp{2}=='INVEHICLE')/length(data_act_clp{2})),...  %in vechicle 
            log(.001+mean(range(data_aud_clp{2}))), ...  %range of audio power
            log(.001+length(data_scr_clp{2})), ...   %number of screen on/off
            use_dur, ...  %phone usage
            use_freq, ...
            estimate_variance(data_lat_clp{2},data_lng_clp{2}), ... %location variance
            estimate_distance(data_lat_clp{2},data_lng_clp{2}), ... %total distance
            estimate_incoming(data_coe_clp, 'PHONE'), ...  %incoming phone ratio
            estimate_incoming(data_coe_clp, 'SMS'), ... %incoming sms ratio
            estimate_response_time(data_coe_clp), ... %sms response time mean
            mean(data_lat_clp{2}), ... %absolute latitude
            mean(data_lng_clp{2}), ... %absolute longitude
            length(data_app_clp{2}), ...   %no. launches
            sum(data_app_clp{2}=='Facebook'), ...   %facebook usage
            sum(data_app_clp{2}~='Facebook'), ...   %non-facebook usage
            sum((data_app_clp{2}=='Gmail')|(data_app_clp{2}=='Email')), ...   %email usage
            sum(data_app_clp{2}=='Maps'), ...   %maps usage
            mod(time_ema(j),86400)]; %time of the day
%             mode(data_bat_clp{2})>0, ... %battery charging?
%             mean(data_lgt_clp{2}), ... %average light power
%             mean(range(data_lgt_clp{2})), ...  %range of light power
%             sum(char(mode(data_wif_clp{2}))), ... %dominant wifi name
        
        if sum(isnan(ft))>0,
            fprintf('NaN value in the feature vector (#%d). Skipping...\n',find(isnan(ft)));
            continue;
        end
        
        feature{cnt} = [feature{cnt}; ft];
        
        % targets as daily average
%         state{cnt} = [state{cnt}; ema{cnt}(j)];

        calm{cnt} = [calm{cnt}; ema_stress(j)];
        mood{cnt} = [mood{cnt}; ema_calm(j)];
        energy{cnt} = [energy{cnt}; ema_energy(j)];
        focus{cnt} = [focus{cnt}; ema_focus(j)];
        
        time{cnt} = [time{cnt}; time_ema(j)];
        
        % targets as anomalies (good:1, bad:0)
%         if ema_mood{cnt}(j)>=mean(ema_mood{cnt})+anomaly_threshold_high*std(ema_mood{cnt}),
%             mood{cnt} = [mood{cnt}; 1];
%         elseif ema_mood{cnt}(j)<=mean(ema_mood{cnt})-anomaly_threshold_low*std(ema_mood{cnt}),
%             mood{cnt} = [mood{cnt}; 0];
%         else
%             error('Something is wrong.');
%         end
        
    end
    
    if size(feature{cnt},1)==0,
        continue;
    end
%     if length(unique(state{cnt}))<2,
%         continue;
%     end
    
    cnt = cnt+1;
    
end

feature_labels = {'stillness','walking','vehicle','sound change','screen',...
    'duration','frequency','loc variance','distance','call',...
    'sms','response','lat','long','apps',...
    'facebook','non-facebook','email','maps','time'};

if save_results,
    save('features_ema.mat', 'feature', 'time','calm', 'mood', 'energy', 'focus', 'feature_labels');
end
