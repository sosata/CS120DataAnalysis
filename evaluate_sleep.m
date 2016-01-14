function warning_log = evaluate_sleep(subject, show)

load('settings.mat');
load('time_senddata.mat');

filename = [data_dir, subject, '\ems.csv'];

timestamp_senddata = timestamp_senddata(strcmp(subjects, subject));
if timestamp_senddata>timestamp_start,
    timestamp_start = timestamp_senddata;
    date_start = floor(timestamp_start/86400);
end

warning_log = [];

if exist(filename, 'file'),
    
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%f%f%f%f%d%s', 'delimiter', '\t');
    fclose(fid);
    
    data{1} = data{1} + time_zone*3600;
    data = clip_data(data, timestamp_start, timestamp_end);
    
    if isempty(data{1}),
        warning_log = [warning_log, sprintf('no data\n')];
    else
        
        time_bed = data{2}/1000 + time_zone*3600;
        time_sleep = data{3}/1000 + time_zone*3600;
        time_wake = data{4}/1000 + time_zone*3600;
        time_up = data{5}/1000 + time_zone*3600;
        
        complete = length(time_bed)/(date_end-date_start+1);
        
        if sum([length(time_bed),length(time_sleep),length(time_wake)]~=length(time_up))>0,
            warning_log = [warning_log, sprintf('Sleep times inconsistent\n')];
        end
        if complete<1,
            warning_log = [warning_log, sprintf('Sleep %.0f%% complete\n', complete*100)];
        end
        
        if show,
            close all;
            h = figure(1);
            set(h, 'position', [296   311   827   453]);
            plot_rectangle_crossdays(time_bed, time_up, date_start, date_end, 'r');
            hold on;
            plot_rectangle_crossdays(time_sleep, time_wake, date_start, date_end, 'b');
            title(sprintf('complete: %.0f%%\navg sleep duration: %.2fh\navg bed duration: %.2fh',...
                complete*100, mean(time_wake-time_sleep)/3600, ...
                mean(time_up-time_bed)/3600));
        end
    end
else
   warning_log = [warning_log, sprintf('no csv file\n')]; 
end

end