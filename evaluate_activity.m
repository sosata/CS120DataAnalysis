function warning_log = evaluate_activity(subject, show)

load('settings.mat');

filename = [data_dir, subject, '\act.csv'];

timestamp_senddata = timestamp_senddata(strcmp(subjects, subject));
if timestamp_senddata>timestamp_start,
    timestamp_start = timestamp_senddata;
    date_start = floor(timestamp_start/86400);
end

warning_log = [];

if exist(filename, 'file'),
    
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%s%f', 'delimiter', '\t');
    fclose(fid);
    
    data{1} = data{1} + time_zone*3600;
    data = clip_data(data, timestamp_start, timestamp_end);
    
    data{2} = categorical(cellfun(@(x) x(x~='_'), data{2}, 'uniformoutput', false));
    
    if isempty(data{1}),
        warning_log = [warning_log, sprintf('no data\n')];
    else
        % extracting useful attributes
        act = separate_days(data, 1, date_start, date_end);
        conf = separate_days(data, 2, date_start, date_end);
        clear data;
        
        act_all = vertcat(act.value{:});
        time_all = vertcat(act.timestamp{:});
        conf_all = vertcat(conf.value{:});
        
        conf_stats = check_sanity(conf_all);
        
        % check sanity
        if sum(act.maxgap==0)>0,
            warning_log = [warning_log, sprintf('activity missing (%d days)\n', ...
                sum(act.maxgap==0))];
        end
        if sum(act.samplingduration >= 300)>0,
            warning_log = [warning_log, sprintf('activity sparse (%d days)\n', ...
                sum(act.samplingduration >= 300))];
        end
        gaps = get_gaps(time_all, date_start, date_end, gap_max_activity);
        if ~isempty(gaps),
            warning_log = [warning_log, sprintf('%d gaps (av. %.1fh)\n', length(gaps), mean(gaps))];
        end
        if get_variability(act_all) < .25,
            warning_log = [warning_log, sprintf('activity variability low\n')];
        end
        if (conf_stats.min < 0)||(conf_stats.max > 100),
            warning_log = [warning_log, sprintf('confidence out of range\n')];
        end
        if conf_stats.mean < 50,
            warning_log = [warning_log, sprintf('confidence low\n')];
        end
        if sum(diff(time_all)==0) > 0,
            warning_log = [warning_log, sprintf('%d/%d duplicate timestamps\n', ...
                sum(diff(time_all)==0), length(time_all))];
        end
        
        % plotting
        if show,
            close all;
            
            h = figure(1);
            set(h, 'position', [164   548   821   420]);
            plot_crossdays(act);
            
            h = figure(2);
            set(h,'position',[1041         377         720         633]);
            subplot 211;
            set(h,'position',[878   156   720   633]);
            hist(act_all);
            title(sprintf('variability = %.2f', get_variability(act_all)));
            xlabel('Activity');
            subplot 212;
            hist(conf_all, 50);
            title(sprintf('min=%.2f max=%.2f\nmean=%.2f', conf_stats.min, conf_stats.max, conf_stats.mean));
            xlabel('Confidence');
            
            h = figure(3);
            set(h,'position', [330   195   793   420]);
            plot_crossdays(conf);
            title('Confidence');
        
            figure(4);
            plot_time(time_all, 1);
            title(sprintf('Confidence\n%d/%d duplicate timestamps\n', sum(diff(time_all)==0), length(time_all)));
        
        end
    end
else
    warning_log = [warning_log, sprintf('no csv file\n')];
end

end