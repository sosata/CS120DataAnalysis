function [feature, feature_label] = extract_features_sleep(data)

feature_label = {'sleep mean', 'bed mean', 'sleep quality mean', 'sleep var', 'bed var', 'sleep quality var', 'no workdays'};

if isempty(data),
    feature = NaN*ones(1,length(feature_label));
    return;
end

if isempty(data{1}),
    feature = NaN*ones(1,length(feature_label));
    return;
end

% timestamps are in ms
data{2} = data{2}/1000;
data{3} = data{2}/1000;
data{4} = data{2}/1000;
data{5} = data{2}/1000;

sleep_duration_mean = nanmean(data{4}-data{3});
bed_duration_mean = nanmean(data{5}-data{2});
sleep_quality_mean = nanmean(data{6});
sleep_duration_var = nanvar(data{4}-data{3});
bed_duration_var = nanvar(data{5}-data{2});
sleep_quality_var = nanvar(data{6});
n_workdays = sum(strcmp(data{7},'normal'));


feature = [sleep_duration_mean, bed_duration_mean, sleep_quality_mean, sleep_duration_var, bed_duration_var, sleep_quality_var, n_workdays];

end