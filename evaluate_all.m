clear;
close all;

addpath('.\functions\');
load('settings.mat');

fid = fopen(subjects_info,'r');
subjects = textscan(fid, '%s%s','delimiter',';');
fclose(fid);
subjects = subjects{:,1};

show = false;

logs_title = sprintf('From %s to %s\n=====================\n\n', datestr(date_start+datenum(1970,1,1),6), ...
    datestr(date_end+datenum(1970,1,1),6));

logs_data = [];
logs_all = [];
n_data = 0;

for i = 1:length(subjects),
    
    visual(i,:) = 3*ones(1,9);

    logs = [sprintf('\n--------------\n')];
    
    logs = [logs, sprintf('Subject %s', subjects{i})];
    logs = [logs, sprintf('\n--------------\n')];
    
    nodata = true;
    
    warning_log = evaluate_activity(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Activity\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
        if strcmp(warning_log, sprintf('no csv file\n'))==0,
            nodata = false;
        else
            visual(i,1) = 0;
        end
        if ~isempty(strfind(warning_log, 'gap')),
            visual(i,1) = 1;
        end
        if ~isempty(strfind(warning_log, 'range')),
            visual(i,1) = 2;
        end
    end

    warning_log = evaluate_audio(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Audio\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
        if strcmp(warning_log, sprintf('no csv file\n'))==0,
            nodata = false;
        else
            visual(i,2) = 0;
        end
        if ~isempty(strfind(warning_log, 'gap')),
            visual(i,2) = 1;
        end
        if ~isempty(strfind(warning_log, 'range')),
            visual(i,2) = 2;
        end
    end

    warning_log = evaluate_communication(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Communication\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
        if strcmp(warning_log, sprintf('no csv file\n'))==0,
            nodata = false;
        else
            visual(i,3) = 0;
        end
        if ~isempty(strfind(warning_log, 'gap')),
            visual(i,3) = 1;
        end
        if ~isempty(strfind(warning_log, 'range')),
            visual(i,3) = 2;
        end
    end
    
    warning_log = evaluate_ema(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('EMA\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
        if strcmp(warning_log, sprintf('no csv file\n'))==0,
            nodata = false;
        else
            visual(i,4) = 0;
        end
        if ~isempty(strfind(warning_log, 'gap')),
            visual(i,4) = 1;
        end
        if ~isempty(strfind(warning_log, 'range')),
            visual(i,4) = 2;
        end
    end
    
    warning_log = evaluate_light(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Light\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
        if strcmp(warning_log, sprintf('no csv file\n'))==0,
            nodata = false;
        else
            visual(i,5) = 0;
        end
        if ~isempty(strfind(warning_log, 'gap')),
            visual(i,5) = 1;
        end
        if ~isempty(strfind(warning_log, 'range')),
            visual(i,5) = 2;
        end
    end

    warning_log = evaluate_location(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Location\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
        if strcmp(warning_log, sprintf('no csv file\n'))==0,
            nodata = false;
        else
            visual(i,6) = 0;
        end
        if ~isempty(strfind(warning_log, 'gap')),
            visual(i,6) = 1;
        end
        if ~isempty(strfind(warning_log, 'range')),
            visual(i,6) = 2;
        end
    end
    
    warning_log = evaluate_screen(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Screen\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
        if strcmp(warning_log, sprintf('no csv file\n'))==0,
            nodata = false;
        else
            visual(i,7) = 0;
        end
        if ~isempty(strfind(warning_log, 'gap')),
            visual(i,7) = 1;
        end
        if ~isempty(strfind(warning_log, 'range')),
            visual(i,7) = 2;
        end
    end
    
    warning_log = evaluate_sleep(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Sleep\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
        if strcmp(warning_log, sprintf('no csv file\n'))==0,
            nodata = false;
        else
            visual(i,8) = 0;
        end
        if ~isempty(strfind(warning_log, 'gap')),
            visual(i,8) = 1;
        end
        if ~isempty(strfind(warning_log, 'range')),
            visual(i,8) = 2;
        end
    end

    warning_log = evaluate_touch(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Touch\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
        if strcmp(warning_log, sprintf('no csv file\n'))==0,
            nodata = false;
        else
            visual(i,9) = 0;
        end
        if ~isempty(strfind(warning_log, 'gap')),
            visual(i,9) = 1;
        end
        if ~isempty(strfind(warning_log, 'range')),
            visual(i,9) = 2;
        end
    end
    
    if ~nodata,
        logs_data = [logs_data, logs];
        n_data = n_data + 1;
    end
    logs_all = [logs_all, logs];
    
end

fid = fopen('log_matlab.txt','w');
fprintf(fid, '%s', [logs_title, logs_all]);
fclose(fid);

fid = fopen('log_matlab_data.txt','w');
fprintf(fid, '%s', [logs_title, logs_data]);
fclose(fid);

disp(['Number of subjects: ', num2str(length(subjects))]);
disp(['Data available: ', num2str(n_data)]);

colormap([0 0 0;1 1 0;1 0 0; 0 1 0]);
imagesc(visual);
set(gca, 'ytick', 1:length(subjects), 'yticklabel', subjects);
set(gca, 'xtick', 1:9, 'xticklabel', {'activity','audio','comm','EMA','light','location','screen','sleep','touch'});
set(gca, 'fontsize', 8);
% legend('no data', 'gap', 'out of range', 'healthy', 'location', 'northeastoutside');