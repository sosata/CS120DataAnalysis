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
sleep_quality_all = [];

for i=1:length(subject_sleep),
    
    filename = [data_dir, '\', subject_sleep{i}, '\ems.csv'];
    
    if exist(filename,'file'),
        tab = readtable(filename,'readvariablenames',false,'delimiter','\t');
        
        ind = find(strcmp(timezones.Var1, subject_sleep{i}));
        time_zone = timezones.Var2(ind);
        
        sleep_duration_all = [sleep_duration_all; (tab.Var4-tab.Var3)/1000/3600];
        sleep_time_all = [sleep_time_all; mod(tab.Var3/1000+time_zone*3600,24*3600)/3600];
        wake_time_all = [wake_time_all; mod(tab.Var4/1000+time_zone*3600,24*3600)/3600];
        sleep_quality_all = [sleep_quality_all; tab.Var6];
        
        sleep_quality{i} = tab.Var6;
        sleep_dur{i} = (tab.Var4-tab.Var3)/1000/3600;
        time{i} = tab.Var1;
    else
        sleep_dur{i} = [];
        time{i} = [];
    end
end

figure;
histogram(sleep_quality_all, -.5:1:8.5);
xlim([-.5 8.5]);
box off
ylabel('Number of Samples')
xlabel('Sleep Quality')

figure;
plot(sleep_duration_all, sleep_quality_all,'.','markersize',8);
xlim([0 24]);
xlabel('sleep duration (hours)');
ylabel('sleep quality (hours)');
title('cross-subject');
box off;
grid on

return;

h = figure;
set(h,'position',[124         167        1049         420]);
hold on;
for i=1:length(sleep_dur),
    plot(time{i},sleep_dur{i},'.','markersize',8);
end
set_date_ticks(gca, 7);
ylabel('sleep duration');
xlabel('date');