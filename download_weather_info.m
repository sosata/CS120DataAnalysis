clear;
close all;

load('settings.mat');
addpath('features');

plot_clusters = true;

% latitude parameters (independent of location)
lat_km = 111;
hist_res_lat = 0.5/lat_km; 
hist_threshold = 1;%%%%
n_kmeans_init = 1;

cnt = 1;

for i=1:length(subjects),
    
    fprintf('%d/%d\n', i, length(subjects));
    
    filename = [data_dir, subjects{i}, '/fus.csv'];
    
    % check if file exists
    if ~exist(filename, 'file'),
        disp(['No location data for ', subjects{i}, '; skipping']);
    else
        % read data
        tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
        
        return;
        time = tab.Var1;
        lat = tab.Var2;
        lng = tab.Var3;
        clear tab;
        
        % filter data based on histogram
        lng_km = 111*cos(mean(lat)*pi/180);
        hist_res_lng = 0.5/lng_km;
        [time, lat, lng, ~] = filter_hist(time, lat, lng, hist_res_lat, hist_res_lng, hist_threshold);
        
        % filter data based on speed
        latlong_km = sqrt(lat_km^2 + lng_km^2);
        speed_max = 1/latlong_km/3600;
        [time, lat, lng, ~] = filter_speed(time, lat, lng, speed_max);
        
        % cluster data
        kmeans_distance_max = 10/latlong_km; % 10km 
        lab = cluster_kmeans(lat, lng, n_kmeans_init, kmeans_distance_max);
        
        cnt = cnt+1;
        
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
    
end