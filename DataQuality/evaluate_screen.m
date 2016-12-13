function warning_log = evaluate_screen(subject, show)

load('settings.mat');
load('time_senddata.mat');

filename = [data_dir, subject, '\scr.csv'];

timestamp_senddata = timestamp_senddata(strcmp(subjects, subject));
if timestamp_senddata>timestamp_start,
    timestamp_start = timestamp_senddata;
    date_start = floor(timestamp_start/86400);
end

warning_log = [];

if exist(filename, 'file'),
    
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%s', 'delimiter', '\t');
    fclose(fid);
    
    data{1} = data{1} + time_zone*3600;
    data = clip_data(data, timestamp_start, timestamp_end);
    
    if isempty(data{1}),
        warning_log = [warning_log, sprintf('no data\n')];
    else
        
        data_sep = data;
        data_sep{2} = categorical(data_sep{2});
        data_sep = separate_days(data_sep, 1, date_start, date_end);
        if sum(data_sep.maxgap==0)>0,
            warning_log = [warning_log, sprintf('missing (%d days)\n', ...
                sum(data_sep.maxgap==0))];
        end
        if sum(diff(data{1})==0)>0,
            warning_log = [warning_log, sprintf('%d/%d duplicate timestamps\n', ...
                 sum(diff(data{1})==0), length(data{1}))];
        end
        
        if show,
            close all;
            dur = zeros(date_end-date_start+1, 1);
            time_start = [];
            time_end = [];
            for i=1:length(data{1})-1,
                if strcmp(data{2}(i),'True')&&strcmp(data{2}(i+1),'False'),
                    time_start = [time_start; data{1}(i)];
                    time_end = [time_end; data{1}(i+1)];
                    if floor(data{1}(i)/86400)==floor(data{1}(i+1)/86400),
                        dur(floor(data{1}(i)/86400)-date_start+1) = dur(floor(data{1}(i)/86400)-date_start+1) + ...
                            data{1}(i+1)-data{1}(i);
                    elseif floor(data{1}(i+1)/86400)==floor(data{1}(i)/86400)+1,
                        dur(floor(data{1}(i)/86400)-date_start+1) = dur(floor(data{1}(i)/86400)-date_start+1) + ...
                            floor(data{1}(i+1)/86400)*86400 - data{1}(i);
                        dur(floor(data{1}(i+1)/86400)-date_start+1) = dur(floor(data{1}(i+1)/86400)-date_start+1) + ...
                            data{1}(i+1) - floor(data{1}(i+1)/86400)*86400;
                    end
                end
            end
            
            h = figure(1);
            set(h, 'position', [624         594        1033         504]);
            subplot(1,3,[1 2]);
            plot_rectangle_crossdays(time_start, time_end, date_start, date_end, 'b');
            
            subplot(1,3,3);
            barh(date_start:date_end, dur);
            set(gca, 'ydir', 'reverse');
            set(gca, 'ytick', date_start:date_end, 'yticklabel', datestr((date_start:date_end)+datenum(1970,1,1),6));
            ylim([date_start-1 date_end+1]);
            set(gca, 'ydir', 'reverse');
            xlabel('sec');
        end
    end
else
    warning_log = [warning_log, sprintf('no csv file\n')];    
end

end