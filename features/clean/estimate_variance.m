function variance = estimate_variance(lat, lng)

if isempty(lat)||isempty(lng),
    variance = nan;
else
    
    lng = 111*cos(lat*pi/180).*lng; %km
    lat = 111*lat; % km
    
    variance = log(var(lat) + var(lng));
    
end
end