function energy = estimate_circadian_movement(time, lat, lng)

lng = 111*cos(lat*pi/180).*lng; %km
lat = 111*lat; %km

[P1, F1] = plomb(lat, time, 'psd');
[P2, F2] = plomb(lng, time, 'psd');

if isinf(P1),
    disp('Warning: Inf value power for latitude');
end
if isinf(P2),
    disp('Warning: Inf value power for longitude');
end

f_circadian_low = 1/(86400+30*60);
f_circadian_high = 1/(86400-30*60);
energy1 = sum(P1((F1>=f_circadian_low)&(F1<=f_circadian_high)))/length(P1((F1>=f_circadian_low)&(F1<=f_circadian_high)));%/lat.^2);
energy2 = sum(P2((F2>=f_circadian_low)&(F2<=f_circadian_high)))/length(P2((F2>=f_circadian_low)&(F2<=f_circadian_high)));%/lng.^2);
energy = energy1+energy2;

if isinf(energy),
    disp('Warning: Inf value for circadian movement');
end
if isempty(energy),
    disp('Warning: empty value for circadian movement');
end
