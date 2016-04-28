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

% there are cases with negative timestamp values
ind_neg = find(data.Var2<0);
ind_neg = union(ind_neg,find(data.Var3<0));
ind_neg = union(ind_neg,find(data.Var4<0));
ind_neg = union(ind_neg,find(data.Var5<0));
if ~isempty(ind_neg),
    disp(sprintf('Sleep: %d/%d datapoints removed because of negative time values.\n',size(ind_neg),length(data.Var1)));
    data(ind_neg,:) = [];
end

% timestamps are in ms
t_bed = data.Var2/1000;
t_sleep = data.Var3/1000;
t_wake = data.Var4/1000;
t_getup = data.Var5/1000;

sleep_duration_mean = nanmean((t_wake - t_sleep)/3600);
bed_duration_mean = nanmean((t_getup - t_bed)/3600);
sleep_duration_var = nanvar((t_wake - t_sleep)/3600);
bed_duration_var = nanvar((t_getup - t_bed)/3600);
% sleep_quality_mean = nanmean(data.Var6);
% sleep_quality_var = nanvar(data.Var6);
% n_workdays = sum(strcmp(data.Var7,'normal'));


% feature = [sleep_duration_mean, bed_duration_mean, sleep_quality_mean, sleep_duration_var, bed_duration_var, sleep_quality_var, n_workdays];
feature = [sleep_duration_mean, bed_duration_mean, sleep_duration_var, bed_duration_var];

end