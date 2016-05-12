clear;
close all;

addpath('../functions/');

data_dir = 'C:\Users\Sohrob\Dropbox\Data\CS120\';
sensors = {'act','app','aud','bat','cal','coe','emc','eml','emm','ems','fus','lgt','run','scr','tch','wif'};

subject = '856513';

h = figure;
set(h,'position', [657   285   558   287]);
hold on;

for i=1:length(sensors),
    filename = [data_dir, subject, '\', sensors{i}, '.csv'];
    if exist(filename, 'file'),
        tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
        plot(tab.Var1, i*ones(length(tab.Var1),1), '.', 'markersize', 10);
    else
%         xrng = xlim;
%         text(xrng(2), i, 'no file', 'fontweight', 'bold');
    end
    
end
ylim([0 length(sensors)]);
set_date_ticks(gca, 1);
set(gca, 'ytick', 1:length(sensors), 'yticklabel', sensors);
box off;
grid on;
