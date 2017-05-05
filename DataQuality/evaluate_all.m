clear;
close all;

addpath('functions');
load('settings.mat');
load('time_senddata.mat');

show = false;
funcs = {'activity', 'audio', 'communication', 'light', 'location', 'screen', 'touch', 'wifi', 'ema', 'sleep', 'selflocation', 'selfcommunication'};

logs = sprintf('From %s to %s\n=====================\n\n', datestr(date_start+datenum(1970,1,1),6), ...
    datestr(date_end+datenum(1970,1,1),6));

for i = 1:length(subjects),
    
    if isinf(timestamp_senddata(i)),
        visual(i,:,:) = ones(length(funcs),1)*[.5 .5 .5];
        continue;
    end
    
    visual(i,:,:) = ones(length(funcs),1)*[0 1 0];

    logs = [logs, sprintf('\n--------------\n')];
    logs = [logs, sprintf('Subject %s', subjects{i})];
    logs = [logs, sprintf('\n--------------\n')];
    
    for j = 1:length(funcs),
        eval(['warning_log = evaluate_',funcs{j},'(subjects{i}, show);']);
        if ~isempty(warning_log),
            logs = [logs, '*', funcs{j}, sprintf('\n')];
            logs = [logs, warning_log];
            logs = [logs, sprintf('\n')];
            if strcmp(warning_log, sprintf('no csv file\n')),
                visual(i,j,:) = [0 0 0];
            elseif ~isempty(strfind(warning_log, 'missing')),
                visual(i,j,:) = [1 0 0];
            elseif ~isempty(strfind(warning_log, 'complete')),
                color = sscanf(warning_log, '%*s%d', [1 inf]);
                visual(i,j,:) = [1-(color/100) color/100 0];
            elseif ~isempty(strfind(warning_log, 'range')),
                visual(i,j,:) = [0 0 1];
            elseif ~isempty(strfind(warning_log, 'gap')),
                visual(i,j,:) = [1 1 0];
            end
        end
    end
    
end

fid = fopen('log_matlab.txt','w');
fprintf(fid, '%s', logs);
fclose(fid);

disp(['Number of subjects: ', num2str(length(subjects))]);
disp(['Data available: ', num2str(sum(~isinf(timestamp_senddata)))]);

h = figure(1);
set(h, 'position', [680          0         650        1400]);
imagesc(visual);
set(gca, 'ytick', 1:length(subjects), 'yticklabel', subjects);
set(gca, 'xtick', 1:length(funcs), 'xticklabel', cellfun(@(x) x(1:min(end,6)), funcs, 'uniformoutput', false));
set(gca, 'fontsize', 6);
title(['From ' datestr(date_start+datenum(1970,1,1),6) ' to ' datestr(date_end+datenum(1970,1,1),6)]);
