function [speed, time_speed] = estimate_speed(time, lat, lng, speed_gap_threshold)

lng = 111*cos(lat*pi/180).*lng; %km
lat = 111*lat; % km

time_speed = diff(time);
speed = sqrt((diff(lng)./time_speed).^2+(diff(lat)./time_speed).^2);

% removing speed values calculated over long periods (gaps)
ind_gaps = find(time_speed>speed_gap_threshold);
fprintf('Speed Estimation: %.2f%% of speed data removed.\n',length(ind_gaps)/length(speed)*100);
speed(ind_gaps) = [];
time_speed(ind_gaps) = [];

% This function makes the speed signal smooth so that it is more robust to GPS outliers
speed = smooth_speed(speed);

end
