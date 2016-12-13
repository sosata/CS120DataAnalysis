clear;
close all;

slsh = '/';

save_results = true;

addpath('functions');

load('settings.mat');

cnt = 1;
for i = 1:length(subjects),
    
    fprintf('%d/%d\n',i,length(subjects));

    % loading data
    filename = [data_dir, subjects{i}, slsh, 'eml.csv'];
    if ~exist(filename, 'file'),
        disp(['No location report data for ', subjects{i}]);
        continue;
    end
    data = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
    
    time_eml{cnt} = data.Var1 + time_zone*3600;
    lat{cnt} = data.Var3;
    lng{cnt} = data.Var4;
    name_mob{cnt} = data.Var6;
    category_mob{cnt} = data.Var7;
    reason{cnt} = data.Var8;
    accomplishment{cnt} = data.Var9;
    pleasure{cnt} = data.Var10;
%     category_fs{cnt} = data.Var11;
    
    subject_eml{cnt} = subjects{i};
    
    cnt = cnt+1;
    
end

if save_results,
    save('eml.mat', 'subject_eml', 'time_eml', 'lat', 'lng', 'name_mob', 'category_mob', 'reason', ...
        'accomplishment', 'pleasure');
end
