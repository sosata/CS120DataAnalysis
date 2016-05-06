clear;
close all;

addpath('../functions');
addpath('../ML');

good_features = true;
plot_results = false;
save_results = false;

n_bootstrap = 12;
p_train = .7;

if good_features,
    load('features_sleep_workdayinfo.mat');
else
    load('features_sleep.mat');
end

% if ~good_features,
%     feature{i}(:,6) = [];
% end

auc = train_personal_random(feature, state, n_bootstrap, p_train, @rf_binaryclassifier);

nanmean(auc)

if save_results,
    if good_features,
        save('results_sleep_workdayinfo.mat', 'auc', 'sensitivity', 'specificity');
    else
        save('results_sleep.mat', 'auc', 'sensitivity', 'specificity');
    end
end
