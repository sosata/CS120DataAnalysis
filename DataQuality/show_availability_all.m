clear;
close all;

load_results = false;

addpath('../functions');

data_dir = 'C:\Users\sohrob\Dropbox\Data\CS120\';
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
            % due to a problem with this subject's app csv file
%             if strcmp(subject, '4667dacb7f27afd0933bc46dbc07405e')&&j==2,
%                 continue;
%             end
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
        
        
    end
    
    save('data_availability.mat', 'time_start_sensor', 'time_end_sensor', 'time_start_ema', 'time_end_ema');
    
end

% time_start_sensor(isinf(time_start_sensor)) = NaN;
% time_end_sensor(isinf(time_end_sensor)) = NaN;
% time_start_ema(isinf(time_start_ema)) = NaN;
% time_end_ema(isinf(time_end_ema)) = NaN;

subplot(1,5,[1 4]);
plot([time_start_sensor, time_end_sensor]',ones(2,1)*(1:length(folders)),'k');
ylabel('subjects');
set_date_ticks(gca, 7);
box off;
subplot(1,5,5);
barh(ceil((time_end_sensor-time_start_sensor)/86400));
xlabel('days');
box off;

figure;
subplot(1,5,[1 4]);
plot([time_start_ema, time_end_ema]',ones(2,1)*(1:length(folders)),'k');
ylabel('subjects');
box off;
set_date_ticks(gca, 7);
subplot(1,5,5);
barh(ceil((time_end_ema-time_start_ema)/86400));
xlabel('days');
box off;