clear;
close all;

addpath('.\functions\');
load('settings.mat');

fid = fopen(subjects_info,'r');
subjects = textscan(fid, '%s%s','delimiter',';');
fclose(fid);
subjects = subjects{:,1};

show = false;

logs = sprintf('From %s to %s\n=====================\n\n', datestr(date_start,6), datestr(date_end,6));

for i = 1:length(subjects),
    
    logs = [logs, sprintf('\n--------------\n')];
    logs = [logs, sprintf('Subject %s', subjects{i})];
    logs = [logs, sprintf('\n--------------\n')];
    
    warning_log = evaluate_activity(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Activity\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
    end

    warning_log = evaluate_audio(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Audio\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
    end

    warning_log = evaluate_communication(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Communication\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
    end
    
    warning_log = evaluate_ema(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('EMA\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
    end
    
    warning_log = evaluate_light(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Light\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
    end

    warning_log = evaluate_location(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Location\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
    end
    
    warning_log = evaluate_screen(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Screen\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
    end
    
    warning_log = evaluate_sleep(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Sleep\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
    end

    warning_log = evaluate_touch(subjects{i}, show);
    if ~isempty(warning_log),
        logs = [logs, sprintf('Touch\n')];
        logs = [logs, warning_log];
        logs = [logs, sprintf('\n')];
    end
    
end

fid = fopen('log_matlab.txt','w');
fprintf(fid, '%s', logs);
fclose(fid);

