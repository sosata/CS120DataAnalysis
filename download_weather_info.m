clear;
close all;

load('settings.mat');
addpath('features');
addpath('functions');

extract_locations = true;
query_weather = false;

plot_clusters = false;


% latitude parameters (independent of location)
lat_km = 111;
hist_res_lat = 0.5/lat_km;
hist_threshold = 1;%%%%
n_kmeans_init = 1;

cnt = 1;

if extract_locations,
    for i=1:length(subjects),
        
        fprintf('%d/%d\n', i, length(subjects));
        
        filename = [data_dir, subjects{i}, '/fus.csv'];
        
        % check if file exists
        if ~exist(filename, 'file'),
            disp(['No location data for ', subjects{i}, '; skipping']);
        else
            % read data
            tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
            
            [tab, jour, ~] = separate_days(tab, false);
            
            ndays = 0;
            
            loc.centroid{cnt} = {}; % GPS cluster centroids
            loc.jour{cnt} = []; % Day
            loc.lab{cnt} = {};  % GPS cluster index
            loc.time{cnt} = {}; % GPS acquisition time
            
            loc.subject{cnt} = subjects{i};
            
            for k = 1:length(tab),
                
                if isempty(tab{k}),
                    continue;
                end
                
                time = tab{k}.Var1;
                lat = tab{k}.Var2;
                lng = tab{k}.Var3;
                
                % filter data based on histogram
                lng_km = 111*cos(mean(lat)*pi/180);
                hist_res_lng = 0.5/lng_km;
                [time, lat, lng, ~] = filter_hist(time, lat, lng, hist_res_lat, hist_res_lng, hist_threshold);
                
                % filter data based on speed
                latlong_km = sqrt(lat_km^2 + lng_km^2);
                speed_max = 1/latlong_km/3600;
                [time, lat, lng, ~] = filter_speed(time, lat, lng, speed_max);
                
                if isempty(time),
                    continue;
                end
                
                % cluster data
                kmeans_distance_max = 5/latlong_km; % 10km
                [lab, centroids] = cluster_kmeans(lat, lng, n_kmeans_init, kmeans_distance_max);
                fprintf('%d ',length(unique(lab)));
                
                % only keep one sample per hour
                [time, lab] = get_mode_hourly(time, lab);
                
                loc.centroid{cnt} = [loc.centroid{cnt}, centroids];
                loc.jour{cnt} = [loc.jour{cnt}, jour(k)];
                loc.lab{cnt} = [loc.lab{cnt}, lab];
                loc.time{cnt} = [loc.time{cnt}, time];
                
                ndays = ndays+1;
                
                if plot_clusters,
                    clf;
                    hold on;
                    lab_u = unique(lab);
                    for j=1:length(lab_u),
                        plot(mean(lng(lab==lab_u(j))), mean(lat(lab==lab_u(j))), '.', 'markersize', 50);
                    end
                    plot(lng, lat, '.k');
                    pause;
                end
                
            end
            
            cnt = cnt+1;
            fprintf('\ndays: %d\n', ndays);
        end
        
    end
    save('locations_weather.mat', 'loc');
else
    load('locations_weather.mat');
end

if query_weather,
    %TODO
    for i = 1:1,%length(loc.subject),
        
        
        
    end
    
end