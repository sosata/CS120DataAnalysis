function [feature, feature_label] = extract_features_sleep(data)

% feature_label = {'sleep mean', 'bed mean', 'sleep quality mean', 'sleep var', 'bed var', 'sleep quality var', 'no workdays'};
feature_label = {'sleep mean', 'bed mean', 'sleep var', 'bed var'};

if isempty(data),
    feature = NaN*ones(1,length(feature_label));
    return;
end

if isempty(data.Var1),
    feature = NaN*ones(1,length(feature_label));
    return;
end

% timestamps are in ms
t_bed = data.Var2/1000/3600;
t_sleep = data.Var3/1000/3600;
t_wake = data.Var4/1000/3600;
t_getup = data.Var5/1000/3600;

sleep_duration_mean = nanmean(t_wake - t_sleep);
bed_duration_mean = nanmean(t_getup - t_bed);
sleep_duration_var = nanvar(t_wake - t_sleep);
bed_duration_var = nanvar(t_getup - t_bed);
% sleep_quality_mean = nanmean(data.Var6);
% sleep_quality_var = nanvar(data.Var6);
% n_workdays = sum(strcmp(data.Var7,'normal'));


% feature = [sleep_duration_mean, bed_duration_mean, sleep_quality_mean, sleep_duration_var, bed_duration_var, sleep_quality_var, n_workdays];
feature = [sleep_duration_mean, bed_duration_mean, sleep_duration_var, bed_duration_var];

end