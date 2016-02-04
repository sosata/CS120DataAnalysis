clear;
close all;

addpath('functions');
addpath('features');

load('settings.mat');

slsh = '/';

cnt = 1;
for i = 1:length(subjects),
    
    % loading emc data
    filename = [data_dir, subjects{i}, slsh, 'emc2.csv'];
    if ~exist(filename, 'file'),
        disp(['No contact self-report data for ', subjects{i}]);
        continue;
    end
    data_emc = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
    self_time{cnt} = data_emc.Var1 + time_zone*3600;
    self_contact{cnt} = data_emc.Var4;
    clear data_ema;

    %loading communication events data
    filename = [data_dir, subjects{i}, slsh, 'coe.csv'];
    if ~exist(filename, 'file'),
        disp(['No communication data for ', subjects{i}]);
        continue;
    end
    data_coe = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
    comm_time{cnt} = data_coe.Var1 + time_zone*3600;
    comm_contact{cnt} = data_coe.Var3;
    clear data_coe;
    
    cnt=cnt+1;

end

% figure;
% hold on;
for i=1:cnt-1,
    match(i) = 0;
    for j=1:length(self_contact{i}),
        if sum(ismember(comm_contact{i},self_contact{i}(j)))>0,
            match(i) = match(i)+1;
%             plot(comm_time{i}(j), i, '.b', 'markersize', 10);
        else
%             plot(comm_time{i}(j), i, '.r', 'markersize', 10);
        end
    end
    match(i) = match(i)/length(self_contact{i});
end
mean(match)