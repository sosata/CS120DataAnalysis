clear;
close all;

plot_results = true;

load('settings.mat');

if plot_results,
    h = figure;
    set(h, 'position', [560   528   847   420]);
    hold on;
end
cnt = 1;
for i=1:length(subjects),
    filename = [data_dir, subjects{i}, '\emm.csv'];
    if exist(filename),
        tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
        complete_ema(cnt) = size(tab,1)/((floor(tab.Var1(end)/86400)-floor(tab.Var1(1)/86400)+1)*3);
        if plot_results,
            plot(tab.Var1, cnt*ones(size(tab,1),1), '.');
        end
        cnt = cnt+1;
    end
end
if plot_results,
    set_date_ticks(gca, 7);
    ylabel('subjects');
    title('EMA');
end

if plot_results,
    h = figure;
    set(h, 'position', [554   135   859   420]);
    hold on;
end
cnt = 1;
for i=1:length(subjects),
    filename = [data_dir, subjects{i}, '\ems.csv'];
    if exist(filename),
        tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
        complete_sleep(cnt) = size(tab,1)/(floor(tab.Var1(end)/86400)-floor(tab.Var1(1)/86400)+1);
        if plot_results,
            plot(tab.Var1, cnt*ones(size(tab,1),1), '.');
        end
        cnt = cnt+1;
    end
end
if plot_results,
    set_date_ticks(gca, 7);
    ylabel('subjects');
    title('Sleep');
end

fprintf('EMA %.1f%% complete\n', mean(complete_ema)*100);
fprintf('Sleep %.1f%% complete\n', mean(complete_sleep)*100);
