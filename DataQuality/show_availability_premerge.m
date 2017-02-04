clear;
close all;

addpath('../functions/');
data_dir = 'C:\Users\cbits\Dropbox\Data\CS120_premerge\';
sensors = {'act','app','aud','bat','cal','coe','emc','eml','emm','ems','fus','lgt','run','scr','tch','wif'};

subject = 'HI713WB';

map = readtable('C:\Users\cbits\Dropbox\Code\Python\PG2CSV_CS120\subject_info_cs120_extended2.csv', 'delimiter', '\t', 'readvariablenames', false);
inds = find(strcmp(map.Var1, subject));

h = figure;
set(h,'position', [102         103        1443         835]);
colors = lines(length(inds));

for i=1:length(inds),
    
    id{i} = map.Var2{inds(i)};
    for j=1:length(sensors),
        filename = [data_dir, map.Var2{inds(i)}, '/', sensors{j}, '.csv'];
        subplot(length(sensors),1,j);
        ylabel(sensors{j});
        set(gca, 'ytick', []);
        hold on;
        if exist(filename, 'file'),
            tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
            if 0,%strcmp(sensors{j},'fus'),
                plot(tab.Var1, tab.Var2, '.', 'color', colors(i,:), 'markersize', 10);
            else
                ylim([0 length(inds)+1]);
                plot(tab.Var1, i*ones(length(tab.Var1),1), '.', 'color', colors(i,:), 'markersize', 10);
            end
            set_date_ticks(gca, 7);
        else
            ylim([0 length(inds)+1]);
            xrng = xlim;
            text(xrng(2), i, 'no file', 'color', colors(i,:), 'fontweight', 'bold');
        end
        
    end
    
end

legend(id, 'fontsize', 14);