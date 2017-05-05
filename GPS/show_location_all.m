clear;
close all;

addpath('../Functions/');

data_dir = '/data/CS120/';

folders = dir(data_dir);
folders(1:2) = [];
cnt = 0;
for i=1:length(folders),
    
    filename = [data_dir, folders(i).name, '/fus.csv'];
    if exist(filename, 'file'),
        tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
        cnt = cnt+1;
        lat(cnt) = tab.Var2(1);
        lng(cnt) = tab.Var3(1);
    else
        fprintf('%s does not have GPS data\n',folders(i).name);
    end
    
end

plot(lng, lat, '.','color',[1 .3 .3], 'markersize', 10);
plot_google_map('MapType', 'satellite');
set(gca, 'xtick', []);
set(gca, 'ytick', []);