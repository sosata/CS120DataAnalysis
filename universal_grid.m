function [lat_out, lng_out] = universal_grid(lat, lng, res)

lat_out = 111*lat; % km
lng_out = 111*cos(lat*pi/180).*lng; %km

lat_out = round(lat_out/res)*res;
lng_out = round(lng_out/res)*res;

end