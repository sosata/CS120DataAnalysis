clear;
close all;

load_results = true;

addpath('../functions');

data_dir = '/data/CS120/';
% data_dir = 'C:\Data\CS120\';

ema = {'emc','eml','emm','ems'};
sensor = {'act','app','aud','bat','cal','coe','fus','run','scr'};

folders = dir(data_dir);
folders(1:2) = [];

if load_results,
    load('data_availability.mat');
else
    
    time_start_sensor = Inf*ones(length(folders),1);
    time_start_ema = Inf*ones(length(folders),1);
    time_end_sensor = -Inf*ones(length(folders),1);
    time_end_ema = -Inf*ones(length(folders),1);
    
    parfor i=1:length(folders),
        subject = folders(i).name;
        
        % estimating sensor times
        for j=1:length(sensor),
            filename = [data_dir, subject, '/', sensor{j}, '.csv'];
            if exist(filename,'file'),
                tab = readtable(filename, 'delimiter','\t','readvariablenames',false);
                if tab.Var1(1) < time_start_sensor(i),
                    time_start_sensor(i) = tab.Var1(1);
                end
                if tab.Var1(end) > time_end_sensor(i),
                    time_end_sensor(i) = tab.Var1(end);
                end
            end
        end
        
        % estimating ema times
        for j=1:length(ema),
            filename = [data_dir, subject, '/', ema{j}, '.csv'];
            if exist(filename,'file'),
                tab = readtable(filename, 'delimiter','\t','readvariablenames',false);
                if tab.Var1(1) < time_start_ema(i),
                    time_start_ema(i) = tab.Var1(1);
                end
                if tab.Var1(end) > time_end_ema(i),
                    time_end_ema(i) = tab.Var1(end);
                end
            end
        end
        
        % estimating sleep report times
        filename = [data_dir, subject, '/ems.csv'];
        if exist(filename,'file'),
            tab = readtable(filename, 'delimiter','\t','readvariablenames',false);
            time_ems{i} = tab.Var1;
        else
            time_ems{i} = [];
        end
        
    end
    
    save('data_availability.mat', 'time_start_sensor', 'time_end_sensor', 'time_start_ema', 'time_end_ema', 'time_ems');
    
end

% time_start_sensor(isinf(time_start_sensor)) = NaN;
% time_end_sensor(isinf(time_end_sensor)) = NaN;
% time_start_ema(isinf(time_start_ema)) = NaN;
% time_end_ema(isinf(time_end_ema)) = NaN;

[~, ind_sort] = sort(time_start_sensor);
subplot(1,5,[1 4]);
plot([time_start_sensor(ind_sort), time_end_sensor(ind_sort)]',ones(2,1)*(1:length(time_start_sensor)),'k');
ylabel('subjects');
set_date_ticks(gca, 30);
box off;
subplot(1,5,5);
barh(ceil((time_end_sensor(ind_sort)-time_start_sensor(ind_sort))/86400));
xlabel('days');
box off;

figure;
[~, ind_sort] = sort(time_start_ema);
plot([time_start_ema(ind_sort), time_end_ema(ind_sort)]',ones(2,1)*(1:length(time_start_ema)),'k');
ylabel('Subjects');
box off;
set_date_ticks(gca, 30);
axis tight;

figure;
numdays = ceil((time_end_ema(ind_sort)-time_start_ema(ind_sort))/86400);
histogram(numdays, 42);
xlabel('Number of Days in Study');
ylabel('Number of Subjects');
box off

h = figure;
set(h,'position',[360   192   661   563]);
hold on;
ind_empty = find(cellfun(@isempty, time_ems));
time_ems(ind_empty) = [];
[~,ind_sort] = sort(cellfun(@(x) x(1), time_ems));
time_ems = time_ems(ind_sort);
for i=1:length(time_ems)
    plot(time_ems{i}, i*ones(length(time_ems{i}),1),'.k');
end
axis tight;
set_date_ticks(gca, 16);
xlabel('Date','fontsize',16);
ylabel('Subjects','fontsize',16);
box off;