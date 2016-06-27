clear;
close all;

addpath('../Functions/');
load('features_sleepdetection');
load('../settings.mat');

data_dir = 'C:\Users\Sohrob\Dropbox\Data\CS120';
timezones = readtable('../general/timezones.csv', 'readvariablenames',false,'delimiter','\t');

sleep_duration_all = [];
sleep_time_all = [];
wake_time_all = [];

for i=1:length(subject_sleep),
    
    filename = [data_dir, '\', subject_sleep{i}, '\ems.csv'];
    
    if exist(filename,'file'),
        tab = readtable(filename,'readvariablenames',false,'delimiter','\t');
        
        ind = find(strcmp(timezones.Var1, subject_sleep{i}));
        time_zone = timezones.Var2(ind);
        
        sleep_duration_all = [sleep_duration_all; (tab.Var4-tab.Var3)/1000/3600];
        sleep_time_all = [sleep_time_all; mod(tab.Var3/1000+time_zone*3600,24*3600)/3600];
        wake_time_all = [wake_time_all; mod(tab.Var4/1000+time_zone*3600,24*3600)/3600];
        
        sleep_dur{i} = (tab.Var4-tab.Var3)/1000/3600;
        time{i} = tab.Var1;
    else
        sleep_dur{i} = [];
        time{i} = [];
    end
end

% figure;
% histogram(sleep_duration_all);

figure;
hs = histogram(wake_time_all, 0:.25:24);
% y = medfilt1(y,3);
% plot(x,y,'linewidth',2,'color',[1 .7 .4]);
% hold on

figure;
hs = histogram(sleep_time_all, 0:1:24);
% y = medfilt1(y,3);
% plot(x,y,'linewidth',2, 'color',[.4 .7 1]);
xlim([0 24]);
box off
ylabel('Number of Samples')
xlabel('Time of Day (hours)')
legend('Wake-up Time','Sleep Time')

figure;
plot(sleep_time_all, sleep_duration_all,'.','markersize',8);
xlim([0 24]);
xlabel('Sleep Time (hours)');
ylabel('Sleep Duration (hours)');
box off;

h = figure;
set(h,'position',[124         167        1049         420]);
hold on;
for i=1:length(sleep_dur),
    plot(time{i},sleep_dur{i},'.','markersize',8);
end
set_date_ticks(gca, 7);
ylabel('sleep duration');
xlabel('date');