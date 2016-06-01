clear;
close all;

addpath('../Functions/');
load('features_sleepdetection');
load('../settings.mat');

data_dir = 'C:\Users\Sohrob\Dropbox\Data\CS120';

sleep_duration_all = [];
sleep_time_all = [];
for i=1:length(subject_sleep),
    tab = readtable([data_dir, '\', subject_sleep{i}, '\ems.csv'],'readvariablenames',false,'delimiter','\t');
    
    sleep_duration_all = [sleep_duration_all; (tab.Var4-tab.Var3)/1000/3600];
    sleep_time_all = [sleep_time_all; mod(tab.Var4/1000+time_zone*3600,24*3600)/3600];
    
    sleep_dur{i} = (tab.Var4-tab.Var3)/1000/3600;
    time{i} = tab.Var1;
end

% figure;
% histogram(sleep_duration_all);

figure;
histogram(sleep_time_all,24);
xlim([0 24]);

h = figure;
set(h,'position',[124         167        1049         420]);
hold on;
for i=1:length(sleep_dur),
    plot(time{i},sleep_dur{i},'.','markersize',8);
end
set_date_ticks(gca, 7);
ylabel('sleep duration');
xlabel('date');