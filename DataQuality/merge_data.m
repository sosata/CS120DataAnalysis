% This function receives data from multiple sources in table format and merges them into one table.
% If tables overlap in less than 1% of their total number of samples, the second set of samples is ignored

clear;
close all;

addpath('../functions/');
data_dir = 'C:\Users\cbits\Dropbox\Data\CS120_premerge\';
data_out = 'C:\Users\cbits\Dropbox\Data\CS120\';

sensors = {'act','app','aud','bat','cal','coe','emc','eml','emm','ems','fus','lgt','run','scr','tch','wif'};

subject = 'HI713WB';

map = readtable('C:\Users\cbits\Dropbox\Code\Python\PG2CSV_CS120\subject_info_cs120_extended2.csv', 'delimiter', '\t', 'readvariablenames', false);
inds = find(strcmp(map.Var1, subject));

data_out = [data_out, subject, '\'];
if ~exist(data_out,'dir'),
    mkdir(data_out);
end

for i=1:length(sensors),
    
    tab = {};
    time_start = [];
    cnt = 1;
    for j=1:length(inds),
        
        id = map.Var2{inds(j)};
        filename = [data_dir, id, '/', sensors{i}, '.csv'];
        
        if exist(filename, 'file'),
            tab{cnt} = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
            time_start(cnt) = tab{cnt}.Var1(1);
            cnt = cnt+1;
        else
            disp(['sensor ',sensors{i},' does not exist']);
        end
        
    end
    

    if length(tab)>0,
        [~, order] = sort(time_start);
        tab = tab(order);
        time_start = time_start(order);
        
        if length(tab)==1,
            tab_all = tab{1};
        elseif length(tab)==2,
            tab_all = vertcat(tab{1},tab{2});
        elseif length(tab)==3,
            tab_all = vertcat(tab{order(1)},tab{order(2)},tab{order(3)});
        else
            disp('number of devices should be either 1, 2 or 3');
        end
        
        filename = [data_out, sensors{i}, '.csv'];
        writetable(tab_all, filename, 'delimiter', '\t', 'writevariablenames', false);
    end
    
end