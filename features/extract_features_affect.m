function [feature, feature_label] = extract_features_affect(data)

feature_label = {'stress mean', 'mood mean', 'energy mean', 'focus mean', 'stress std', 'mood std', 'energy std', ...
    'focus std', 'compliance'};

if isempty(data),
    feature = NaN*ones(1,length(feature_label));
    return;
end

stress_mean = nanmean(data{2});
mood_mean = nanmean(data{3});
energy_mean = nanmean(data{4});
focus_mean = nanmean(data{5});

stress_std = nanstd(data{2});
mood_std = nanstd(data{3});
energy_std = nanstd(data{4});
focus_std = nanstd(data{5});

compliance = nanmean(length(data{1})/(range(data{1})/86400));   % nanmean to generate nan when argument is empty

feature = [stress_mean, mood_mean, energy_mean, focus_mean, stress_std, mood_std, energy_std, focus_std, compliance];

end