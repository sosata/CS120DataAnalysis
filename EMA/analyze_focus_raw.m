clear;
close all;

addpath('functions');
load('settings.mat');

win_size = 12*3600;
save_results = true;

cnt = 1;
for i = 1:length(subjects),
    
    % loading focus data
    filename = [data_dir, subjects{i}, '\emm.csv'];
    if ~exist(filename, 'file'),
        disp(['No focus data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%f%f%f%f', 'delimiter', '\t');
    fclose(fid);
    time = data{1} + time_zone*3600;
    focus = data{5};
    
    % loading location data
    filename = [data_dir, subjects{i}, '\fus.csv'];
    if ~exist(filename, 'file'),
        disp(['No location data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data_loc = textscan(fid, '%f%f%f%f%f', 'delimiter', '\t');
    fclose(fid);
    data{1} = data{1} + time_zone*3600;
    for j = 1:length(time),
        data_loc_clipped = clip_data(data_loc, time(j)-win_size, time(j));
        time_loc{cnt}{j} = data_loc_clipped{1}-time(j)+win_size;
        input{cnt}{j}(1,:) = data_loc_clipped{2};
        input{cnt}{j}(2,:) = data_loc_clipped{3};
        output{cnt}(j) = focus(j);
    end
    cnt = cnt+1;
    
end

%% cleaning and interpolation
for i = 1:length(input),
    cnt = 1;
    for j = 1:length(input{i})
        if size(input{i}{j},2)>2,
            for k=1:size(input{i}{j},1),
                input_new{i}{cnt}(k,:) = interp1(time_loc{i}{j}, input{i}{j}(k,:), 0:300:win_size, 'linear', 'extrap');
            end
            output_new{i}(cnt) = output{i}(j);
            cnt = cnt+1;
        end
    end
end
input = input_new;
output = output_new;
clear input_new output_new;

%% creating training and test datasets

split = round(length(input)*.9);

input_train = [];
output_train = [];
for i=1:split,
    for j=1:length(input{i}),
        input_train = [input_train; input{i}{j}(1,:)];
    end
    output_train = [output_train; output{i}'];
end

input_test = [];
output_test = [];
for i=(split+1):length(input),
    for j=1:length(input{i}),
        input_test = [input_test; input{i}{j}(1,:)];
    end
    output_test = [output_test; output{i}'];
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
    save('location_focus.mat', 'input_train', 'input_test', 'output_train', 'output_test');
end
