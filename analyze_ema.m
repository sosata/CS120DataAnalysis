clear;
close all;

addpath('functions\');
addpath('features\');

load('settings.mat');


time = [];
value = [];

%% reading data
cnt = 1;
for i = 1:length(subjects),
    
    % loading focus data
    filename = [data_dir, subjects{i}, '\emm.csv'];
    if ~exist(filename, 'file'),
        disp(['No EMA data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%f%f%f%f', 'delimiter', '\t');
    fclose(fid);
    time{cnt} = data{1} + time_zone*3600;
    value{cnt} = data{3};   % 2:stress, 3:mood, 4:energy, 5:focus
    
    cnt = cnt+1;
end

%% availability
figure;
complete = zeros(length(time),1);
for i=1:length(time),
    subplot(1,4,[1 3]);
    hold on;
    plot(time{i}, i*ones(size(time{i})), '.');
    subplot(1,4,4);
    hold on;
    complete(i) = length(time{i})/floor((time{i}(end)-time{i}(1))/86400)/3*100;
    plot(complete(i), i, '.');
end
subplot(1,4,[1 3]);
set_date_ticks(gca, 7);
grid on;
subplot(1,4,4);
plot(100*ones(length(time),1), 1:length(time), ':k');
xlabel('% complete');

%% distribution of mean
figure;
hist(cellfun(@(x) mean(x), value), 0:.4:8);
xlim([0 8]);

%% completeness vs circadian rhythmicity vs mean
h = figure;
set(h, 'position', [8    352    1329    385]);
subplot 131;
plot_correlation(complete, cellfun(@(x) estimate_circadian_rhythmicity(x, 8*3600), time)', 'spearman');
xlabel('% complete');
ylabel('circadian rhythmicity');subplot 132;
plot_correlation(cellfun(@(x) mean(x), value)', cellfun(@(x) estimate_circadian_rhythmicity(x, 8*3600), time)', 'spearman');
xlabel('mean');
ylabel('circadian rhythmicity');subplot 133;
plot_correlation(complete, cellfun(@(x) mean(x), value)', 'spearman');
xlabel('% complete');
ylabel('mean');

%% range vs mean
figure;
plot_correlation(cellfun(@(x) mean(x), value)', cellfun(@(x) range(x), value)', 'pearson');
xlabel('mean');
ylabel('range');

%% variance vs mean
figure;
plot_correlation(cellfun(@(x) mean(x), value)', cellfun(@(x) var(x), value)', 'pearson');
xlabel('mean');
ylabel('variance');

return;

%% moving average
figure;
for i = [80:115,117:125,127:145,147:length(value)],
   subplot(2,2,mod(i,4)+1);
   hold on;
   tsobj = fints([time{i}/86400+datenum(1970,1,1), value{i}]);
   output = tsmovavg(tsobj, 'e', 21);
   if std(value{i})>1,
       mycolor = 'b';
   else
       mycolor = 'g';
   end
   plot((output.dates+output.times)*86400, fts2mat(output), mycolor);
end
for i=1:4,
    subplot(2,2,i);
    set_date_ticks(gca, 7);
    grid on;
end

%% daily averages
figure;
hold on;
cnt=1;
for i = [80:115,117:125,127:145,147:length(value)],
    t = floor(time{i}(1)/86400)*86400;
    cnt2 = 1;
    while t<=time{i}(end),
       ind = find((time{i}>=t)&(time{i}<t+86400));
       ema{cnt}(cnt2, 1) = t;
       ema{cnt}(cnt2, 2) = mean(value{i}(ind));
       cnt2 = cnt2+1;
       t = t+86400;
    end
    plot(ema{cnt}(:,1),ema{cnt}(:,2));    
    cnt = cnt+1;
end
set_date_ticks(gca, 7);