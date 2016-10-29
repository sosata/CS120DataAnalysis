function d = estimate_distance(time, lat, lng)

if length(time)<=1,
    d = 0;
else

    lng = 111*cos(lat*pi/180).*lng; %km
    lat = 111*lat; %km

    d = sum(sqrt(diff(lat).^2+diff(lng).^2))/(time(end)-time(1))*3600; % per hour
end

end