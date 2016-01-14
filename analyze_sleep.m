clear;
close all;

runtype = 'wake'; %'bed', 'sleep', 'wake', 'up'

win_size = 60; % +=minutes

addpath('functions');

load('settings.mat');

for i = 1:length(subjects),
    
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
    
    eval(['time = time_', runtype, ';']);
    
    filename = [data_dir, subjects{i}, '\scr.csv'];
    if ~exist(filename, 'file'),
        disp(['No screen data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%s', 'delimiter', '\t');
    data{1} = data{1} + time_zone*3600;
    fclose(fid);
    
    for j = 1:length(time),
       
        time_start = time(j) - win_size*60;
        time_end = time(j) + win_size*60;
        
        ind = find((data{1}>=time_start)&(data{1}<=time_end));
        scr_time{i}{j} = data{1}(ind) - time(j);
        scr_state{i}{j} = data{2}(ind);
        
    end
    
end

% now plotting
figure;
hold on;

cnt = 0;
% colors = lines(length(subjects));
colors = zeros(length(subjects),3);
for i = 1:length(subjects),
    
    for j = 1:length(scr_time{i}),
        
        if ~isempty(scr_state{i}{j}),
            
            cnt = cnt+1;
            
%             if strcmp(scr_state{i}{j}(1),'False'),
%                 plot([-win_size*60 scr_time{i}{j}(1)],[cnt cnt], 'color', colors(i,:));
%             end
%             if strcmp(scr_state{i}{j}(end),'True'),
%                 plot([scr_time{i}{j}(end) win_size*60],[cnt cnt], 'color', colors(i,:));
%             end
            
            for k = 1:length(scr_state{i}{j})-1,
                
                if strcmp(scr_state{i}{j}(k),'True')&&strcmp(scr_state{i}{j}(k+1),'False'),
                    plot([scr_time{i}{j}(k) scr_time{i}{j}(k+1)],[cnt cnt], 'color', colors(i,:));
                end
            end
            
        end
        
    end
    
end

plot([0 0], [0 cnt], 'k');