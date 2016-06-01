function [time_bed, time_sleep, time_wake, time_up] = correct_reported_times(time_bed, time_sleep, time_wake, time_up)

ind_mixup = (mod(time_sleep,86400)/3600>=12)&(mod(time_sleep,86400)/3600<15)&...
    ((time_wake-time_sleep)/3600>=15);

time_sleep(ind_mixup) = time_sleep(ind_mixup) + 12*3600;

end