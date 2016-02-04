function [time_out, lat_out, lng_out, ind] = filter_speed(time, lat, lng, speed_max)

spd_temp = sqrt((diff(lng)./diff(time)).^2+(diff(lat)./diff(time)).^2);
spd_temp = smooth_speed(spd_temp);
ind = find(spd_temp<speed_max);
lng_out = lng(ind);
lat_out = lat(ind);
time_out = time(ind);

fprintf('%.0f%% of data removed by speed filtering.\n',(length(lng)-length(ind))/length(lng)*100);

end