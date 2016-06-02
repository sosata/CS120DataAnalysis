function [timestamp, time_bed, time_sleep, time_wake, time_up] = correct_reported_times(timestamp, time_bed, time_sleep, time_wake, time_up)

% shifting 12-3pm to 12-3am (only for samples with sleep duration >= 15)

ind_mixup = (mod(time_sleep,86400)/3600>=12)&(mod(time_sleep,86400)/3600<15)&...
    ((time_wake-time_sleep)/3600>=15);

time_sleep(ind_mixup) = time_sleep(ind_mixup) + 12*3600;

% removing all remaning sleep duration >= 15

ind_long = (time_wake-time_sleep)/3600>=15;

time_bed(ind_long) = [];
time_sleep(ind_long) = [];
time_wake(ind_long) = [];
time_up(ind_long) = [];
timestamp(ind_long) = [];

end