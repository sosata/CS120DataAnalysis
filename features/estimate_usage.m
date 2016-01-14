function [duration, frequency] = estimate_usage(time, state, dur_threshold_low, dur_threshold_high)

states = unique(state);

if length(states)<2,
    duration = 0;
    frequency = 0;
    return;
end


% if (length(states)~=2)||(states(1)~='False')||(states(2)~='True'),
%     error('estimate_usage: inappropriate usage state vector!');
% end

dur = [];
for k = 2:length(state),
    if strcmp(state(k),'False')&&strcmp(state(k-1),'True'),  % data is stored only at transition
        dur_temp = time(k)-time(k-1);
        if (dur_temp>=dur_threshold_low)&&(dur_temp<=dur_threshold_high),
            dur = [dur, dur_temp];
        end
    end
end

duration = sum(dur);
frequency = length(dur);

end