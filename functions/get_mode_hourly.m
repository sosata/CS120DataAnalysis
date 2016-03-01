function [time_out, x_out] = get_mode_hourly(time, x)

hour_start = floor(time(1)/3600)*3600;
hour_end = floor(time(end)/3600)*3600;

time_out = [];
x_out = [];

for h = hour_start:3600:hour_end,
    
    ind = find((time>=h)&(time<h+3600));
    if ~isempty(ind),
        time_out = [time_out; h];
        x_out = [x_out; mode(x(ind))];
    end    
end