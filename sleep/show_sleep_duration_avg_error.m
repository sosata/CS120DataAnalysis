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
load('bad_subjects.mat');

ind_good = ones(size(feature));
ind_good(ind_bad) = 0;
ind_good(183) = 0;
ind_good = find(ind_good);

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

rmsd_dur = cellfun(@(x) sqrt(nanmean(x.^2)), dur_error)*time_mod;
rmsd_start = cellfun(@(x) sqrt(nanmean(x.^2)), start_error)*time_mod;
rmsd_end = cellfun(@(x) sqrt(nanmean(x.^2)), end_error)*time_mod;
med_dur = cellfun(@(x) nanmedian(abs(x)), dur_error)*time_mod;
med_start = cellfun(@(x) nanmedian(abs(x)), start_error)*time_mod;
med_end = cellfun(@(x) nanmedian(abs(x)), end_error)*time_mod;

fprintf('duration rmsd: %.1f (%.2f)\n', nanmean(rmsd_dur), nanstd(rmsd_dur)/sqrt(length(rmsd_dur)))
fprintf('start rmsd: %.1f (%.2f)\n', nanmean(rmsd_start), nanstd(rmsd_start)/sqrt(length(rmsd_start)))
fprintf('end rmsd: %.1f (%.2f)\n', nanmean(rmsd_end), nanstd(rmsd_end)/sqrt(length(rmsd_end)))
fprintf('duration error median: %.1f (%.2f)\n', nanmean(med_dur), nanstd(med_dur)/sqrt(length(med_dur)))
fprintf('start error median: %.1f (%.2f)\n', nanmean(med_start), nanstd(med_start)/sqrt(length(med_start)))
fprintf('end error median: %.1f (%.2f)\n', nanmean(med_end), nanstd(med_end)/sqrt(length(med_end)))

return;

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
histogram(dur_error{example_subj},10)

%% Visualize data for all subjects

figure(31)
rmsd_dur_error = cellfun(@(x) sqrt(mean(x.^2)), dur_error) * 10 / 60;
histogram(rmsd_dur_error)
xlabel('RMSD in Duration (h)')
ylabel('# of participants')

figure(32)
plot(cellfun(@(x) nanmean(x), dur_error) * 10 / 60, cellfun(@(x) nanstd(x), dur_error) * 10 / 60, '.','markersize',10)
xlabel('duration error mean')
ylabel('duration error std')

figure(33)
clf
abox_1 = [0,250,0,100];
bins = 0:20:250;

subplot(2,2,1)
hold on
data = med_start(ind_good);
histogram(data, bins)
center_val = nanmean(data);
plot(center_val*[1,1], abox_1(3:4), 'k--')
text(center_val+5, 0.75*abox_1(end), ...
    sprintf('mean: %0.0f min', center_val));
hold off
axis(abox_1)
title('start onset error')
xlabel('MAD of sleep onset time (m)')
ylabel('# of participants')

subplot(2,2,2)
hold on
data = med_end(ind_good);
histogram(data, bins)
center_val = nanmean(data);
plot(center_val*[1,1], abox_1(3:4), 'k--')
text(center_val+5, 0.75*abox_1(end), ...
    sprintf('mean: %0.0f min', center_val));
hold off
axis(abox_1)
title('wake time error')
xlabel('MAD of wake time (m)')
ylabel('# of participants')

subplot(2,1,2)
hold on
data = med_dur(ind_good);
histogram(data, bins)
center_val = nanmean(data);
plot(center_val*[1,1], abox_1(3:4), 'k--')
text(center_val+5, 0.75*abox_1(end), ...
    sprintf('mean: %0.0f min', center_val));
hold off
axis(abox_1)
title('sleep duration error')
xlabel('MAD of duration (m)')
ylabel('# of participants')


figure(34)
clf
hold on
histogram(med_dur, bins)
histogram(med_dur(ind_good), bins)
hold off

%% Does duration dictate prediction error?

figure(41)
clf
xval = cellfun(@nanmean, aln_targ_dur) * time_mod;
yval = med_dur;

% Remove nans
nonan_idx = (~isnan(xval)&~isnan(yval));
xval = xval(nonan_idx);
yval = yval(nonan_idx);

coeffs = polyfit(xval, yval, 1);
fitx = linspace(min(xval), max(xval), 200);
fity = polyval(coeffs, fitx);
r = corrcoef(xval, yval, 'rows', 'complete');

hold on
scatter(xval, yval, '.')
plot(fitx, fity, 'k--')
text(0.7*(max(xval)-min(xval)) + min(xval), ...
    0.7*(max(yval)-min(yval)) + min(yval), ...
    sprintf('r=%0.2f', r(1,2)))
hold off

xlabel('Avg. Subject Sleep Duration (m)')
ylabel('Subject Duration Prediction MAD (m)')


