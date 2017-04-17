clear;
close all;

addpath('../Functions/');
load('features_sleepdetection');
load('../settings.mat');

data_dir = '/data/CS120';
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

h = figure;
set(h,'position',[683   244   703   577])
res = 1;
hist_edges = 0:res:24;
hist_centers = (hist_edges(1)+res/2):res:(hist_edges(end)-res/2);
[n, ~] = histcounts(wake_time_all, hist_edges);
plot(hist_centers, n, '--k','linewidth',2)
xlim([0 24]);
hold on
[n, ~] = histcounts(sleep_time_all, hist_edges);
plot(hist_centers, n, 'k','linewidth',2)
box off
set(gca,'fontsize',12)
ylabel('Samples','fontsize',14)
xlabel('Time of Day (hours)','fontsize',14)
set(gca,'xtick',1:24);
l = legend('Sleep End Time','Sleep Start Time','location','north');
set(l,'fontsize',14)
set(gca,'xgrid','on')

return

h = figure;
set(h,'position',[245   252   714   571])
% plot([12 12],[0 25],'linewidth',1,'color',[.5 .5 .5])
% hold on
plot(sleep_time_all, sleep_duration_all, '.k', 'markersize', 7);
% alpha .25;
xlim([0 24]);
set(gca,'fontsize',12)
xlabel('Sleep Time (hours)','fontsize',14);
ylabel('Sleep Duration (hours)','fontsize',14);
box off;
set(gca,'xtick',0:24);
set(gca,'xgrid','on')

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