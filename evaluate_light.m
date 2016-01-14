function warning_log = evaluate_light(subject, show)

load('settings.mat');
load('time_senddata.mat');

filename = [data_dir, subject, '\lgt.csv'];

timestamp_senddata = timestamp_senddata(strcmp(subjects, subject));
if timestamp_senddata>timestamp_start,
    timestamp_start = timestamp_senddata;
    date_start = floor(timestamp_start/86400);
end

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
        
        lux = separate_days(data, 1, date_start, date_end);
        clear data;
        
        time_all = vertcat(lux.timestamp{:});
        lux_all = vertcat(lux.value{:});
        
        lux_stats = check_sanity(lux_all);
        
        if sum(lux.maxgap==0)>0,
            warning_log = [warning_log, sprintf('power missing (%d days)\n', ...
                sum(lux.maxgap==0))];
        end
        if sum(lux.samplingduration>=1800)>0,
            warning_log = [warning_log, sprintf('power sparse (%d days)\n', ...
                sum(lux.samplingduration>=1800))];
        end
        gaps = get_gaps(time_all, date_start, date_end, gap_max);
        if ~isempty(gaps),
            warning_log = [warning_log, sprintf('%d gaps (av. %.1fh)\n', length(gaps), mean(gaps))];
        end
        if lux_stats.std < 10,
            warning_log = [warning_log, sprintf('power variability low\n')];
        end
        if lux_stats.min < 0,
            warning_log = [warning_log, sprintf('power out of range\n')];
        end
        if lux_stats.nans > 0,
            warning_log = [warning_log, sprintf('power NaN values\n')];
        end

        if sum(diff(time_all)==0)>0,
            warning_log = [warning_log, sprintf('%d/%d duplicate timestamps\n', ...
                sum(diff(time_all)==0), length(time_all))];
        end
        
        if show,
            close all;
            
            h = figure(1);
            set(h, 'position', [276   390   617   382]);
            hist(lux_all, 50);
            title(sprintf('min: %.2f max: %.2f\nvariability: %.2f', lux_stats.min, lux_stats.max, lux_stats.std));
            xlabel('power (lux)');
            
            figure(2);
            plot_crossdays(lux);
                    
            figure(3);
            plot_time(time_all, 5);
            title(sprintf('%d/%d duplicate timestamps\n', sum(diff(time_all)==0), length(time_all)));
            
        end
    end
else
    warning_log = [warning_log, sprintf('no csv file\n')];
end

end