clear;
close all;

addpath('functions');
addpath('features');

load('settings.mat');

cnt = 1;
for i = 1:length(subjects),
    
    % loading emc data
    filename = [data_dir, subjects{i}, '\emc.csv'];
    if ~exist(filename, 'file'),
        disp(['No contact self-report data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data_emc = textscan(fid, '%f%s%s%d%d%d%d', 'delimiter', '\t');
    fclose(fid);
    self_time{cnt} = data_emc{1} + time_zone*3600;
    self_contact{cnt} = data_emc{2};
    clear data_ema;

    %loading communication events data
    filename = [data_dir, subjects{i}, '\coe.csv'];
    if ~exist(filename, 'file'),
        disp(['No communication data for ', subjects{i}]);
        continue;
    end
    fid = fopen(filename, 'r');
    data_coe = textscan(fid, '%f%s%s%s%s', 'delimiter', '\t');
    fclose(fid);
    comm_time{cnt} = data_coe{1} + time_zone*3600;
    comm_contact{cnt} = data_coe{3};
    clear data_coe;
    
    cnt=cnt+1;

end

for i=1:cnt-1,
    len_dif = length(setdiff(unique(self_contact{i}),unique(comm_contact{i})));
    len = max(length(unique(comm_contact{i})),length(unique(self_contact{i})));
    fprintf('%d %.f%% match \n',i,(len-len_dif)/len*100);
    
end