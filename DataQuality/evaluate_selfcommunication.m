function warning_log = evaluate_selfcommunication(subject, show)

load('settings.mat');
load('time_senddata.mat');

filename = [data_dir, subject, '\emc.csv'];

timestamp_senddata = timestamp_senddata(strcmp(subjects, subject));
if timestamp_senddata>timestamp_start,
    timestamp_start = timestamp_senddata;
    date_start = floor(timestamp_start/86400);
end

warning_log = [];

if exist(filename, 'file'),
    
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%s%s%f%f%f%f', 'delimiter', '\t');
    fclose(fid);
    
    data{1} = data{1} + time_zone*3600;
    data = clip_data(data, timestamp_start, timestamp_end);
    
    if isempty(data{1}),
        warning_log = [warning_log, sprintf('no data\n')];
    else
        
        time = data{1};
        number = data{2};
        want = data{4};
        closeness = data{7};
        
        want_sep = separate_days(data, 3, date_start, date_end);
        
        completeness = sum(cellfun(@(x) ~isempty(x), want_sep.value))/(date_end-date_start+1);
        
        if completeness<1,
            warning_log = [warning_log, sprintf('report %.0f%% complete\n', completeness*100)];
        end
        
        if show,
            close all;
            
            h = figure;
            subplot 211;
            plot(time, want,'.','markersize',12);
            xlim([timestamp_start, timestamp_end]);
            ylim([0 10]);
            set_date_ticks(gca, 1);
            ylabel('Accomplishment');
            title(sprintf('complete: %.0f%%', completeness*100));
            
            subplot 212;
            plot(time, closeness,'.','markersize',12);
            xlim([timestamp_start, timestamp_end]);
            ylim([0 10]);
            set_date_ticks(gca, 1);
            ylabel('Pleasure');

        end
    end
else
   warning_log = [warning_log, sprintf('no csv file\n')]; 
end

end