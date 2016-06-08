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
load('results_personal_correctedtimes');
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

%% Visualize aggregate data

figure(11)
plot(avg_target_dur - avg_pred_dur)

% rmsd = sqrt(nanmean((avg_target_dur - avg_pred_dur).^2))
% fprintf('duration rmsd: %.1f (%.2f)\n', nanmean(rmsd), nanstd(rmsd)/sqrt(length(rmsd)))

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
        
        start_error{i} = aln_preds{i}(:,1) - aln_targs{i}(:,1);
        end_error{i} = aln_preds{i}(:,2) - aln_targs{i}(:,2);
        
        
        % <TODO>
        % There might be a fencepost error here.
        % End times (:,2) are the index of the last sleep-positive bin
        % We may need to add one to get the proper duration
        % Otherwise, our duration estimates may be 10m short.
        % Look into this at some point.
        
        aln_pred_dur{i} = aln_pred_times(:,2) - aln_pred_times(:,1) + 1;
        aln_targ_dur{i} = targ_times_nonan(:,2) - targ_times_nonan(:,1) + 1;
        dur_error{i} = aln_pred_dur{i} - aln_targ_dur{i};
    end
end

rmsd_dur = cellfun(@(x) sqrt(nanmean(x.^2)), dur_error);
rmsd_start = cellfun(@(x) sqrt(nanmean(x.^2)), start_error);
rmsd_end = cellfun(@(x) sqrt(nanmean(x.^2)), end_error);
fprintf('duration rmsd: %.1f (%.2f)\n', nanmean(rmsd_dur), nanstd(rmsd_dur)/sqrt(length(rmsd_dur)))
fprintf('start rmsd: %.1f (%.2f)\n', nanmean(rmsd_start), nanstd(rmsd_start)/sqrt(length(rmsd_start)))
fprintf('end rmsd: %.1f (%.2f)\n', nanmean(rmsd_end), nanstd(rmsd_end)/sqrt(length(rmsd_end)))


%% Visualize aligned data for example subject

example_subj = 1;

figure(21)
clf
subplot(3,1,1)
hold on
plot(out.target{example_subj})
plot(aln_targs{example_subj}(:,1), ...
    ones(length(aln_targs{example_subj}(:,1)), 1), '*')
plot(aln_targs{example_subj}(:,2), ...
    ones(length(aln_targs{example_subj}(:,2)), 1), '*')
hold off
xlabel('Time Bin Idx')
legend('Sleep Trace', 'Identified Start Times', 'Identified End Times')
subplot(3,1,2)
hold on
plot(out.prediction3{example_subj})
plot(aln_preds{example_subj}(:,1), ...
    ones(length(aln_preds{example_subj}(:,1)), 1), '*')
plot(aln_preds{example_subj}(:,2), ...
    ones(length(aln_preds{example_subj}(:,2)), 1), '*')
hold off
xlabel('Time Bin Idx')
legend('Sleep Trace', 'Identified Start Times', 'Identified End Times')
subplot(3,1,3)
hold on
plot(aln_preds{example_subj})
plot(aln_targs{example_subj})
hold off

figure(22)
clf
hold on
plot([aln_targs{example_subj}(:,1), aln_preds{example_subj}(:,1)]' , ...
    repmat([2,1], size(aln_targs{example_subj},1), 1)', '-ok')
plot([aln_targs{example_subj}(:,2), aln_preds{example_subj}(:,2)]' , ...
    repmat([2,1], size(aln_targs{example_subj},1), 1)', '-or')
hold off
legend('Start Time Alignments', 'End Time Alignments')
title('Sleep Cycle Alignments')

figure(23)
clf
hold on
plot([zeros(length(aln_targ_dur{example_subj}), 1), ...
    aln_targ_dur{example_subj}]', ...
    repmat(length(aln_targ_dur{example_subj})*2:-2:1, 2, 1), 'k-o')

plot([zeros(length(aln_pred_dur{example_subj}), 1), ...
    aln_pred_dur{example_subj}]', ...
    repmat(length(aln_pred_dur{example_subj})*2-0.5:-2:0.5, 2, 1), 'r-o')
hold off

figure(24)
histogram(dur_error{1})

%% Visualize data for all subjects

figure(31)
rmsd_dur_error = cellfun(@(x) sqrt(mean(x.^2)), dur_error) * 10 / 60
histogram(rmsd_dur_error)
