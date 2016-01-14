clear;
close all;

load('features.mat');
load('ema.mat');

n_lag = 60;
correlation_type = 'spearman';
normalize = false;
normalize_type = 'mean'; % 'mean','zscore'

if normalize,
    if strcmp(normalize_type, 'zscore'),
        feature = cellfun(@(x) zscore(x), feature, 'uniformoutput', false);
        mood = cellfun(@(x) zscore(x), mood, 'uniformoutput', false);
        calm = cellfun(@(x) zscore(x), calm, 'uniformoutput', false);
        energy = cellfun(@(x) zscore(x), energy, 'uniformoutput', false);
        focus = cellfun(@(x) zscore(x), focus, 'uniformoutput', false);
    elseif strcmp(normalize_type, 'mean'),
        feature = cellfun(@(x) x-ones(size(x,1),1)*mean(x), feature, 'uniformoutput', false);
        mood = cellfun(@(x) x-mean(x), mood, 'uniformoutput', false);
        calm = cellfun(@(x) x-mean(x), calm, 'uniformoutput', false);
        energy = cellfun(@(x) x-mean(x), energy, 'uniformoutput', false);
        focus = cellfun(@(x) x-mean(x), focus, 'uniformoutput', false);
    else
        error('Normalization type unknown!');
    end
end

c = zeros(length(feature_labels), 2*n_lag+1);
for i=1:length(subject_feature),
    ind_ema = find(strcmp(subject_ema, subject_feature{i}));
    if ~isempty(ind_ema),
        for j = 1:length(feature_labels),
            c(j,:) = c(j,:) + myxcorr(time_feature{i}, feature{i}(:,j), time_ema{ind_ema}, ...
                mood{ind_ema}+calm{ind_ema}+energy{ind_ema}+focus{ind_ema}, n_lag)';
        end
    end
end

c = c/length(subject_feature);
    
imagesc(c);
set(gca,'xtick',1:(n_lag*2+1),'xticklabel',num2str((-n_lag:n_lag)'));
set(gca,'ytick',1:length(feature_labels),'yticklabel',feature_labels);
colorbar;
xlabel('lag(state-feature)');
title('r (features vs. factor 1)');
return;

% cnt = 0;
% rm = zeros(length(lag_range), length(feature_labels));
% rc = zeros(length(lag_range), length(feature_labels));
% rf = zeros(length(lag_range), length(feature_labels));
% re = zeros(length(lag_range), length(feature_labels));
% rf1 = zeros(length(lag_range), length(feature_labels));
% rf2 = zeros(length(lag_range), length(feature_labels));
% for lag = lag_range,
%     cnt = cnt+1;
%     feature_all = [];
%     mood_all = [];
%     calm_all = [];
%     focus_all = [];
%     energy_all = [];
%     for i=1:length(time),
%         for j=1:length(time{i}),
% %             [lag_sorted, ind_sorted] = sort(time{i} - time{i}(j) + lag*86400);
% %             ind = find(lag_sorted>0, 1, 'first');
% %             ind = ind_sorted(ind);
%             dt = abs(time{i} - time{i}(j) - lag*86400);
%             [~, ind] = min(dt(dt<86400));%%%%%%%%%%%% there was a possible error
%             if ~isempty(ind),
%                 feature_all = [feature_all; feature{i}(j,:)];
%                 mood_all = [mood_all; mood{i}(ind)];
%                 calm_all = [calm_all; calm{i}(ind)];
%                 focus_all = [focus_all; focus{i}(ind)];
%                 energy_all = [energy_all; energy{i}(ind)];
%             end
%         end
%     end
%     for i=1:size(feature_all,2),
%         [rm(cnt,i), p] = corr(feature_all(:,i), mood_all, 'type', correlation_type);
%         [rc(cnt,i), p] = corr(feature_all(:,i), calm_all, 'type', correlation_type);
%         [rf(cnt,i), p] = corr(feature_all(:,i), focus_all, 'type', correlation_type);
%         [re(cnt,i), p] = corr(feature_all(:,i), energy_all, 'type', correlation_type);
%         [rf1(cnt,i), p] = corr(feature_all(:,i), .48*mood_all+.51*calm_all+.49*focus_all+.51*energy_all, 'type', correlation_type);
%         [rf2(cnt,i), p] = corr(feature_all(:,i), .64*mood_all+.33*calm_all-.59*focus_all-.37*energy_all, 'type', correlation_type);
%     end
% end

subplot 221;
imagesc(rm');
set(gca, 'xtick', 1:length(lag_range), 'xticklabel', num2str(lag_range'));
set(gca, 'ytick', 1:length(feature_labels), 'yticklabel', feature_labels);
xlabel('lag days (target - sensor)');
title('mood');
colorbar;
subplot 222;
imagesc(rc');
set(gca, 'xtick', 1:length(lag_range), 'xticklabel', num2str(lag_range'));
set(gca, 'ytick', 1:length(feature_labels), 'yticklabel', feature_labels);
xlabel('lag days (target - sensor)');
colorbar;
title('calmness');
subplot 223;
imagesc(rf');
set(gca, 'xtick', 1:length(lag_range), 'xticklabel', num2str(lag_range'));
set(gca, 'ytick', 1:length(feature_labels), 'yticklabel', feature_labels);
xlabel('lag days (target - sensor)');
colorbar;
title('focus');
subplot 224;
imagesc(re');
set(gca, 'xtick', 1:length(lag_range), 'xticklabel', num2str(lag_range'));
set(gca, 'ytick', 1:length(feature_labels), 'yticklabel', feature_labels);
xlabel('lag days (target - sensor)');
colorbar;
title('energy');

figure;
imagesc(rf1');
set(gca, 'xtick', 1:length(lag_range), 'xticklabel', num2str(lag_range'));
set(gca, 'ytick', 1:length(feature_labels), 'yticklabel', feature_labels);
xlabel('lag days (target - sensor)');
colorbar;
title('Factor 1 (~ average)');

figure;
imagesc(rf2');
set(gca, 'xtick', 1:length(lag_range), 'xticklabel', num2str(lag_range'));
set(gca, 'ytick', 1:length(feature_labels), 'yticklabel', feature_labels);
xlabel('lag days (target - sensor)');
colorbar;
title('Factor 2 (~ calmness - energy)');