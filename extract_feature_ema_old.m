clear;
close all;

addpath('functions');
load('settings.mat');

win_size_location = 6*3600;
win_size_screen = 2*3600;

save_results = true;

cnt = 1;
for i = 1:length(subjects),
    
    % loading focus data
    filename = [data_dir, subjects{i}, '\emm.csv'];
    if ~exist(filename, 'file'),
        disp(['No ema data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%f%f%f%f', 'delimiter', '\t');
    fclose(fid);
    time_ema = data{1} + time_zone*3600;
    emm_stress = data{2};
    emm_mood = data{3};
    emm_energy = data{4};
    emm_focus = data{5};
    clear data;
    
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
    
    cnt2 = 1;
    for j = 1:length(time_ema),
        
        % adding location features
        data_clipped = clip_data(data_loc, time_ema(j)-win_size_location, time_ema(j));
        feature{cnt}{cnt2} = var(data_clipped{2})+var(data_clipped{3});
        feature{cnt}{cnt2}(end+1) = mean(data_clipped{2});
        feature{cnt}{cnt2}(end+1) = mean(data_clipped{3});

        % adding screen features
        data_clipped = clip_data(data_scr, time_ema(j)-win_size_screen, time_ema(j));
        feature{cnt}{cnt2}(end+1) = sum(strcmp(data_clipped{2},'True'));
        
        % adding time as a feature
        feature{cnt}{cnt2}(end+1) = mod(time_ema(j), 86400)/3600;
        
        % adding light
        data_clipped = clip_data(data_lgt, time_ema(j)-win_size_screen, time_ema(j));
        feature{cnt}{cnt2}(end+1) = mean(data_clipped{2});

        % adding screen features
        data_clipped = clip_data(data_aud, time_ema(j)-win_size_screen, time_ema(j));
        feature{cnt}{cnt2}(end+1) = mean(data_clipped{2});
        feature{cnt}{cnt2}(end+1) = mean(data_clipped{3});

        stress{cnt}(cnt2) = emm_stress(j);
        mood{cnt}(cnt2) = emm_mood(j);
        energy{cnt}(cnt2) = emm_energy(j);
        focus{cnt}(cnt2) = emm_focus(j);
        time{cnt}(cnt2) = time_ema(j);
        
        cnt2 = cnt2+1;
    end
    
    cnt = cnt+1;
    
end

%% creating training and test datasets

% subj = 16;

split = round(length(feature)*.8);

feature_train = [];
stress_train = [];
mood_train = [];
energy_train = [];
focus_train = [];
time_train = [];
for i=1:split,
    for j=1:length(feature{i}),
        feature_train = [feature_train; feature{i}{j}];
    end
    stress_train = [stress_train; stress{i}'];
    mood_train = [mood_train; mood{i}'];
    energy_train = [energy_train; energy{i}'];
    focus_train = [focus_train; focus{i}'];
    time_train = [time_train; time{i}'];
end

feature_test = [];
stress_test = [];
mood_test = [];
energy_test = [];
focus_test = [];
time_test = [];
for i=(split+1):length(feature),
    for j=1:length(feature{i}),
        feature_test = [feature_test; feature{i}{j}];
    end
    stress_test = [stress_test; stress{i}'];
    mood_test = [mood_test; mood{i}'];
    energy_test = [energy_test; energy{i}'];
    focus_test = [focus_test; focus{i}'];
    time_test = [time_test; time{i}'];
end

%% for compatibility with CNN implementation

% for i=1:length(input_train),
%     input_train{i} = reshape(input_train{i}(1,end-1024+1:end), 32, 32);
% end
% for i=1:length(input_test),
%     input_test{i} = reshape(input_test{i}(1,end-1024+1:end), 32, 32);
% end

%% saving

if save_results,
    save('features_ema.mat', 'feature_train', 'feature_test', 'stress_train', 'stress_test', 'mood_train', 'mood_test', 'energy_train', 'energy_test', 'focus_train', 'focus_test', 'time_train', 'time_test');
end
