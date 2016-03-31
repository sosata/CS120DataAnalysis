% Numbers from emc.csv are matched with coe.csv and then saved in a single
% emc_coe.mat file.

clear;
close all;

slsh = '/';
save_results = true;

load('settings.mat');

numbers_emc = {};
numbers_coe = {};

for i = 1:length(subjects),
    
    fprintf('%d/%d\n',i,length(subjects));

    % loading self-report data
    filename = [data_dir, subjects{i}, slsh, 'emc.csv'];
    if ~exist(filename, 'file'),
        disp(['No contact report data for ', subjects{i}]);
    else
        data_emc = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
        numbers_emc = [numbers_emc; data_emc.Var4];
    end
    
    % loading communication data
    filename = [data_dir, subjects{i}, slsh, 'coe.csv'];
    if ~exist(filename, 'file'),
        disp(['No communication data for ', subjects{i}]);
    else
        data_coe = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
        numbers_coe  = [numbers_coe; data_coe.Var3];
    end
    
end

numbers_emc = unique(numbers_emc);
numbers_coe = unique(numbers_coe);

if save_results
    fid = fopen('numbers_mobilyze.csv', 'w');
    for i=1:length(numbers_emc),
        fprintf(fid, '%s\n', numbers_emc{i});
    end
    fclose(fid);
    fid = fopen('numbers_PR.csv', 'w');
    for i=1:length(numbers_coe),
        fprintf(fid, '%s\n', numbers_coe{i});
    end
    fclose(fid);
end