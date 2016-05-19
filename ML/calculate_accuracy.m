% This function currently only works for 2 classes

function [accuracy, precision, recall] = calculate_accuracy(y, y_pred)

% removing missing observations
ind_nan = isnan(y);
y(ind_nan) = [];
y_pred(ind_nan) = [];

if length(y)~=length(y_pred)
    error('calculate_accuracy: inputs should have the same length');
end

y_uniq = unique(y);
if length(y_uniq)~=2,
    fprintf('instance skipped since there weren''t two classes in the ground truth.\n');
    accuracy = nan;
    precision = nan;
    recall = nan;
    return;
end
y1 = y_uniq(1);
y2 = y_uniq(2);

accuracy = nanmean(y==y_pred);

precision_y1 = nanmean(y(y_pred==y1)==y1);
precision_y2 = nanmean(y(y_pred==y2)==y2);
precision = mean([precision_y1 precision_y2]);

recall_y1 = nanmean(y_pred(y==y1)==y1);
recall_y2 = nanmean(y_pred(y==y2)==y2);
recall = mean([recall_y1 recall_y2]);


end