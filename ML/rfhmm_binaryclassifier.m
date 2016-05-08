function out = rfhmm_binaryclassifier(xtrain, ytrain, xtest, ytest)

n_tree = 100;

if isempty(xtrain)||isempty(xtest),
    out = [0 0 0];
else
    
    if length(unique(ytrain))~=2,
        error('rf_binaryclassifier: ytrain must be binary.');
    end
    
    y_uniq = unique(ytrain);
    ind0 = (ytrain==y_uniq(1));
    ind1 = (ytrain==y_uniq(2));
    ytrain(ind0) = 0;
    ytrain(ind1) = 1;
    
    ind0 = (ytest==y_uniq(1));
    ind1 = (ytest==y_uniq(2));
    ytest(ind0) = 0;
    ytest(ind1) = 1;
    
    % stratification of training data
    [xtrain, ytrain] = stratify(xtrain, ytrain);
    
    % training random forest
    mdl = TreeBagger(n_tree, xtrain, ytrain, 'method', 'classification');
    
    [state_pred, ~] = predict(mdl, xtest);
    state_pred = cellfun(@str2num, state_pred);

%     state_pr = pr(:,2);
%     cnt = 1;
%     for phq_th = 0:.05:1,
%         state_pred = (state_pr>=phq_th);
%         sensitivity(cnt) = sum(state_pred(ytest==1)==1)/sum(ytest==1);
%         specificity(cnt) = sum(state_pred(ytest==0)==0)/sum(ytest==0);
%         cnt = cnt+1;
%     end
%     auc = abs(trapz(1-specificity, sensitivity));
%     state_pred = state_pr>=.5;
    
    %p_transit = sum(diff(ytrain)~=0)/length(ytrain)/2;
    
    p_transit = 1/(6*24);
    state_pred = hmmviterbi(state_pred+1, [1-p_transit p_transit; p_transit 1-p_transit], [.99 .01;.01 .99]) - 1;
    
    acc = nanmean(state_pred'==ytest);
    if (sum(ytest==1)~=0)||(sum(ytest==0)~=0),
        precision = (nanmean(ytest(state_pred==1)==1)+nanmean(ytest(state_pred==0)==0))/2;
        recall = (nanmean(state_pred(ytest==1)==1)+nanmean(state_pred(ytest==0)==0))/2;
    else
        precision = nan;
        recall = nan;
        fprintf('No sleep instances in test data.\n');
    end
    out = [acc, precision, recall];
end

end