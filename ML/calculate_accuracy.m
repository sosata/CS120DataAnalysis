% This function currently only works for 2 classes

function [accuracy, precision, recall] = calculate_accuracy(y, y_pred)

if length(y)~=length(y_pred)
    error('inputs should have the same length');
end

y_uniq = unique(y);
if length(y_uniq)~=2,
    error('this function only works for 2 classes.');
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