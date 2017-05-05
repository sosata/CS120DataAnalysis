clear;
close all;

load_results = true;

addpath('../functions');

data_dir = '/data/CS120/';

folders = dir(data_dir);
folders(1:2) = [];

if load_results,
    load('data_availability_coe.mat');
else
    
    for i=1:length(folders),
        subject = folders(i).name;
        
        % estimating sensor times
        filename = [data_dir, subject, '/coe.csv'];
        if exist(filename,'file'),
            tab = readtable(filename, 'delimiter','\t','readvariablenames',false);
            time{i} = tab.Var1;
        end
        
        
    end
    
    save('data_availability_coe.mat', 'time');
    
end

h = figure
set(h,'position',[560         528        1105         420])
hold on
for i=1:length(time)
    plot(time{i}, i*ones(length(time{i}),1), '.')
end
set_date_ticks(gca, 7);
axis tight
xlabel('time')
ylabel('subjects')