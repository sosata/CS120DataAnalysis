function d = estimate_distance(lat, lng)

d = sum(sqrt(diff(lat).^2+diff(lng).^2));

end