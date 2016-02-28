% Numbers from emc.csv are matched with coe.csv and then saved in a single
% emc_coe.mat file.

clear;
close all;

slsh = '/';
save_results = true;

addpath('functions');
load('settings.mat');

cnt = 1;

figure; hold on;
cnt2 = 1;
for i = 1:length(subjects),
    
    fprintf('%d/%d\n',i,length(subjects));

    % loading self-report data
    filename = [data_dir, subjects{i}, slsh, 'emc.csv'];
    if ~exist(filename, 'file'),
        disp(['No contact report data for ', subjects{i}]);
        continue;
    end
    data_emc = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
    time_emc = data_emc.Var1 + time_zone*3600;
    numbers_emc = [numbers_emc; data_emc.Var4];
    
    % loading communication data
    filename = [data_dir, subjects{i}, slsh, 'coe.csv'];
    if ~exist(filename, 'file'),
        disp(['No communication data for ', subjects{i}]);
        continue;
    end
    data_coe = readtable(filename, 'delimiter', '\t', 'ReadVariableNames',false);
    time_coe = data_coe.Var1 + time_zone*3600;
%     name_coe = data.Var2;
%     number_coe = data.Var3;
    
    plot(time_coe, (cnt+.2)*ones(length(time_coe),1), '.r');
    plot(time_emc, (cnt-.2)*ones(length(time_emc),1), '.b');
    
%     time_emc_u = unique(time_emc);
%     for j=1:length(time_emc_u),
%         data_emc_clipped = data_emc(time_emc==time_emc_u(j), :);
%         ind = find((time_coe>time_emc_u(j)-86400)&(time_coe<=time_emc_u(j)));
%         data_coe_clipped = data_coe(ind, :);
%         
%         if length(unique(data_emc_clipped.Var4))==length(unique(data_coe_clipped.Var3)),
%             match(cnt2) = 1;
%         else
%             match(cnt2) = 0;
%         end
%         cnt2 = cnt2+1;
%     end


    cnt = cnt+1;
    
end
% mean(match)
set_date_ticks(gca, 7);
ylim([0 length(subjects)+1]);