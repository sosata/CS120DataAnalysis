function warning_log = evaluate_touch(subject, show)

load('settings.mat');

filename = [data_dir, subject, '\tch.csv'];

warning_log = [];

if exist(filename, 'file'),
    
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%f%f', 'delimiter', '\t');
    fclose(fid);
    
    data{1} = data{1} + time_zone*3600;
    data = clip_data(data, timestamp_start, timestamp_end);
    
    if isempty(data{1}),
        warning_log = [warning_log, sprintf('no data\n')];
    else
        
        delay = separate_days(data, 1, date_start, date_end);
        count = separate_days(data, 2, date_start, date_end);
        clear data;
        
        time_all = vertcat(delay.timestamp{:});
        delay_all = vertcat(delay.value{:});
        count_all = vertcat(count.value{:});
        
        delay_stats = check_sanity(delay_all);
        count_stats = check_sanity(count_all);
        
        % delay
        if sum(delay.samplingduration>=86400)>0,
            warning_log = [warning_log, sprintf('delay missing (%d days)\n', ...
                sum(delay.samplingduration>=86400))];
        end
        if sum(delay.samplingduration>=1800)>0,
            warning_log = [warning_log, sprintf('delay sparse (%d days)\n', ...
                sum(delay.samplingduration>=1800))];
        end
        if delay_stats.std < 1000,
            warning_log = [warning_log, sprintf('delay variability low\n')];
        end
        if delay_stats.min < 0,
            warning_log = [warning_log, sprintf('delay out of range\n')];
        end
        if delay_stats.nans > 0,
            warning_log = [warning_log, sprintf('delay NaN values\n')];
        end
        
        % count
        if sum(count.samplingduration>=86400)>0,
            warning_log = [warning_log, sprintf('count missing (%d days)\n', ...
                sum(count.samplingduration>=86400))];
        end
        if sum(count.samplingduration>=1800)>0,
            warning_log = [warning_log, sprintf('count sparse (%d days)\n', ...
                sum(count.samplingduration>=1800))];
        end
        if count_stats.std < .1,
            warning_log = [warning_log, sprintf('count variability low\n')];
        end
        if count_stats.min < 0,
            warning_log = [warning_log, sprintf('count out of range\n')];
        end
        if count_stats.nans > 0,
            warning_log = [warning_log, sprintf('count NaN values\n')];
        end
        
        % time
        if sum(diff(time_all)==0)>0,
            warning_log = [warning_log, sprintf('%d/%d duplicate timestamps\n', sum(diff(time_all)==0), length(time_all))];
        end
        if get_gaps(time_all, date_start, date_end, gap_max)>0,
            warning_log = [warning_log, sprintf('gap (%d)\n', get_gaps(time_all, date_start, date_end, gap_max))];
        end
        
        if show,
            close all;
            
            figure(1);
            subplot 211;
            hist(delay_all, 50);
            title(sprintf('min: %.2f max: %.2f\nvariability: %.2f', delay_stats.min, delay_stats.max, delay_stats.std));
            xlabel('Time since last touch');
            subplot 212;
            hist(count_all, 50);
            title(sprintf('min: %.2f max: %.2f\nvariability: %.2f', count_stats.min, count_stats.max, count_stats.std));
            xlabel('Touch Count');
            
            figure(2);
            plot_crossdays(delay);
            title('Time since last touch');
            
            figure(3);
            plot_crossdays(count);
            title('Touch Count');
        
            figure(4);
            plot_time(time_all, 5);
            title(sprintf('%d/%d duplicate timestamps\n', sum(diff(time_all)==0), length(time_all)));
        end
    end
else
    warning_log = [warning_log, sprintf('no csv file\n')];
end

end