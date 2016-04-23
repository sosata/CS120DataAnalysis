clear;
close all;

extract_workday = true;

addpath('../functions');
load('../settings.mat');

probes = {'ems','fus','lgt','aud','act','scr','bat','wif'};

window_awake = 6*3600;  % time window before sleep and after wake to be considered as awake
window_sensor = 10*60;
overlap = 0;

save_results = true;

cnt = 1;
for i = 1:length(subjects),
    
    fprintf('%d/%d\n', i, length(subjects));
    
    % loading data
    empty_probe = false;
    for p = 1:length(probes),
        filename = [data_dir, subjects{i}, '/', probes{p}, '.csv'];
        if ~exist(filename, 'file'),
            disp(['No ', probes{p}, ' data for ', subjects{i}]);
            empty_probe = true;
            continue;
        end
        data.(probes{p}) = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
        data.(probes{p}).Var1 = data.(probes{p}).Var1 + time_zone*3600;
    end
    
    % skip if one of the probes is empty
    if empty_probe,
        continue;
    end
    
    % times are in ms
    time_bed = data.ems.Var2/1000 + time_zone*3600;
    time_sleep = data.ems.Var3/1000 + time_zone*3600;
    time_wake = data.ems.Var4/1000 + time_zone*3600;
    time_up = data.ems.Var5/1000 + time_zone*3600;
    
    if extract_workday,
        workday = categorical(data.ems.Var7);
        workday_new = zeros(length(workday),1);
        workday_new(workday=='off') = 0;
        workday_new(workday=='partial') = 1;
        workday_new(workday=='normal') = 2;
        workday = workday_new;
    end
    
    % sorting second columns which will be used for feature extraction
    data.fus.Var2 = sqrt((data.fus.Var2-mean(data.fus.Var2)).^2+(data.fus.Var3-mean(data.fus.Var3)).^2);
    data.act.Var2 = categorical(cellfun(@(x) x(x~='_'), data.act.Var2, 'uniformoutput', false));
    data.scr.Var2 = categorical(data.scr.Var2);
    data.bat.Var2 = data.bat.Var3;
    data.wif.Var2 = categorical(data.wif.Var2);
    
    feature{cnt} = [];
    state{cnt} = [];
    
    for j = 1:length(time_bed),
        
        for p = 1:length(probes),
            data.before.(probes{p}) = clip_data(data.(probes{p}), time_sleep(j)-window_awake, time_bed(j));
            data.during.(probes{p}) = clip_data(data.(probes{p}), time_sleep(j), time_wake(j));
            data.after.(probes{p}) = clip_data(data.(probes{p}), time_wake(j), time_wake(j)+window_awake);
        end
        
        period = {'before', 'during', 'after'};
        
        for k = 1:length(period),

            data_int = {data.(period{k}).act, data.(period{k}).lgt, data.(period{k}).aud, data.(period{k}).scr, data.(period{k}).fus, data.(period{k}).bat, data.(period{k}).wif};
            
            % proceed if light data is available
            if sum(cellfun(@(x) isempty(x.Var2), data_int))==0,
                
                % only second columns remain (as single columns) after applying this function
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
                
                if strcmp(period{k}, 'during'),
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
