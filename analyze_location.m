clear;
close all;

load('settings.mat');

cnt = 1;
for i = 1:length(subjects),%[80:115,117:125,127:145,147:length(subjects)],
    
    fprintf('%d/%d\n',i,length(subjects));
    
    % loading focus data
    filename = [data_dir, subjects{i}, '\eml.csv'];
    if ~exist(filename, 'file'),
        disp(['No sleep data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data_ema = textscan(fid, '%f%f%f%f%f%d%s', 'delimiter', '\t');
    fclose(fid);
    data_ema{1} = data_ema{1} + time_zone*3600;

end