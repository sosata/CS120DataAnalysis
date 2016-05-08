clear;
close all;

addpath('../functions');
addpath('../ML');

plot_results = false;

n_bootstrap = 12;
p_train = .85;
k_train = 3;

load('features_sleep_workdayinfo.mat');
% load('features_sleep.mat');

% removing work day info
% for i=1:length(feature),
%     feature{i}(:,end) = [];
% end

% personal model
% out = train_personal_random(feature, state, n_bootstrap, p_train, @rf_binaryclassifier);
% out = train_personal_temporal(feature, state, k_train, @rf_binaryclassifier);
% out = train_personal_temporal(feature, state, k_train, @rfhmm_binaryclassifier);

% global model
% out = train_loso(feature, state, @rf_binaryclassifier);
out = train_loso(feature, state, @rfhmm_binaryclassifier);

fprintf('accuracy: %.3f\nprecision: %.3f\nrecall: %.3f\n', nanmean(out(:,1)),nanmean(out(:,2)),nanmean(out(:,3)));

save('results.mat', 'out');