clear;

addpath('../Functions/');
load('../settings.mat');

subject = 'FJ227MJ';

data_dir = 'C:\Users\Sohrob\Dropbox\Data\CS120';

tab = readtable([data_dir, '\', subject, '\ems.csv'],'readvariablenames',false,'delimiter','\t');

timestamp = tab.Var1 + time_zone*3600;
time_bed = tab.Var2/1000 + time_zone*3600;
time_sleep = tab.Var3/1000 + time_zone*3600;
time_wake = tab.Var4/1000 + time_zone*3600;
time_up = tab.Var5/1000 + time_zone*3600;

h=figure(1);
set(h,'position',[4         316        1671         420]);
hold on;
plot(time_bed, 1*ones(size(tab,1),1), '.','markersize',10);
plot(time_sleep, 2*ones(size(tab,1),1), '.','markersize',10);
plot(time_wake, 3*ones(size(tab,1),1), '.','markersize',10);
plot(time_up, 4*ones(size(tab,1),1), '.','markersize',10);
ylim([0 5]);
set_date_ticks(gca, 2);
set(gca,'ytick',1:4,'yticklabel',{'bed','sleep','wake','up'});

figure(2);
subplot 211;
histogram((time_wake-time_sleep)/3600,24);
xlabel('sleep duration');

% after correction
[timestamp, time_bed, time_sleep, time_wake, time_up] = correct_reported_times(timestamp, time_bed, time_sleep, time_wake, time_up);

figure(1);
plot(time_bed, 1*ones(length(time_bed),1), 'o','markersize',10);
plot(time_sleep, 2*ones(length(time_sleep),1), 'o','markersize',10);
plot(time_wake, 3*ones(length(time_wake),1), 'o','markersize',10);
plot(time_up, 4*ones(length(time_up),1), 'o','markersize',10);

figure(2);
subplot 212;
histogram((time_wake-time_sleep)/3600,24);
xlabel('sleep duration - after correction');