figure(42)
clf
xval = cellfun(@nanmean, aln_targ_dur(ind_good)) * time_mod;
yval = cellfun(@nanmean, aln_pred_dur(ind_good)) * time_mod;

% Remove nans
nonan_idx = (~isnan(xval)&~isnan(yval));
xval = xval(nonan_idx);
yval = yval(nonan_idx);

coeffs = polyfit(xval, yval, 1);
fitx = linspace(min(xval), max(xval), 200);
fity = polyval(coeffs, fitx);
r = corrcoef(xval, yval, 'rows', 'complete');

hold on
scatter(xval, yval, '.')
plot(fitx, fity, 'k--')
text(0.7*(max(xval)-min(xval)) + min(xval), ...
    0.25*(max(yval)-min(yval)) + min(yval), ...
    sprintf('r=%0.2f', r(1,2)))
hold off

xlabel('Avg. Subject Sleep Duration (m)')
ylabel('Avg. Predicted Subject Sleep Duration (m)')


figure(43)
clf
xval = cellfun(@nanmean, aln_targ_dur(ind_good)) * time_mod;
yval = cellfun(@nanmean, dur_error(ind_good)) * time_mod;

% Remove nans
nonan_idx = (~isnan(xval)&~isnan(yval));
xval = xval(nonan_idx);
yval = yval(nonan_idx);

coeffs = polyfit(xval, yval, 1);
fitx = linspace(min(xval), max(xval), 200);
fity = polyval(coeffs, fitx);
r = corrcoef(xval, yval, 'rows', 'complete');

hold on
scatter(xval, yval, '.')
plot(fitx, fity, 'k--')
text(0.7*(max(xval)-min(xval)) + min(xval), ...
    0.7*(max(yval)-min(yval)) + min(yval), ...
    sprintf('r=%0.2f', r(1,2)))
hold off

xlabel('Avg. Subject Sleep Duration (m)')
ylabel('Avg. Error in Subject Sleep Duration (m)')


figure(44)
clf
bins2 = -150:20:150;
abox_2 = [-150,150,0,70];
hold on
data = cellfun(@nanmean, dur_error) * time_mod;
histogram(data, bins2)
center_val = nanmean(data);
plot(center_val*[1,1], abox_2(3:4), 'k--')
text(center_val+5, 0.75*abox_2(end), ...
    sprintf('mean: %0.0f min', center_val));
hold off
axis(abox_2)

%% Is this a bias in start or end times?

figure(53)
clf
xval = cellfun(@nanmean, aln_targ_dur(ind_good)) * time_mod;
yval = cellfun(@nanmean, start_error(ind_good)) * time_mod;

% Remove nans
nonan_idx = (~isnan(xval)&~isnan(yval));
xval = xval(nonan_idx);
yval = yval(nonan_idx);

coeffs = polyfit(xval, yval, 1);
fitx = linspace(min(xval), max(xval), 200);
fity = polyval(coeffs, fitx);
r = corrcoef(xval, yval, 'rows', 'complete');

hold on
scatter(xval, yval, '.')
plot(fitx, fity, 'k--')
text(0.7*(max(xval)-min(xval)) + min(xval), ...
    0.7*(max(yval)-min(yval)) + min(yval), ...
    sprintf('r=%0.2f', r(1,2)))
hold off

xlabel('Avg. Subject Sleep Duration (m)')
ylabel('Avg. Error in Subject Sleep Start Time (pred. - true.) (m)')


figure(54)
clf
xval = cellfun(@nanmean, aln_targ_dur(ind_good)) * time_mod;
yval = cellfun(@nanmean, end_error(ind_good)) * time_mod;

% Remove nans
nonan_idx = (~isnan(xval)&~isnan(yval));
xval = xval(nonan_idx);
yval = yval(nonan_idx);

coeffs = polyfit(xval, yval, 1);
fitx = linspace(min(xval), max(xval), 200);
fity = polyval(coeffs, fitx);
r = corrcoef(xval, yval, 'rows', 'complete');

hold on
scatter(xval, yval, '.')
plot(fitx, fity, 'k--')
text(0.7*(max(xval)-min(xval)) + min(xval), ...
    0.7*(max(yval)-min(yval)) + min(yval), ...
    sprintf('r=%0.2f', r(1,2)))
hold off

xlabel('Avg. Subject Sleep Duration (m)')
ylabel('Avg. Error in Subject Sleep Start Time (pred. - true.) (m)')

%% Do start and end times show the same relation to early or late sleepers?

figure(63)
clf
xval = cellfun(@(x) nanmean(x(:,1)), aln_targs(ind_good)) * time_mod;
yval = cellfun(@nanmean, start_error(ind_good)) * time_mod;

% Remove nans
nonan_idx = (~isnan(xval)&~isnan(yval));
xval = xval(nonan_idx);
yval = yval(nonan_idx);

