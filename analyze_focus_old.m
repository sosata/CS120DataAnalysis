clear;
close all;

addpath('functions\');
load('settings.mat');

time = [];
value = [];

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
    time = [time; data{1} + time_zone*3600];
    value = [value; data{2}];
end

%% population daily
h = figure;
set(h, 'position', [130    0    1180    600]);
subplot 211;
plot(time, value, '.');
set_date_ticks(gca, 1);
subplot 212;
hold on;
for t = min(time):86400:max(time),
    ind = find((time>=t)&(time<t+86400));
    plot(t, mean(value(ind)), '.k', 'markersize', 14);
end
plot(xlim, [mean(value) mean(value)], '--');
set_date_ticks(gca, 1);

%% population distribution
figure;
hist(value, 0:8);
title(sprintf('avg: %.2f\nskewness: %.2f\nGaussian? %d',mean(value),skewness(value), 1-kstest(value)));


%% time of the day distribution
ind_night = find(mod(time,86400)<6*3600);
ind_morning = find((mod(time,86400)>=6*3600)&(mod(time,86400)<12*3600));
ind_afternoon = find((mod(time,86400)>=12*3600)&(mod(time,86400)<18*3600));
ind_evening = find((mod(time,86400)>=18*3600));

figure;
subplot 221;
hist(value(ind_morning), 0:8);
title(sprintf('avg: %.2f\nskewness: %.2f\nGaussian? %d',mean(value(ind_morning)),skewness(value(ind_morning)), 1-kstest(value(ind_morning))));
ylabel('morning');
subplot 222;
hist(value(ind_afternoon), 0:8);
title(sprintf('avg: %.2f\nskewness: %.2f\nGaussian? %d',mean(value(ind_afternoon)),skewness(value(ind_afternoon)), 1-kstest(value(ind_afternoon))));
ylabel('afternoon');
subplot 223;
hist(value(ind_evening), 0:8);
title(sprintf('avg: %.2f\nskewness: %.2f\nGaussian? %d',mean(value(ind_evening)),skewness(value(ind_evening)), 1-kstest(value(ind_evening))));
ylabel('evening');
subplot 224;
hist(value(ind_night), 0:8);
title(sprintf('avg: %.2f\nskewness: %.2f\nGaussian? %d',mean(value(ind_night)),skewness(value(ind_night)), 1-kstest(value(ind_night))));
ylabel('night');
ylim([0 600]);

%% day of the week distribution
ind_mon = find(strcmp(cellstr(datestr(time/86400+datenum(1970,1,1),8)),'Mon'));
ind_tue = find(strcmp(cellstr(datestr(time/86400+datenum(1970,1,1),8)),'Tue'));
ind_wed = find(strcmp(cellstr(datestr(time/86400+datenum(1970,1,1),8)),'Wed'));
ind_thu = find(strcmp(cellstr(datestr(time/86400+datenum(1970,1,1),8)),'Thu'));
ind_fri = find(strcmp(cellstr(datestr(time/86400+datenum(1970,1,1),8)),'Fri'));
ind_sat = find(strcmp(cellstr(datestr(time/86400+datenum(1970,1,1),8)),'Sat'));
ind_sun = find(strcmp(cellstr(datestr(time/86400+datenum(1970,1,1),8)),'Sun'));

h = figure;
set(h, 'position', [318.6000  245.0000  622.4000  420.0000]);
subplot 331;
hist(value(ind_mon), 0:8);
title(sprintf('avg: %.2f', mean(value(ind_mon))));
ylim([0 400]);
xlim([-1 9]);
ylabel('mon');
subplot 332;
hist(value(ind_tue), 0:8);
title(sprintf('avg: %.2f', mean(value(ind_tue))));
ylim([0 400]);
xlim([-1 9]);
ylabel('tue');
subplot 333;
hist(value(ind_wed), 0:8);
title(sprintf('avg: %.2f', mean(value(ind_wed))));
ylim([0 400]);
xlim([-1 9]);
ylabel('wed');
subplot 334;
hist(value(ind_thu), 0:8);
title(sprintf('avg: %.2f', mean(value(ind_thu))));
ylim([0 400]);
xlim([-1 9]);
ylabel('thu');
subplot 335;
hist(value(ind_fri), 0:8);
title(sprintf('avg: %.2f', mean(value(ind_fri))));
ylim([0 400]);
xlim([-1 9]);
ylabel('fri');
subplot 336;
hist(value(ind_sat), 0:8);
title(sprintf('avg: %.2f', mean(value(ind_sat))));
ylim([0 400]);
xlim([-1 9]);
ylabel('sat');
subplot 337;
hist(value(ind_sun), 0:8);
title(sprintf('avg: %.2f', mean(value(ind_sun))));
ylim([0 400]);
xlim([-1 9]);
ylabel('sun');

return;

% chi2 test
var1 = focus(ind_afternoon);
var2 = focus(ind_evening);

expected = [];
observed = [];
for i=0:8,
    expected = [expected, length(var1)*sum([var1;var2]==i)/length([var1;var2]), ...
        length(var2)*sum([var1;var2]==i)/length([var1;var2])];
    observed = [observed, sum(var1==i), sum(var2==i)];
end

chi2stat = sum((observed-expected).^2 ./expected)
p = 1-chi2cdf(chi2stat, 8)