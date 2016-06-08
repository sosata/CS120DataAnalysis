%% 
% This calculuates the average sleep duration for both target and predicted
% vectors for all subjects, then looks at their difference
%
% This is not necessarily what we want for the end product (still need to 
% do trial alignment and get individual sleep difference), but it's a
% start.

%%

clear;
close all;

addpath('../Functions/');
load('features_sleepdetection');
load('results_newfeatures');
load('../settings.mat');

%% Plot to figure out what we're working with

figure(1)
clf; hold on;
plot(out.target{1}(:))
plot(out.prediction3{1}(:))
hold off

%% For all subjects

n_subjects = length(subjects);
time_mod = 10; % 10m bin time

avg_target_dur = zeros(n_subjects,1);
avg_pred_dur = zeros(n_subjects,1);

for i = 1:n_subjects
    x = out.target{i}(:);
    y = out.prediction3{i}(:);
    
    if ~isempty(x) & ~isempty(y)
        target_times = get_start_and_end_times(x);
        pred_times = get_start_and_end_times(y);

        target_sleep_mean = nanmean(target_times(:,2) - target_times(:,1)) ...
            * time_mod;
        pred_sleep_mean = nanmean(pred_times(:,2) - pred_times(:,1))...
            * time_mod;

        avg_target_dur(i) = nanmean(target_sleep_mean);
        avg_pred_dur(i) = nanmean(pred_sleep_mean);
    else
        avg_target_dur(i) = NaN;
        avg_pred_dur(i) = NaN;
    end
end

figure(11)
plot(avg_target_dur - avg_pred_dur)

rmsd = sqrt(nanmean((avg_target_dur - avg_pred_dur).^2))