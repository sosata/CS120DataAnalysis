function energy = estimate_circadian_rhythmicity(time, period)

time = mod(time, period)/period;
energy = sum(cos(2*pi*time))^2 + sum(sin(2*pi*time))^2;
energy = energy/(length(time)^2);

end