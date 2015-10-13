function warning_log = evaluate_location(subject, show)

load('settings.mat');

warning_log = [];

filename = [data_dir, subject, '\fus.csv'];

if exist(filename, 'file'),
    
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%f%f%f%f', 'delimiter', '\t');
    fclose(fid);
    
    data{1} = data{1} + time_zone*3600;
    data = clip_data(data, timestamp_start, timestamp_end);
    
    if isempty(data{1}),
        warning_log = [warning_log, sprintf('no data\n')];
    else
        
        lat = separate_days(data, 1, date_start, date_end);
        lng = separate_days(data, 2, date_start, date_end);
        acc = separate_days(data, 4, date_start, date_end);
        
        time_all = vertcat(lat.timestamp{:});
        lat_all = vertcat(lat.value{:});
        lng_all = vertcat(lng.value{:});
        acc_all = vertcat(acc.value{:});
        
        if sum(lat.samplingduration>=86400)>0,
            warning_log = [warning_log, sprintf('latitude missing (%d days)\n', ...
                sum(lat.samplingduration>=86400))];
        end
        if sum(lat.samplingduration>=600)>0,
            warning_log = [warning_log, sprintf('latitude sparse (%d days)\n', ...
                sum(lat.samplingduration>=600))];
        end
        if sum(lng.samplingduration>=86400)>0,
            warning_log = [warning_log, sprintf('longitude missing (%d days)\n', ...
                sum(lng.samplingduration>=86400))];
        end
        if sum(lng.samplingduration>=600)>0,
            warning_log = [warning_log, sprintf('longitude sparse (%d days)\n', ...
                sum(lng.samplingduration>=600))];
        end
        if sum(diff(time_all) >= gap_max)>0,
            warning_log = [warning_log, sprintf('gap (%d)\n', sum(diff(time_all)>=gap_max))];
        end
        
        % checking latitude stats
        lat_stat = check_sanity(lat_all);
        if (lat_stat.min<-90)||(lat_stat.max>90),
            warning_log = [warning_log, sprintf('latitude out of range\n')];
        end
        if lat_stat.std<.0001,
            warning_log = [warning_log, sprintf('latitude variability low\n')];
        end
        if lat_stat.nans>0,
            warning_log = [warning_log, sprintf('latitude NaN values\n')];
        end
        
        % checking longitude stats
        lng_stat = check_sanity(lng_all);
        if (lng_stat.min<-180)||(lng_stat.max>180),
            warning_log = [warning_log, sprintf('longitude out of range\n')];
        end
        if lng_stat.std<.0001,
            warning_log = [warning_log, sprintf('longitude variability low\n')];
        end
        if lng_stat.nans>0,
            warning_log = [warning_log, sprintf('longitude NaN values\n')];
        end
        
        % checking accuracy
        acc_stat = check_sanity(acc_all);
        if acc_stat.min<0,
            warning_log = [warning_log, sprintf('Accuracy out of range\n')];
        end
        % The returned accuracy is the radius of 68% confidence in meters.
        if acc_stat.mean>68,
            warning_log = [warning_log, sprintf('Accuracy low\n')];
        end
        
        n_zeros = sum(diff(time_all)==0);
        if n_zeros>0,
            warning_log = [warning_log, sprintf('%d/%d duplicate timestamps\n', n_zeros, length(time_all))];
        end
        
        if show,
            close all;
            
            figure(1);
            plot(lng_all, lat_all, '.r', 'markersize', 8);
            plot_google_map('MapType', 'satellite');
            
            figure(2);
            subplot 311;
            hist(lat_all, 50);
            ylabel('Latitude');
            title(sprintf('min: %.2f max: %.2f\nstd: %.4f', lat_stat.min, lat_stat.max, lat_stat.std));
            subplot 312;
            hist(lng_all, 50);
            ylabel('Longitude');
            title(sprintf('min: %.2f max: %.2f\nstd: %.4f', lng_stat.min, lng_stat.max, lng_stat.std));
            subplot 313;
            hist(acc_all, 50);
            ylabel('Accuracy');
            title(sprintf('min: %.2f max: %.2f\nmean: %.4f', acc_stat.min, acc_stat.max, acc_stat.mean));
            
            figure(3);
            plot_time(time_all, 1);
            title(sprintf('Duplicate timestamps: %d', n_zeros));
            
            figure(4);
            plot_crossdays(lat);
            title('latitude');
            
            figure(5);
            plot_crossdays(lng);
            title('longitude');
            
            figure(6);
            plot_crossdays(acc);
            title('accuracy');
        end
        
    end
else
    warning_log = [warning_log, sprintf('no csv file\n')];
end

end