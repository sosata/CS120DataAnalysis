clear
close all

load('../settings.mat');
addpath('../Functions/');

h = figure
set(h, 'position', [321         392        1104         420])
subplot 211
hold on
subplot 212
hold on
for i=1:length(subjects)
    
    filename = ['availability_temporal/cs120_', subjects{i}, '.csv'];
    if exist(filename,'file')
        tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
        time = tab.Var1;
        aval = tab.Var2;
        
        subplot 211
        plot(time(aval==0), i*ones(sum(aval==0),1), '.k');
        subplot 212
        plot(time(aval==1), i*ones(sum(aval==1),1), '.k');
    end
    
end
subplot 211
axis tight;
set_date_ticks(gca, 7);
title('CS120 - not available');
subplot 212
axis tight;
set_date_ticks(gca, 7);
title('CS120 - available');

h = figure
set(h, 'position', [321         392        1104         420])
subplot 211
hold on
subplot 212
hold on
for i=1:length(subjects)
    
    filename = ['availability_temporal/pr_', subjects{i}, '.csv'];
    if exist(filename,'file')
        tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
        time = tab.Var1;
        aval = tab.Var2;
       
        subplot 211
        plot(time(aval==0), i*ones(sum(aval==0),1), '.k');
        subplot 212
        plot(time(aval==1), i*ones(sum(aval==1),1), '.k');
    end
    
end
subplot 211
axis tight;
set_date_ticks(gca, 7);
title('PR - not available');
subplot 212
axis tight;
set_date_ticks(gca, 7);
title('PR - available');
