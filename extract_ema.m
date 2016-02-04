%% This function calculates daily averages of each self-reported variable

clear;
close all;

save_results = true;

addpath('functions');

load('settings.mat');

cnt = 1;
for i = 1:length(subjects),
    
    fprintf('%d/%d\n',i,length(subjects));

    % loading data
    filename = [data_dir, subjects{i}, '\emm.csv'];
    if ~exist(filename, 'file'),
        disp(['No sleep data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%f%f%f%f%d%s', 'delimiter', '\t');
    fclose(fid);
    data{1} = data{1} + time_zone*3600;
    
    t_start = floor(data{1}(1)/86400)*86400;
    t_end = floor(data{1}(end)/86400)*86400;
    
    time_ema{cnt} = [];
    mood{cnt} = [];
    calm{cnt} = [];
    energy{cnt} = [];
    focus{cnt} = [];
    
    for t = t_start:86400:t_end,
        
        data_clp = clip_data(data, t, t+86400);
        
        if ~isempty(data_clp{1}),
            time_ema{cnt} = [time_ema{cnt}; t];
            mood{cnt} = [mood{cnt}; mean(data_clp{3})];
            calm{cnt} = [calm{cnt}; mean(data_clp{2})];
            energy{cnt} = [energy{cnt}; mean(data_clp{4})];
            focus{cnt} = [focus{cnt}; mean(data_clp{5})];
        end
        
    end
    
    if isempty(time_ema{cnt}),
        continue;
    end
    
    subject_ema{cnt} = subjects{i};
    
    cnt = cnt+1;
    
end

if save_results,
    save('ema.mat', 'subject_ema', 'time_ema', 'mood', 'calm', 'energy', 'focus');
end
