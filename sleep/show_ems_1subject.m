clear;
close all;

addpath('../Functions/');
load('../settings.mat');

subject = '765488';

data_dir = '/data/CS120';

tab = readtable([data_dir, '\', subject, '\ems.csv'],'readvariablenames',false,'delimiter','\t');

timestamp = tab.Var1 + time_zone*3600;
time_bed = tab.Var2/1000 + time_zone*3600;
time_sleep = tab.Var3/1000 + time_zone*3600;
time_wake = tab.Var4/1000 + time_zone*3600;
time_up = tab.Var5/1000 + time_zone*3600;

h=figure(1);
set(h,'position',[4         316        1671         420]);
hold on;
plot(timestamp, 1*ones(size(tab,1),1), '.','markersize',10);
plot(time_bed, 2*ones(size(tab,1),1), '.','markersize',10);
plot(time_sleep, 3*ones(size(tab,1),1), '.','markersize',10);
plot(time_wake, 4*ones(size(tab,1),1), '.','markersize',10);
plot(time_up, 5*ones(size(tab,1),1), '.','markersize',10);
ylim([0 6]);
set_date_ticks(gca, 1);
set(gca,'ytick',1:5,'yticklabel',{'timestamp','bed','sleep','wake','up'});
set(gca,'xgrid','on');

figure(2);
subplot 211;
histogram((time_wake-time_sleep)/3600,24);
xlabel('sleep duration');

h = figure(3);
set(h,'position',[40         300        1397         308]);
d0 = floor(time_sleep(1)/86400);
plot(floor(time_sleep/86400)-d0, mod(time_sleep,86400)/3600, '.b','markersize',10);
hold on;
plot(floor(time_wake/86400)-d0, mod(time_wake,86400)/3600, '.r','markersize',10);
xlabel('day');
ylabel('hour');
ylim([0 24]);
set(gca,'ydir','reverse');

% after correction
[timestamp, time_bed, time_sleep, time_wake, time_up] = correct_reported_times(timestamp, time_bed, time_sleep, time_wake, time_up);

figure(1);
plot(timestamp, 1*ones(length(time_bed),1), 'o','markersize',10);
plot(time_bed, 2*ones(length(time_bed),1), 'o','markersize',10);
plot(time_sleep, 3*ones(length(time_sleep),1), 'o','markersize',10);
plot(time_wake, 4*ones(length(time_wake),1), 'o','markersize',10);
plot(time_up, 5*ones(length(time_up),1), 'o','markersize',10);

figure(2);
subplot 212;
histogram((time_wake-time_sleep)/3600,24);
xlabel('sleep duration - after correction');

figure(3);
plot(floor(time_sleep/86400)-d0,mod(time_sleep,86400)/3600,'ob','markersize',10);
plot(floor(time_wake/86400)-d0,mod(time_wake,86400)/3600,'or','markersize',10);
legend('sleep time','wake-up time','sleep time (corrected)','wake-up time (corrected)');
