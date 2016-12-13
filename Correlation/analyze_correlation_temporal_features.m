clear;
close all;

load('features_ema.mat');

% state_all = [cell2mat(mood'), cell2mat(energy'), cell2mat(focus'), cell2mat(calm')];
normalize = false;

cnt = 1;

feature_all = [];
state_all = [];
for i = 1:length(feature),
    state{i} = [mood{i}, energy{i}, focus{i}, calm{i}];
    if normalize,
        feature{i} = zscore(feature{i});
        state{i} = zscore(state{i});
    end
    feature_all = [feature_all; feature{i}];
    state_all = [state_all; state{i}];
end

for i=1:size(feature_all,2),
    [r, p] = corr(feature_all(:,i), state_all(:,1), 'type', 'spearman');
    fprintf('%d. %s: r=%.3f p=%.3f\n', i, feature_labels{i}, r, p);
end
