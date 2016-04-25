function [feature, feature_label] = extract_features_audio(data)

feature_label = {'audio mean','audio var','freq mean','freq var'};

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
frequency_mean = nanmean(data.Var3);
frequency_var = nanvar(data.Var3);

feature = [power_mean,power_var,frequency_mean,frequency_var];

end