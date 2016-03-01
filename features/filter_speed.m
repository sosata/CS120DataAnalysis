function [time_out, lat_out, lng_out, ind] = filter_speed(time, lat, lng, speed_max)

% removing duplicate timestamps if the exist
ind_dup = find(diff(time)==0)+1;
if ~isempty(ind_dup),
    time(ind_dup) = [];
    lat(ind_dup) = [];
    lng(ind_dup) = [];
end

if length(time)>=2,
    spd_temp = sqrt((diff(lng)./diff(time)).^2+(diff(lat)./diff(time)).^2);
    spd_temp = smooth_speed(spd_temp);
    ind = find(spd_temp<=speed_max);
    lng_out = lng(ind);
    lat_out = lat(ind);
    time_out = time(ind);
    %fprintf('%.0f%% of data removed by speed filtering.\n',(length(lng)-length(ind))/length(lng)*100);
else
    time_out = [];
    lat_out = [];
    lng_out = [];
    ind = [];
end

end