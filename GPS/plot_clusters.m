clear;
close all;

addpath('../Features');
addpath('../Functions');

data_dir = '/data/CS120/';

folders = dir(data_dir);
folders(1:2) = [];
folder = folders(10).name;

filename = [data_dir, folder, '/fus.csv'];
if exist(filename, 'file'),
    tab = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
else
    error('%s does not have GPS data\n',folder);
end

tab = clip_data(tab, tab.Var1(1), tab.Var1(1)+7*86400);

time = tab.Var1;
lat = tab.Var2;
lng = tab.Var3;

figure;
plot(lng, lat,'.k');
xlabel('longitude');
ylabel('latitude');
box off;
xlim([-86.39 -86.22]);
ylim([39.7 39.82]);
axis equal;

lat_orig = lat;
lng_orig = lng;

histogram_filter = true;
speed_filter = true;

lat_km = 111;
lng_km = 111*cos(mean(lat)*pi/180);
latlong_km = sqrt(lat_km^2 + lng_km^2);
hist_res_lat = 0.5/lat_km; % (500m) histogram resolution in lattitude
hist_res_lng = 0.5/lng_km; % (500m) histogram resolution in longitude
hist_threshold = 5;%1;%%%%%%%%%%%%%%%%%%%%%%%
speed_max = 1/latlong_km/3600; % (deg/s) (=1 km/h) to find static location for filtering location data
n_kmeans_init = 1;
kmeans_distance_max = .5/latlong_km; %0.5/latlong_km; %(0.5/latlong_km)^2; % 500m 
% speed_gap_threshold = 30*60; % (5 min) to remove gaps prior to estimating the speed

lat_mean = mean(lat);
lng_mean = mean(lng);

% lat_zm = lat - lat_mean;
% lng_zm = lng - lng_mean;
    
%% filtering out transient datapoints based on speed
if speed_filter,
    n_old = length(time);
    [time, lat, lng, ~] = filter_speed(time, lat, lng, speed_max);
    out_time = 1-length(time)/n_old;
end
if isempty(time),
    error('vector empty after speed filtering.');
end

%% filtering data based on histogram
if histogram_filter,
    [time, lat, lng, ~] = filter_hist(time, lat, lng, hist_res_lat, hist_res_lng, hist_threshold);
end
if isempty(time),
    error('vector empty after hist filtering.');
end

%% kmeans clustering
[labs, centroids] = cluster_kmeans(lat, lng, n_kmeans_init, kmeans_distance_max);
num_clusters = max(labs);

figure;
plot(lng_orig, lat_orig,'.k');
hold on;
colors = lines(num_clusters);
for i=1:num_clusters,
%     plot(centroids(i,1),centroids(i,2),'.','markersize',50,'color',colors(i,:));
    plot(lng(labs==i),lat(labs==i),'.', 'color',colors(i,:));
    viscircles(centroids(i,:), kmeans_distance_max, 'color',colors(i,:));
end
xlabel('longitude');
ylabel('latitude');
box off;
% xlim([-86.39 -86.22]);
% ylim([39.7 39.82]);
% axis equal;

%% plot entropy
figure;
hold on;
for i=1:num_clusters,
    bar(i, sum(labs==i),'facecolor',colors(i,:));
end
box off;
set(gca, 'xtick', []);
set(gca,'ytick',[]);
xlabel('Location','fontsize',18);
ylabel('Visiting Frequency','fontsize',18);

%% plot circadian movement
figure;
hold on;
labdiff = find(diff(labs)~=0);
if isempty(labdiff),
    labdiff = length(labs);
end
rectangle('position', [1 0 labdiff(1) 1], 'facecolor', colors(labs(1),:));
for i=1:length(labdiff)-1,
    rectangle('position', [labdiff(i)+1 0 labdiff(i+1)-labdiff(i) 1], 'facecolor', colors(labs(labdiff(i)+1),:));
end
rectangle('position', [labdiff(end)+1 0  length(labs)-labdiff(end) 1], 'facecolor', colors(labs(end),:));