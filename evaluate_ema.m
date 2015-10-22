function warning_log = evaluate_ema(subject, show)

load('settings.mat');

filename = [data_dir, subject, '\emm.csv'];

timestamp_senddata = timestamp_senddata(strcmp(subjects, subject));
if timestamp_senddata>timestamp_start,
    timestamp_start = timestamp_senddata;
    date_start = floor(timestamp_start/86400);
end

warning_log = [];

if exist(filename, 'file'),
    
    fid = fopen(filename, 'r');
    data = textscan(fid, '%f%f%f%f%f', 'delimiter', '\t');
    fclose(fid);
    
    data{1} = data{1} + time_zone*3600;
    data = clip_data(data, timestamp_start, timestamp_end);
    
    
    if isempty(data{1}),
        warning_log = [warning_log, sprintf('no data\n')];
    else
        
        time = data{1};
        stress = data{2};
        mood = data{3};
        energy = data{4};
        focus = data{5};
        
        complete_stress = length(stress)/3/(date_end-date_start+1);
        complete_mood = length(mood)/3/(date_end-date_start+1);
        complete_energy = length(energy)/3/(date_end-date_start+1);
        complete_focus = length(focus)/3/(date_end-date_start+1);
        
        if complete_stress<1,
            warning_log = [warning_log, sprintf('Stress %.0f%% complete\n', ...
                complete_stress*100)];
        end
        if complete_stress<1,
            warning_log = [warning_log, sprintf('Mood %.0f%% complete\n', ...
                complete_mood*100)];
        end
        if complete_stress<1,
            warning_log = [warning_log, sprintf('Energy %.0f%% complete\n', ...
                complete_energy*100)];
        end
        if complete_stress<1,
            warning_log = [warning_log, sprintf('Focus %.0f%% complete\n', ...
                complete_focus*100)];
        end
        
        if show,
            close all;
            
            h = figure;
            set(h, 'position', [495    58   672   896]);
            subplot 411;
            plot(time, stress,'.','markersize',12);
            xlim([timestamp_start, timestamp_end]);
            ylim([0 10]);
            set_date_ticks(gca, 1);
            ylabel('stress');
            title(sprintf('variability: %.2f \nno. states: %d \ncomplete: %.0f%%', ...
                get_variability(stress), length(unique(stress)), ...
                complete_stress*100));
            
            subplot 412;
            plot(time, mood,'.','markersize',12);
            xlim([timestamp_start, timestamp_end]);
            ylim([0 10]);
            set_date_ticks(gca, 1);
            ylabel('mood');
            title(sprintf('variability: %.2f \nno. states: %d \ncomplete: %.0f%%', ...
                get_variability(mood), length(unique(mood)), ...
                complete_mood*100));
            
            subplot 413;
            plot(time, energy,'.','markersize',12);
            xlim([timestamp_start, timestamp_end]);
            ylim([0 10]);
            ylabel('energy');
            set_date_ticks(gca, 1);
            title(sprintf('variability: %.2f \nno. states: %d \ncomplete: %.0f%%', ...
                get_variability(energy), length(unique(energy)), ...
                complete_energy*100));
            
            subplot 414;
            plot(time, focus,'.','markersize',12);
            xlim([timestamp_start, timestamp_end]);
            ylim([0 10]);
            set_date_ticks(gca, 1);
            ylabel('focus');
            title(sprintf('variability: %.2f \nno. states: %d \ncomplete: %.0f%%', ...
                get_variability(focus), length(unique(focus)), ...
                complete_focus*100));
            
        end
    end
else
   warning_log = [warning_log, sprintf('no csv file\n')]; 
end

end