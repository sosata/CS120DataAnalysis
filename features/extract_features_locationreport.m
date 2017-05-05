function [feature, feature_label] = extract_features_locationreport(data)

feature_label = {'accomplishment mean', 'pleasure mean', 'accomplishment var', 'pleasure var'};

if isempty(data),
    feature = NaN*ones(1,length(feature_label));
    return;
end

if isempty(data{1}),
    feature = NaN*ones(1,length(feature_label));
    return;
end

acc_mean = nanmean(data{9});
pls_mean = nanmean(data{10});

acc_var = nanvar(data{9});
pls_var = nanvar(data{10});

feature = [acc_mean, pls_mean, acc_var, pls_var];

end