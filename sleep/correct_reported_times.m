function [timestamp, time_bed, time_sleep, time_wake, time_up] = correct_reported_times(timestamp, time_bed, time_sleep, time_wake, time_up)

% shifting 12-3pm to 12-3am (only for samples with sleep duration >= 15)

ind_mixup = (mod(time_sleep,86400)/3600>=12)&(mod(time_sleep,86400)/3600<15)&...
    ((time_wake-time_sleep)/3600>=15);
time_sleep(ind_mixup) = time_sleep(ind_mixup) + 12*3600;

% removing remaning instances of sleep duration >= 15h

ind_long = (time_wake-time_sleep)/3600>=15;
time_bed(ind_long) = [];
time_sleep(ind_long) = [];
time_wake(ind_long) = [];
time_up(ind_long) = [];
timestamp(ind_long) = [];

% removing instances of sleep duration < 1h

ind_short = (time_wake-time_sleep)/3600<1;
time_bed(ind_short) = [];
time_sleep(ind_short) = [];
time_wake(ind_short) = [];
time_up(ind_short) = [];
timestamp(ind_short) = [];


% removing the sample if its sleep time is before previous sample's wake-up
% time

ind_double = find((time_sleep(2:end)-time_wake(1:end-1))<=0) + 1;
time_bed(ind_double) = [];
time_sleep(ind_double) = [];
time_wake(ind_double) = [];
time_up(ind_double) = [];
timestamp(ind_double) = [];



end