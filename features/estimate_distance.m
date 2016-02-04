function d = estimate_distance(time, lat, lng)

if length(time)<=1,
    d = 0;
else
    d = sum(sqrt(diff(lat).^2+diff(lng).^2))/(time(end)-time(1))*3600;
end

end