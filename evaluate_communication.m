function warning_log = evaluate_communication(subject, show)

load('settings.mat');

filename = [data_dir, subject, '\coe.csv'];

warning_log = [];

if show,
    close all;
end

if exist(filename, 'file'),
    
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%s%s%s%s', 'delimiter', '\t');
    fclose(fid);
    
    data{1} = data{1} + time_zone*3600;
    data = clip_data(data, timestamp_start, timestamp_end);
    
    data{2} = categorical(data{2});
    data{3} = categorical(data{3});
    data{4} = categorical(data{4});
    data{5} = categorical(data{5});
    
    if isempty(data{1}),
        warning_log = [warning_log, sprintf('no data\n')];
    else
        
        phone{1} = data{1}(data{4}=='PHONE');
        phone{2} = data{2}(data{4}=='PHONE');
        phone{3} = data{3}(data{4}=='PHONE');
        phone{4} = data{5}(data{4}=='PHONE');

        sms{1} = data{1}(data{4}=='SMS');
        sms{2} = data{2}(data{4}=='SMS');
        sms{3} = data{3}(data{4}=='SMS');
        sms{4} = data{5}(data{4}=='SMS');
        
        clear data;

        if ~isempty(phone{1}),
            phone_dir = separate_days(phone, 3, date_start, date_end);
            
            if sum(diff(phone{1})==0)>0,
                warning_log = [warning_log, sprintf('%d/%d duplicate timestamps (phone)\n', ...
                    sum(diff(phone{1})==0), length(phone{1}))];
            end
            
            if show,
                h = figure(1);
                set(h, 'position', [706   473   926   420]);
                plot_crossdays(phone_dir);
                title(sprintf('Phone\n%d/%d duplicate timestamps', sum(diff(phone{1})==0), length(phone{1})));
            end
            
        else
            warning_log = [warning_log, sprintf('no phone data\n')];
        end
        
        if ~isempty(sms{1}),
            sms_dir = separate_days(sms, 3, date_start, date_end);
            if sum(diff(sms{1})==0)>0,
                warning_log = [warning_log, sprintf('%d/%d duplicate timestamps (sms)\n', ...
                    sum(diff(sms{1})==0), length(sms{1}))];
            end
            
            if show,
                h = figure(2);
                set(h, 'position', [706   473   926   420]);
                plot_crossdays(sms_dir);
                title(sprintf('SMS\n%d/%d duplicate timestamps', sum(diff(sms{1})==0), length(sms{1})));
            end
            
        else
            warning_log = [warning_log, sprintf('no sms data\n')];
        end

    end
else
    warning_log = [warning_log, sprintf('no csv file\n')];
end
end