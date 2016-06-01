function [time_bed, time_sleep, time_wake, time_up] = correct_reported_times(time_bed, time_sleep, time_wake, time_up)

ind_12_3pm = (mod(time_sleep,86400)/3600>=12)&(mod(time_sleep,86400)/3600<15);
time_sleep(ind_12_3pm) = time_sleep(ind_12_3pm) + 12*3600;

end