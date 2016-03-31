clear;
close all;

extract_home_location = true;

slsh = '/';

probes = {'fus', 'aud', 'act', 'scr', 'bat', 'wif', 'coe', 'app'};

morning_offset = 0; %hours
midnight_offset = 6; %hours

addpath('functions');
addpath('features');
load('settings.mat');

save_results = true;

lat_km = 111;
lng_km = 111*cos(41.88*pi/180); %based on the latitude of Chicago
latlong_km = sqrt(lat_km^2 + lng_km^2);

cnt = 1;
for i = 1:length(subjects),
    
    % loading day type data
    filename = [data_dir, subjects{i}, slsh, 'ems.csv'];
    if ~exist(filename, 'file'),
        disp(['No sleep data for ', subjects{i}]);
        continue;
    end
    tab = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
    time_daytype = tab.Var1 + time_zone*3600;
    daytype = categorical(tab.Var7);

    % loading location data
    filename = [data_dir, subjects{i}, slsh, 'fus.csv'];
    if ~exist(filename, 'file'),
        disp(['No location data for ', subjects{i}]);
        continue;
    end
    tab = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
    sensor.fus{1} = tab.Var1 + time_zone*3600;
    sensor.fus{2} = tab.Var2;  
    sensor.fus{3} = tab.Var3;

    % loading location report data
    if extract_home_location,
        filename = [data_dir, subjects{i}, slsh, 'eml.csv'];
        if ~exist(filename, 'file'),
            disp(['No location report data for ', subjects{i}]);
            continue;
        end
        tab = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
        ind_home = find(categorical(tab.Var6)=='Home');
        if ~isempty(ind_home)
            home_lat = mean(tab.Var3(ind_home));
            home_long = mean(tab.Var4(ind_home));
        else
            disp('Home location not available.');
            continue;
        end
    end
    
    % loading light data
