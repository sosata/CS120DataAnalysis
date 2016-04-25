%% Phone usage stats per day

function [feature, feature_label] = extract_features_usage(data, dur_threshold_low, dur_threshold_high)

feature_label = {'screen','duration','frequency'};

if isempty(data),
    feature = [0 0 0];
    return;
end

time = data.Var1;
state = data.Var2;
states = unique(state);

if length(states)<2,
    feature = [0 0 0];
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

duration = sum(dur)/(time(end)-time(1))*86400;
frequency = length(dur)/(time(end)-time(1))*86400;
screen = length(time)/(time(end)-time(1))*86400;

feature = [screen, duration, frequency];

end