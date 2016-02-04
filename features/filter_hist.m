function [time_out, lat_out, lng_out, ind] = filter_hist(time, lat, lng, hist_res_lat, hist_res_lng, hist_threshold)

edges_lat = min(lat):hist_res_lat:max(lat)+hist_res_lat-mod(max(lat)-min(lat),hist_res_lat);
edges_lng = min(lng):hist_res_lng:max(lng)+hist_res_lng-mod(max(lng)-min(lng),hist_res_lng);
[hist_bins, hist_centers] = hist3([lng, lat], {edges_lng, edges_lat});
centers_x = hist_centers{1};
centers_y = hist_centers{2};

rad_x = (centers_x(2)-centers_x(1))/2;
rad_y = (centers_y(2)-centers_y(1))/2;
[indx, indy] = find(hist_bins>hist_threshold);
ind = [];
for i=1:length(indx),
    ind = [ind; find((abs(lng-centers_x(indx(i)))<rad_x)&(abs(lat-centers_y(indy(i)))<rad_y))];
end
ind = sort(ind);
fprintf('%.0f%% of data removed by histogram filtering.\n',(length(lng)-length(ind))/length(lng)*100);
lng_out = lng(ind);
lat_out = lat(ind);
time_out = time(ind);

end