%     filename = [data_dir, subjects{i}, slsh, 'lgt.csv'];
%     if ~exist(filename, 'file'),
%         disp(['No light data for ', subjects{i}]);
%         continue;
%     end
%     tab = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
%     sensor.lgt{1} = tab.Var1 + time_zone*3600;
%     sensor.lgt{2} = tab.Var2;

    % loading audio data
    filename = [data_dir, subjects{i}, slsh, 'aud.csv'];
    if ~exist(filename, 'file'),
        disp(['No audio data for ', subjects{i}]);
        continue;
    end
    tab = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
    sensor.aud{1} = tab.Var1 + time_zone*3600;
    sensor.aud{2} = tab.Var2;
    
    % loading activity data
    filename = [data_dir, subjects{i}, slsh, 'act.csv'];
    if ~exist(filename, 'file'),
        disp(['No activity data for ', subjects{i}]);
        continue;
    end
    tab = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
    sensor.act{1} = tab.Var1 + time_zone*3600;
    sensor.act{2} = categorical(cellfun(@(x) x(x~='_'), tab.Var2, 'uniformoutput', false));

    % loading screen data
    filename = [data_dir, subjects{i}, slsh, 'scr.csv'];
    if ~exist(filename, 'file'),
        disp(['No screen data for ', subjects{i}]);
        continue;
    end
    tab = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
    sensor.scr{1} = tab.Var1 + time_zone*3600;
    sensor.scr{2} = tab.Var2;

    % loading battery data
    filename = [data_dir, subjects{i}, slsh, 'bat.csv'];
    if ~exist(filename, 'file'),
        disp(['No battery data for ', subjects{i}]);
        continue;
    end
    tab = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
    sensor.bat{1} = tab.Var1 + time_zone*3600;
    sensor.bat{2} = tab.Var3;   %charge level

    % loading wifi data
    filename = [data_dir, subjects{i}, slsh, 'wif.csv'];
    if ~exist(filename, 'file'),
        disp(['No wifi data for ', subjects{i}]);
        continue;
    end
    tab = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
    sensor.wif{1} = tab.Var1 + time_zone*3600;
    sensor.wif{2} = categorical(tab.Var2);
    
    % loading communication data
    filename = [data_dir, subjects{i}, slsh, 'coe.csv'];
    if ~exist(filename, 'file'),
        disp(['No wifi data for ', subjects{i}]);
        continue;
    end
    tab = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
    sensor.coe{1} = tab.Var1 + time_zone*3600;
    sensor.coe{2} = tab.Var2;
    sensor.coe{3} = tab.Var3;
    sensor.coe{4} = tab.Var4;
    sensor.coe{5} = tab.Var5;
    
    %loading app usage data
    filename = [data_dir, subjects{i}, slsh, 'app.csv'];
    if ~exist(filename, 'file'),
        disp(['No app usage data for ', subjects{i}]);
        continue;
    end
    tab = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
    sensor.app{1} = tab.Var1 + time_zone*3600;
    sensor.app{2} = categorical(tab.Var3);
    sensor.app{3} = categorical(tab.Var4);

    feature{cnt} = [];
    state{cnt} = [];
    time{cnt} = [];
    
    
    for j = 1:length(time_daytype),
        
        time_start = (floor(time_daytype(j)/86400)+morning_offset/24)*86400;
        time_end = ceil(time_daytype(j)/86400-midnight_offset/24)*86400;
        
        for k=1:length(probes),
            sensor_clp.(probes{k}) = clip_data(sensor.(probes{k}), time_start, time_end);
        end
        
        [use_dur, use_freq] = estimate_usage(sensor_clp.scr{1}, sensor_clp.scr{2}, 30, Inf);
        
        [lat_disc, lng_disc] = universal_grid(sensor_clp.fus{2}, sensor_clp.fus{3}, 1);
        
        ft = [sum(sensor_clp.act{2}=='STILL')/length(sensor_clp.act{2}),...  %stillness
            sum(sensor_clp.act{2}=='ONFOOT')/length(sensor_clp.act{2}),...  %walking activity
            sum(sensor_clp.act{2}=='INVEHICLE')/length(sensor_clp.act{2}),...  %in vechicle 
            mean(range(sensor_clp.aud{2})), ...  %range of audio power
            length(sensor_clp.scr{2}), ...   %number of screen on/off
            use_dur, ...  %phone usage
            use_freq, ...
            estimate_variance(sensor_clp.fus{2},sensor_clp.fus{3}), ... %location variance
            estimate_distance(sensor_clp.fus{1},sensor_clp.fus{2},sensor_clp.fus{3}), ... %total distance
            estimate_incoming(sensor_clp.coe, 'PHONE'), ...  %incoming phone ratio
            estimate_incoming(sensor_clp.coe, 'SMS'), ... %incoming sms ratio
            estimate_response_time(sensor_clp.coe), ... %sms response time mean
            estimate_entropy(categorical(sensor_clp.app{2})), ...   %app name entopry
            sum(sensor_clp.app{2}=='Facebook'), ...   %facebook usage
            sum(sensor_clp.app{2}~='Facebook'), ...   %non-facebook usage
            sum((sensor_clp.app{2}=='Gmail')|(sensor_clp.app{2}=='Email')), ...   %email usage
            sum(sensor_clp.app{2}=='Maps'), ...  %maps usage
            mode(sensor_clp.bat{2})>0, ... %battery charging?
            length(sensor_clp.wif{2}), ... %number of wifi nets
            estimate_entropy(categorical(sensor_clp.wif{2})), ...   %entropy of wifi nets
            mode(lat_disc), ...   %mode of discrete lat
            mode(lng_disc), ...   %mode of discrete long
            sum([1 7]==weekday(time_daytype(j)/86400+datenum(1970,1,1)))];  % weekend?
%             mean(sensor_clp.lgt{2}), ... %average light power
%             mean(var(sensor_clp.lgt{2})), ...  %variance of light power
        if extract_home_location,
            ft = [ft, sum((sqrt((sensor_clp.fus{2}-home_lat).^2+(sensor_clp.fus{3}-home_long).^2))<0.0002)>0]; % avg dist from home
        end
        if sum(isnan(ft))>0,
            fprintf('NaN value in the feature vector (#%d). Skipping...\n',find(isnan(ft)));
            continue;
        end
        
        feature{cnt} = [feature{cnt}; ft];
        state{cnt} = [state{cnt}; daytype(j)];
        time{cnt} = [time{cnt}; time_daytype(j)];
        
    end
    
    if size(feature{cnt},1)==0,
        continue;
    end
%     if length(unique(state{cnt}))<2,
%         continue;
%     end
    
    cnt = cnt+1;
    
end

feature_labels = {'still', 'walking', 'car', 'audio', 'screen', 'duration', 'frequency', 'loc var', 'distance', ...
    'phone', 'sms', 'response','app entropy', 'facebook', 'non-facebook', 'email', 'maps', 'charging', ...
    'wifi', 'wifi entropy', 'lat', 'long', 'dayofweek'};
if extract_home_location,
    feature_labels = [feature_labels, 'home dist'];
end

if save_results,
    if extract_home_location,
        save('features_workday_homeinfo.mat', 'feature_labels', 'feature', 'state', 'time');
    else
        save('features_workday.mat', 'feature_labels', 'feature', 'state', 'time');
    end
end
