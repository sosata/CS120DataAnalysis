function warning_log = evaluate_audio(subject, show)

load('settings.mat');
load('time_senddata.mat');

filename = [data_dir, subject, '\aud.csv'];

timestamp_senddata = timestamp_senddata(strcmp(subjects, subject));
if timestamp_senddata>timestamp_start,
    timestamp_start = timestamp_senddata;
    date_start = floor(timestamp_start/86400);
end

warning_log = [];

if exist(filename, 'file'),
    
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%f%f%f', 'delimiter', '\t');
    fclose(fid);
    
    data{1} = data{1} + time_zone*3600;
    data = clip_data(data, timestamp_start, timestamp_end);
    
    if isempty(data{1}),
        warning_log = [warning_log, sprintf('no data\n')];
    else
        
        pwr = separate_days(data, 1, date_start, date_end);
        frq = separate_days(data, 2, date_start, date_end);
        clear data;
        
        pwr_all = vertcat(pwr.value{:});
        frq_all = vertcat(frq.value{:});
        pwr_time_all = vertcat(pwr.timestamp{:});
        frq_time_all = vertcat(pwr.timestamp{:});
        
        pwr_stats = check_sanity(pwr_all);
        frq_stats = check_sanity(frq_all);
        
        % power
        if sum(pwr.maxgap==0)>0,
            warning_log = [warning_log, sprintf('power missing (%d days)\n', ...
                sum(pwr.maxgap==0))];
        end
        if sum(pwr.samplingduration>=1800)>0,
            warning_log = [warning_log, sprintf('power sparse (%d days)\n', ...
                sum(pwr.samplingduration>=1800))];
        end
        gaps = get_gaps(pwr_time_all, date_start, date_end, gap_max);
        if ~isempty(gaps),
            warning_log = [warning_log, sprintf('%d power gaps (av. %.1fh)\n', length(gaps), mean(gaps))];
        end
        if pwr_stats.std< .001,
            warning_log = [warning_log, sprintf('power variability low\n')];
        end
        if pwr_stats.min < 0,
            warning_log = [warning_log, sprintf('power out of range\n')];
        end
        if pwr_stats.nans>0,
            warning_log = [warning_log, sprintf('power NaN values\n')];
        end
        if sum(diff(pwr_time_all)==0) > 0,
            warning_log = [warning_log, sprintf('%d/%d power duplicate timestamps\n', ...
                sum(diff(pwr_time_all)==0), length(pwr_time_all))];
        end
        
        % frequency
        if sum(frq.maxgap==0) > 0,
            warning_log = [warning_log, sprintf('frequency missing (%d days)\n', ...
                sum(frq.maxgap==0))];
        end
        if sum(frq.samplingduration>=1800) > 0,
            warning_log = [warning_log, sprintf('frequency sparse (%d days)\n', ...
                sum(frq.samplingduration>=1800))];
        end
        gaps = get_gaps(frq_time_all, date_start, date_end, gap_max);
        if ~isempty(gaps),
            warning_log = [warning_log, sprintf('%d frequency gaps (av. %.1fh)\n', length(gaps), mean(gaps))];
        end
        if frq_stats.std < 100,
            warning_log = [warning_log, sprintf('frequency variability low\n')];
        end
        if frq_stats.min < 0,
            warning_log = [warning_log, sprintf('frequency out of range\n')];
        end
        if frq_stats.nans>0,
            warning_log = [warning_log, sprintf('frequency NaN values\n')];
        end
        if sum(diff(frq_time_all)==0) > 0,
            warning_log = [warning_log, sprintf('%d/%d frequency duplicate timestamps\n', ...
                sum(diff(frq_time_all)==0), length(frq_time_all))];
        end
        
        if show,
            close all;
            
            figure(1);
            subplot 211;
            hist(pwr_all, 50);
            title(sprintf('min: %.2f max: %.2f\nvariability: %.3f', pwr_stats.min,  pwr_stats.max,  pwr_stats.std));
            xlabel('power');
            subplot 212;
            hist(frq_all, 50);
            title(sprintf('min: %.2f max: %.2f\nvariability: %.0f', frq_stats.min,  frq_stats.max,  frq_stats.std));
            xlabel('dominant frequency');
            
            figure(2);
            plot_crossdays(pwr);
            title('Power');
            
            figure(3);
            plot_crossdays(frq);
            title('Frequency');
        
            figure(4);
            plot_time(pwr_time_all, 5);
            title(sprintf('Audio Power\nduplicate timestamps: %d', sum(diff(pwr_time_all)==0)));
        end
    end
    
else
   warning_log = [warning_log, sprintf('no csv file\n')]; 
end

end