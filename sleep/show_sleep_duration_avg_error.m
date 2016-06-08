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

%% Do with aligned trials

for i = 1:n_subjects
    x = out.target{i}(:);
    y = out.prediction3{i}(:);
    
    if ~isempty(x) & ~isempty(y) % some subjects have empty targets
        target_times = get_start_and_end_times(x);
        pred_times = get_start_and_end_times(y);
        
        targ_times_nonan = target_times(~any(isnan(target_times),2),:);
        aln_pred_times = align_sleep_trials(targ_times_nonan, pred_times);
        
        aln_preds{i} = aln_pred_times;
        aln_targs{i} = targ_times_nonan;
        
        aln_pred_dur{i} = aln_pred_times(:,2) - aln_pred_times(:,1);
        aln_targ_dur{i} = targ_times_nonan(:,2) - targ_times_nonan(:,1);
        
        start_error{i} = aln_preds{i}(:,1) - aln_targs{i}(:,1);
        end_error{i} = aln_preds{i}(:,2) - aln_targs{i}(:,2);
        dur_error{i} = aln_pred_dur{i} - aln_targ_dur{i};
    end
end