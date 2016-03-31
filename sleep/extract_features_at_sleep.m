clear;
close all;

extract_workday = true;

addpath('../Functions');
load('../settings.mat');

window_awake = 6*3600;  % time window before sleep and after wake to be considered as awake
window_sensor = 10*60;
overlap = 0;

save_results = true;

cnt = 1;
for i = 1:length(subjects),
    
    % loading focus data
    filename = [data_dir, subjects{i}, '\ems.csv'];
    if ~exist(filename, 'file'),
        disp(['No sleep data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%f%f%f%f%d%s', 'delimiter', '\t');
    fclose(fid);

    time_bed = data{2}/1000 + time_zone*3600;
    time_sleep = data{3}/1000 + time_zone*3600;
    time_wake = data{4}/1000 + time_zone*3600;
    time_up = data{5}/1000 + time_zone*3600;
    
    if extract_workday,
        workday = categorical(data{7});
        workday_new = zeros(length(workday),1);
        workday_new(workday=='off') = 0;
        workday_new(workday=='partial') = 1;
        workday_new(workday=='normal') = 2;
        workday = workday_new;
    end
    
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
    data_loc{2} = sqrt((data_loc{2}-mean(data_loc{2})).^2+(data_loc{3}-mean(data_loc{3})).^2);  %distance from mean
    data_loc(5) = [];
    data_loc(4) = [];
    data_loc(3) = [];

    % loading light data
    filename = [data_dir, subjects{i}, '\lgt.csv'];
    if ~exist(filename, 'file'),
        disp(['No light data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data_lgt = textscan(fid, '%f%f%f', 'delimiter', '\t');
    fclose(fid);
    data_lgt{1} = data_lgt{1} + time_zone*3600;
    data_lgt(3) = [];

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
    filename = [data_dir, subjects{i}, '\bat.csv'];
    if ~exist(filename, 'file'),
        disp(['No battery data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data_bat = textscan(fid, '%f%d%d', 'delimiter', '\t');
    fclose(fid);
    data_bat{1} = data_bat{1} + time_zone*3600;
    data_bat{2} = data_bat{3};   %charge level
    data_bat(3) = [];

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

    feature{cnt} = [];
    state{cnt} = [];
    
    for j = 1:length(time_bed),
        
        data_act_before = clip_data(data_act, time_sleep(j)-window_awake, time_bed(j));
        data_act_during = clip_data(data_act, time_sleep(j), time_wake(j));
        data_act_after = clip_data(data_act, time_wake(j), time_wake(j)+window_awake);
        
        data_lgt_before = clip_data(data_lgt, time_sleep(j)-window_awake, time_bed(j));
        data_lgt_during = clip_data(data_lgt, time_sleep(j), time_wake(j));
        data_lgt_after = clip_data(data_lgt, time_wake(j), time_wake(j)+window_awake);

        data_aud_before = clip_data(data_aud, time_sleep(j)-window_awake, time_bed(j));
        data_aud_during = clip_data(data_aud, time_sleep(j), time_wake(j));
        data_aud_after = clip_data(data_aud, time_wake(j), time_wake(j)+window_awake);

        data_scr_before = clip_data(data_scr, time_sleep(j)-window_awake, time_bed(j));
        data_scr_during = clip_data(data_scr, time_sleep(j), time_wake(j));
        data_scr_after = clip_data(data_scr, time_wake(j), time_wake(j)+window_awake);

        data_loc_before = clip_data(data_loc, time_sleep(j)-window_awake, time_bed(j));
        data_loc_during = clip_data(data_loc, time_sleep(j), time_wake(j));
        data_loc_after = clip_data(data_loc, time_wake(j), time_wake(j)+window_awake);
        
        data_bat_before = clip_data(data_bat, time_sleep(j)-window_awake, time_bed(j));
        data_bat_during = clip_data(data_bat, time_sleep(j), time_wake(j));
        data_bat_after = clip_data(data_bat, time_wake(j), time_wake(j)+window_awake);

        data_wif_before = clip_data(data_wif, time_sleep(j)-window_awake, time_bed(j));
        data_wif_during = clip_data(data_wif, time_sleep(j), time_wake(j));
        data_wif_after = clip_data(data_wif, time_wake(j), time_wake(j)+window_awake);
        
        int = {'before', 'during', 'after'};
        
        for k = 1:length(int),

            eval(sprintf('data_int = {data_act_%s, data_lgt_%s, data_aud_%s, data_scr_%s, data_loc_%s, data_bat_%s, data_wif_%s};', ...
                int{k}, int{k}, int{k}, int{k}, int{k}, int{k}, int{k}));
            
            % proceed if light data is available
            if sum(cellfun(@(x) isempty(x{2}), data_int))==0,
                
                data_int = combine_and_window(data_int, window_sensor);
                
                ft = [cell2mat(cellfun(@(x) (sum(x{1}~='STILL')==0)||isempty(x{1}), data_int, 'uniformoutput', false))',...  %is there only still activity or no activity data?
                    cellfun(@(x) mean(x{2}), data_int)', ... %average light power
                    cellfun(@(x) mean(range(x{2})), data_int)', ...  %range of light power
                    cellfun(@(x) mean(range(x{3})), data_int)', ...  %range of audio power
                    cellfun(@(x) length(x{4}), data_int)', ...   %number of screen on/off
                    cellfun(@(x) var(x{5}), data_int)', ... %variance of distance from mean
                    cellfun(@(x) mode(x{6})>0, data_int)', ... %battery charging?
                    cellfun(@(x) sum(char(mode(x{7}))), data_int)']; ... %dominant wifi name
                
                if extract_workday,
                    ft = [ft, workday(j)*ones(length(data_int),1)];
                end
                
                ft(isnan(ft(:,2)),:) = [];
                ft(isnan(ft(:,3)),:) = [];
                ft(isnan(ft(:,4)),:) = [];
                ft(isnan(ft(:,6)),:) = [];
                ft(isnan(ft(:,8)),:) = [];
                
                feature{cnt} = [feature{cnt}; ft];
                
                if strcmp(int{k}, 'during'),
                    state{cnt} = [state{cnt}; 2*ones(size(ft,1),1)];
                else
                    state{cnt} = [state{cnt}; ones(size(ft,1),1)];
                end
            end

        end

    end
    
    if size(feature{cnt},1)<=1,
        continue;
    end
    if length(unique(state{cnt}))<2,
        continue;
    end
    
    cnt = cnt+1;
    
end

if save_results,
    if extract_workday,
        save('features_sleep_workdayinfo.mat', 'feature', 'state');
    else
        save('features_sleep.mat', 'feature', 'state');
    end
end
