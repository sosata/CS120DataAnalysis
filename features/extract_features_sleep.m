% NOTE: All times must already been corrected

function [feature, feature_label] = extract_features_sleep(data)

% feature_label = {'sleep mean', 'bed mean', 'sleep quality mean', 'sleep var', 'bed var', 'sleep quality var', 'no workdays'};
feature_label = {'sleep mean', 'bed mean', 'sleep var', 'bed var', 'sleep midtime', 'bed midtime', ...
    'sleep time circ', 'wake time circ', 'bed time circ', 'getup time circ'};

if isempty(data),
    feature = NaN*ones(1,length(feature_label));
    return;
end

if isempty(data.Var1),
    feature = NaN*ones(1,length(feature_label));
    return;
end

% there are cases with negative timestamp values
ind_neg = find(data.Var2<0);
ind_neg = union(ind_neg,find(data.Var3<0));
ind_neg = union(ind_neg,find(data.Var4<0));
ind_neg = union(ind_neg,find(data.Var5<0));
if ~isempty(ind_neg),
    disp(sprintf('Sleep: %d/%d datapoints removed because of negative time values.\n',length(ind_neg),length(data.Var1)));
    data(ind_neg,:) = [];
end

% timestamps are in ms
t_bed = data.Var2;
t_sleep = data.Var3;
t_wake = data.Var4;
t_getup = data.Var5;

sleep_duration_mean = nanmean((t_wake - t_sleep)/3600);
bed_duration_mean = nanmean((t_getup - t_bed)/3600);

sleep_duration_var = nanvar((t_wake - t_sleep)/3600);
bed_duration_var = nanvar((t_getup - t_bed)/3600);

sleep_midpoint = mod(mean((t_sleep + t_wake)/2),86400);
bed_midpoint = mod(mean((t_bed + t_getup)/2),86400);

if length(t_bed)>1,
    sleep_circ = estimate_circadian_rhythmicity(t_sleep, 86400);
    wake_circ = estimate_circadian_rhythmicity(t_wake, 86400);
    bed_circ = estimate_circadian_rhythmicity(t_bed, 86400);
    getup_circ = estimate_circadian_rhythmicity(t_getup, 86400);
else
    sleep_circ = NaN;
    wake_circ = NaN;
    bed_circ = NaN;
    getup_circ = NaN;
end

% sleep_quality_mean = nanmean(data.Var6);
% sleep_quality_var = nanvar(data.Var6);
% n_workdays = sum(strcmp(data.Var7,'normal'));


% feature = [sleep_duration_mean, bed_duration_mean, sleep_quality_mean, sleep_duration_var, bed_duration_var, sleep_quality_var, n_workdays];
feature = [sleep_duration_mean, bed_duration_mean, sleep_duration_var, bed_duration_var, sleep_midpoint, bed_midpoint, ...
    sleep_circ, wake_circ, bed_circ, getup_circ];

end