coeffs = polyfit(xval, yval, 1);
fitx = linspace(min(xval), max(xval), 200);
fity = polyval(coeffs, fitx);
r = corrcoef(xval, yval, 'rows', 'complete');

hold on
scatter(xval, yval, '.')
plot(fitx, fity, 'k--')
text(0.7*(max(xval)-min(xval)) + min(xval), ...
    0.7*(max(yval)-min(yval)) + min(yval), ...
    sprintf('r=%0.2f', r(1,2)))
hold off

xlabel('Avg. Subject Sleep Start Time (m)')
ylabel('Avg. Error in Subject Sleep Start Time (pred. - true.) (m)')


figure(64)
clf
xval = cellfun(@(x) nanmean(x(:,2)), aln_targs(ind_good)) * time_mod;
yval = cellfun(@nanmean, end_error(ind_good)) * time_mod;

% Remove nans
nonan_idx = (~isnan(xval)&~isnan(yval));
xval = xval(nonan_idx);
yval = yval(nonan_idx);

coeffs = polyfit(xval, yval, 1);
fitx = linspace(min(xval), max(xval), 200);
fity = polyval(coeffs, fitx);
r = corrcoef(xval, yval, 'rows', 'complete');

hold on
scatter(xval, yval, '.')
plot(fitx, fity, 'k--')
text(0.7*(max(xval)-min(xval)) + min(xval), ...
    0.7*(max(yval)-min(yval)) + min(yval), ...
    sprintf('r=%0.2f', r(1,2)))
hold off

xlabel('Avg. Subject Sleep End Time (m)')
ylabel('Avg. Error in Subject Sleep End Time (pred. - true.) (m)')

%% How do we do on predicting sleep outliers?

% for i = 1:n_subjects
%     figure(2000)
%     histogram(aln_targ_dur{i}/6,0:19)
%     axis([0,18,0,20])
%     pause;
% end

% Is there something odd about sleep distributions?

targ_skew = cellfun(@skewness, aln_targ_dur);
targ_kurt = cellfun(@kurtosis, aln_targ_dur);

figure(2001)
clf
xval = med_dur * time_mod;
yval = targ_skew;

% Remove nans
nonan_idx = (~isnan(xval)&~isnan(yval));
xval = xval(nonan_idx);
yval = yval(nonan_idx);

coeffs = polyfit(xval, yval, 1);
fitx = linspace(min(xval), max(xval), 200);
fity = polyval(coeffs, fitx);
r = corrcoef(xval, yval, 'rows', 'complete');

hold on
scatter(xval, yval, '.')
plot(fitx, fity, 'k--')
text(0.7*(max(xval)-min(xval)) + min(xval), ...
    0.7*(max(yval)-min(yval)) + min(yval), ...
    sprintf('r=%0.2f', r(1,2)))
hold off

xlabel('median sleep duration (m)')
ylabel('skew in sleep duration')

figure(2002)
clf
xval = cellfun(@mean, aln_targ_dur);
yval = targ_kurt;

% Remove nans
nonan_idx = (~isnan(xval)&~isnan(yval));
xval = xval(nonan_idx);
yval = yval(nonan_idx);

coeffs = polyfit(xval, yval, 1);
fitx = linspace(min(xval), max(xval), 200);
fity = polyval(coeffs, fitx);
r = corrcoef(xval, yval, 'rows', 'complete');

hold on
scatter(xval, yval, '.')
plot(fitx, fity, 'k--')
text(0.7*(max(xval)-min(xval)) + min(xval), ...
    0.7*(max(yval)-min(yval)) + min(yval), ...
    sprintf('r=%0.2f', r(1,2)))
hold off

xlabel('average sleep duration (m)')
ylabel('skew in sleep duration')

figure(2003)
clf
xval = cellfun(@std, aln_targ_dur) * time_mod;
yval = med_dur;

% Remove nans
nonan_idx = (~isnan(xval)&~isnan(yval));
xval = xval(nonan_idx);
yval = yval(nonan_idx);

coeffs = polyfit(xval, yval, 1);
fitx = linspace(min(xval), max(xval), 200);
fity = polyval(coeffs, fitx);
r = corrcoef(xval, yval, 'rows', 'complete');

hold on
scatter(xval, yval, '.')
plot(fitx, fity, 'k--')
text(0.7*(max(xval)-min(xval)) + min(xval), ...
    0.7*(max(yval)-min(yval)) + min(yval), ...
    sprintf('r=%0.2f', r(1,2)))
hold off

xlabel('std. deviation of sleep duration (m)')
ylabel('MAD of predictions')

%%

for i = 1:n_subjects
    figure(2000)
    clf
    hold on
    histogram(aln_targ_dur{i}/6,0:19)
    histogram(aln_pred_dur{i}/6,0:19)
    hold off
    title(subject_sleep{i})
    legend('True', 'Predicted')
    axis([0,18,0,20])
    pause;
end