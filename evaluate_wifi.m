function warning_log = evaluate_wifi(subject, show)

load('settings.mat');

filename = [data_dir, subject, '\wif.csv'];

timestamp_senddata = timestamp_senddata(strcmp(subjects, subject));
if timestamp_senddata>timestamp_start,
    timestamp_start = timestamp_senddata;
    date_start = floor(timestamp_start/86400);
end

warning_log = [];

if exist(filename, 'file'),
    
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%s%s%f', 'delimiter', '\t');
    fclose(fid);
    
    data{1} = data{1} + time_zone*3600;
    data = clip_data(data, timestamp_start, timestamp_end);
    
    data{2} = categorical(cellfun(@(x) x(x~='"'), data{2}, 'uniformoutput', false));
    data{3} = categorical(data{3});
    
    if isempty(data{1}),
        warning_log = [warning_log, sprintf('no data\n')];
    else
        
        name = separate_days(data, 1, date_start, date_end);
        address = separate_days(data, 2, date_start, date_end);
        count = separate_days(data, 3, date_start, date_end);
        
        clear data;
        
        time_all = vertcat(name.timestamp{:});
        count_all = vertcat(count.value{:});
        
        count_stats = check_sanity(count_all);
        
        if sum(name.maxgap==0)>0,
            warning_log = [warning_log, sprintf('missing (%d days)\n', ...
                sum(name.maxgap==0))];
        end
        if sum(name.samplingduration>=1800)>0,
            warning_log = [warning_log, sprintf('sparse (%d days)\n', ...
                sum(name.samplingduration>=1800))];
        end
        gaps = get_gaps(time_all, date_start, date_end, gap_max_wifi);
        if ~isempty(gaps),
            warning_log = [warning_log, sprintf('%d gaps (av. %.1fh)\n', length(gaps), mean(gaps))];
        end
        if count_stats.min < 0,
            warning_log = [warning_log, sprintf('count out of range\n')];
        end
        if count_stats.nans > 0,
            warning_log = [warning_log, sprintf('count out of range\n')];
        end

        if sum(diff(time_all)==0)>0,
            warning_log = [warning_log, sprintf('%d/%d duplicate timestamps\n', ...
                sum(diff(time_all)==0), length(time_all))];
        end
        
        if show,
            close all;
            
            h = figure(1);
            set(h, 'position', [276   390   617   382]);
            hist(count_all, 50);
            title(sprintf('min: %.2f max: %.2f\nvariability: %.2f', count_stats.min, count_stats.max, count_stats.std));
            xlabel('access point count');
            
            figure(2);
            plot_crossdays(name);
                    
            figure(3);
            plot_crossdays(address);

            figure(4);
            plot_time(time_all, 5);
            title(sprintf('%d/%d duplicate timestamps\n', sum(diff(time_all)==0), length(time_all)));
            
        end
    end
else
    warning_log = [warning_log, sprintf('no csv file\n')];
end

end