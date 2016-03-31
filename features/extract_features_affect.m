function [feature, feature_label] = extract_features_affect(data)

feature_label = {'stress mean', 'mood mean', 'energy mean', 'focus mean', 'stress var', 'mood var', 'energy var', ...
    'focus var', 'stress change', 'mood change', 'energy change', 'focus change', 'compliance'};

if isempty(data),
    feature = NaN*ones(1,length(feature_label));
    return;
end

if isempty(data{1}),
    feature = NaN*ones(1,length(feature_label));
    return;
end

stress_mean = nanmean(data{2});
mood_mean = nanmean(data{3});
energy_mean = nanmean(data{4});
focus_mean = nanmean(data{5});

stress_var = nanvar(data{2});
mood_var = nanvar(data{3});
energy_var = nanvar(data{4});
focus_var = nanvar(data{5});

[data_day, ~, ~] = separate_days(data, false);

stress_change = nanmean(data_day{end}{2})-nanmean(data_day{1}{2});
mood_change = nanmean(data_day{end}{3})-nanmean(data_day{1}{3});
energy_change = nanmean(data_day{end}{4})-nanmean(data_day{1}{4});
focus_change = nanmean(data_day{end}{5})-nanmean(data_day{1}{5});

compliance = nanmean(length(data{1})/(range(data{1})/86400));   % nanmean to generate nan when argument is empty

feature = [stress_mean, mood_mean, energy_mean, focus_mean, stress_var, mood_var, energy_var, focus_var, ...
    stress_change, mood_change, energy_change, focus_change, compliance];

end