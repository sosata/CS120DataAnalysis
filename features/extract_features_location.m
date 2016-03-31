function [features, feature_labels] = extract_features_location(data)

feature_labels = {'total distance', 'loc variance', ...
    'circadian movement', 'n clusters', 'entropy', 'normalized entropy', 'continuous entropy', ...
    'home stay', 'transition time', 'cluster cm', 'lat mean', 'lng mean'};

if isempty(data),
    features = ones(1,length(feature_labels))*NaN;
    return;
end

time = data{1};
lat = data{2};
lng = data{3};
clear data;
if isempty(time),
    features = ones(1,length(feature_labels))*NaN;
    return;
end

histogram_filter = true;
speed_filter = true;

lat_km = 111;
lng_km = 111*cos(mean(lat)*pi/180);
latlong_km = sqrt(lat_km^2 + lng_km^2);
hist_res_lat = 0.5/lat_km; % (500m) histogram resolution in lattitude
hist_res_lng = 0.5/lng_km; % (500m) histogram resolution in longitude
hist_threshold = 1;
speed_max = 1/latlong_km/3600; % (deg/s) (=1 km/h) to find static location for filtering location data
n_kmeans_init = 1;
kmeans_distance_max = 0.5/latlong_km; %0.5/latlong_km; %(0.5/latlong_km)^2; % 500m 
% speed_gap_threshold = 30*60; % (5 min) to remove gaps prior to estimating the speed

lat_mean = mean(lat);
lng_mean = mean(lng);

lat_zm = lat - lat_mean;
lng_zm = lng - lng_mean;
    
%% variance
% location_variance = estimate_variance(lat_zm, lng_zm);
% location_variance = estimate_variance(lat_zm, lng_zm)/sqrt((prctile(lat_zm,75)-prctile(lat_zm,25))^2+range(prctile(lng_zm,75)-prctile(lng_zm,25))^2);
    
%% circadian movement
%circadian_movement = log(estimate_circadian_movement(time, lat_zm, lng_zm));
circadian_movement = estimate_circadian_movement(time, lat_zm, lng_zm);
if circadian_movement>0,
    circadian_movement = log(circadian_movement);
else
    circadian_movement = 0;
end
    
%% speed features
% [spd, ~] = estimate_speed(time, lat, lng, speed_gap_threshold);
    
% speed_mean = mean(spd);
% speed_variance = var(spd);

displacement = sum(sqrt(diff(lng).^2+diff(lat).^2));
    
%% filtering data based on histogram
if histogram_filter,
    [time, lat, lng, ~] = filter_hist(time, lat, lng, hist_res_lat, hist_res_lng, hist_threshold);
end

%% filtering out transient datapoints based on speed
if speed_filter,
    n_old = length(time);
    [time, lat, lng, ~] = filter_speed(time, lat, lng, speed_max);
    out_time = 1-length(time)/n_old;
end

if isempty(time),
    features = ones(1,length(feature_labels))*NaN;
    return;
end

location_variance = estimate_variance(lat, lng);%%%%%%%%%%%

%% kmeans clustering
labs = cluster_kmeans(lat, lng, n_kmeans_init, kmeans_distance_max);
num_clusters = max(labs);

%% entropy, normalized entropy, homestay
ent = estimate_entropy(labs);
if (ent~=0),
    ent_norm = ent/log(num_clusters);  % normalized entropy
else
    ent_norm = 0;
end
ent_cont = estimate_entropy_cont(lat, 10) + estimate_entropy_cont(lng, 10);
%home_stay = estimate_homestay(labs, mode(labs));
home_stay = estimate_homestay(time, labs);

%% cluster circadian movement
clus_circadian_movement = estimate_circadian_rhythmicity(time(find(diff(labs)>0)+1), 86400);

% features = [speed_mean, speed_variance, displacement, location_variance, circadian_movement, ...
%     num_clusters, ent, ent_norm, ent_cont, home_stay, out_time];
% feature_labels = {'Speed Mean', 'Speed Variance', 'Total Distance', 'Location Variance', ...
%     'Circadian Movement', 'Number of Clusters', 'Entropy', 'Normalized Entropy', 'Continuous Entropy', 'Home Stay', 'Transition Time'};

num_clusters

features = [displacement, location_variance, circadian_movement, ...
    num_clusters, ent, ent_norm, ent_cont, home_stay, out_time, clus_circadian_movement, lat_mean, lng_mean];


end