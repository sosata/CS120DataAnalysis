function variance = estimate_variance(lat, lng)

if isempty(lat)||isempty(lng),
    variance = nan;
else
    
    lng = 111*cos(lat*pi/180).*lng; %km
    lat = 111*lat; % km
    
    variance = sqrt(var(lng)^2 + var(lat)^2);
    %variance = log(var(lat) + var(lng));
    
%     if isinf(variance),
%         variance = -100;
%     end
end
end