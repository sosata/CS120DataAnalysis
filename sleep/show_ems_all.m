clear;
close all;

addpath('../Functions/');
load('features_sleepdetection');

data_dir = 'C:\Users\Sohrob\Dropbox\Data\CS120';

sleep_duration_all = [];
for i=1:length(subject_sleep),
    tab = readtable([data_dir, '\', subject_sleep{i}, '\ems.csv'],'readvariablenames',false,'delimiter','\t');
    
    sleep_duration_all = [sleep_duration_all; (tab.Var4-tab.Var3)/1000/3600];
    sleep_dur{i} = (tab.Var4-tab.Var3)/1000/3600;
    time{i} = tab.Var1;
end

figure;
histogram(sleep_duration_all);

h = figure;
set(h,'position',[124         167        1049         420]);
hold on;
for i=1:length(sleep_dur),
    plot(time{i},sleep_dur{i},'.','markersize',8);
end
set_date_ticks(gca, 7);
ylabel('sleep duration');
xlabel('date');