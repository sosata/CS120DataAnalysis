function warning_log = evaluate_location(subject, show)

close all;

load('settings.mat');
load('time_senddata.mat');

warning_log = [];

if strcmp(subject,'all'),
    subjects_to_review = subjects;
else
    subjects_to_review = subject;
end

for subj = 1:length(subjects_to_review),
    
    timestamp_senddata_subj = timestamp_senddata(strcmp(subjects, subjects_to_review{subj}));
    if timestamp_senddata_subj>timestamp_start,
        timestamp_start = timestamp_senddata_subj;
        date_start = floor(timestamp_start/86400);
    end
    
    filename = [data_dir, subjects_to_review{subj}, '/fus.csv'];
    
    filename
    
    if exist(filename, 'file'),
        
        %fid = fopen(filename, 'r');
        %data = textscan(fid, '%f%f%f%f%f', 'delimiter', '\t');
        data = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
        %fclose(fid);
        
        data.Var1 = data.Var1 + time_zone*3600;
        %data = clip_data(data, timestamp_start, timestamp_end);%%%%%%%%%
        
        if isempty(data.Var1),
            warning_log = [warning_log, sprintf('csv file is empty\n')];
        else
            
            time_all = data.Var1;
            lat_all = data.Var2;
            lng_all = data.Var3;
            acc_all = data.Var5;
            
            [~, ~, stats] = separate_days(data, false);
            
            if sum(isnan(stats.maxgap))>0,
                warning_log = [warning_log, sprintf('missing (%d days)\n', ...
                    sum(isnan(stats.maxgap)))];
            end
            if sum(stats.samplingduration>=600)>0,
                warning_log = [warning_log, sprintf('sparse (%d days)\n', ...
                    sum(stats.samplingduration>=600))];
            end
            gaps = get_gaps(time_all, date_start, date_end, gap_max);
            if ~isempty(gaps),
                warning_log = [warning_log, sprintf('%d gaps (av. %.1fh)\n', length(gaps), mean(gaps))];
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
                warning_log = [warning_log, sprintf('accuracy out of range\n')];
            end
            if acc_stat.mean>100,
                warning_log = [warning_log, sprintf('accuracy very low\n')];
            end
            
            n_sametime = sum(diff(time_all)==0);
            n_samevalue = sum((diff(time_all)==0)&(diff(lat_all)==0)&(diff(lng_all)==0));
            if n_sametime>0,
                warning_log = [warning_log, sprintf('%d/%d duplicate timestamps\n', n_sametime, length(time_all))];
            end
            
            if show,
                %close all;
                
                h = figure;
                set(h,'position',[362   385   969   420]);
                
                subplot 121;
                plot(lng_all, lat_all, '.r', 'markersize', 8);
                plot_google_map('MapType', 'satellite');
                title(sprintf('%d days',ceil((time_all(end)-time_all(1))/86400)));
                
%                 subplot(2,3,3);
%                 subplot 311;
%                 hist(lat_all, 50);
%                 ylabel('Latitude');
%                 title(sprintf('min: %.2f max: %.2f\nstd: %.4f', lat_stat.min, lat_stat.max, lat_stat.std));
%                 subplot 312;
%                 hist(lng_all, 50);
%                 ylabel('Longitude');
%                 title(sprintf('min: %.2f max: %.2f\nstd: %.4f', lng_stat.min, lng_stat.max, lng_stat.std));
%                 subplot 313;
%                 hist(acc_all, 50);
%                 ylabel('Accuracy');
%                 title(sprintf('min: %.2f max: %.2f\nmean: %.4f', acc_stat.min, acc_stat.max, acc_stat.mean));
                
                subplot 122;
                plot_time(time_all, 5);
                title(sprintf('Duplicate timestamps: %d (%.f%%)\nDuplicate all: %d (%.f%%)', ...
                    n_sametime, n_sametime/length(time_all)*100, n_samevalue, n_samevalue/length(time_all)*100));
                
                %TODO
                % table format cannot be used with current version of
                % plot_crossdays
                
%                 figure(4);
%                 plot_crossdays(lat);
%                 title('latitude');
%                 
%                 figure(5);
%                 plot_crossdays(lng);
%                 title('longitude');
%                 
%                 figure(6);
%                 plot_crossdays(acc);
%                 title('accuracy');
            end
            
        end
    else
        warning_log = [warning_log, sprintf('no csv file\n')];
    end
    
    pause;
    
end

end