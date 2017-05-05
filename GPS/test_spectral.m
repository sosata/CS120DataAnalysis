clear;
close all;

load('settings');

for i=10,
    filename = [data_dir, subjects{i}, '\fus.csv'];
    if exist(filename, 'file'),
        tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
        
        tab = clip_data(tab, tab.Var1(1), tab.Var1(1)+86400*14);
        
        lat = tab.Var2;
        lng = tab.Var3;
        data = [lat, lng];
        data_adj = pdist(data, 'euclidean');
        
    end
end