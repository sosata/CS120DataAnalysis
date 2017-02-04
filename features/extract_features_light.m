function [feature, feature_label] = extract_features_light(data)

feature_label = {'lux mean','lux var'};

if isempty(data),
    feature = NaN*ones(1,length(feature_label));
    return;
end

if isempty(data.Var1),
    feature = NaN*ones(1,length(feature_label));
    return;
end

power_mean = nanmean(data.Var2);
power_var = nanvar(data.Var2);

feature = [power_mean,power_var];

end