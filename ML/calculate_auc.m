function auc = calculate_auc(y, y_pred)

if length(y)~=length(y_pred)
    error('inputs should have the same length');
end

y_uniq = unique(y);
if length(y_uniq)~=2,
    error('this function only works for 2 classes.');
end
ypos = y_uniq(2);

%     state_pr = pr(:,2);
%     cnt = 1;
%     for phq_th = 0:.05:1,
%         state_pred = (state_pr>=phq_th);
%         sensitivity(cnt) = sum(state_pred(ytest==1)==1)/sum(ytest==1);
%         specificity(cnt) = sum(state_pred(ytest==0)==0)/sum(ytest==0);
%         cnt = cnt+1;
%     end
%     auc = abs(trapz(1-specificity, sensitivity));

[~,~,~,auc] = perfcurve(y, y_pred, ypos);

end