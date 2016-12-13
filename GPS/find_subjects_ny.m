clear;
close all;

load('settings');

NY_lat = [40.47, 40.92];
NY_lng = [-74.27, -73.73];

CH_lat = [41.65, 42.07];
CH_lng = [-88.01, -87.41];

for i=1:length(subjects),
    
    filename = [data_dir, subjects{i}, '/fus.csv'];
    
    if exist(filename, 'file'),
    
        tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
        
%         40.47 
%         40.92
%         
%         -73.73 
%         -74.27
        cnt = 0;
        for j=1:length(tab.Var2),
            if (tab.Var2(j)>CH_lat(1))&&(tab.Var2(j)<CH_lat(2))&&(tab.Var3(j)>CH_lng(1))&&(tab.Var3(j)<CH_lng(2)),
                cnt = cnt+1;
            end
        end
        
        fprintf('%.f%% in CHI\n', cnt/length(tab.Var2)*100);
    else
        fprintf('No data for %s\n', subjects{i});
    end
end