function auc = rf_binaryclassifier(xtrain, ytrain, xtest, ytest)

n_tree = 1000;

if isempty(xtrain)||isempty(xtest),
    auc = 0;
else
    
    if length(unique(ytrain))~=2,
        error('rf_binaryclassifier: ytrain must be binary.');
    end
    
    y_uniq = unique(ytrain);
    ind0 = find(ytrain==y_uniq(1));
    ind1 = find(ytrain==y_uniq(2));
    ytrain(ind0) = 0;
    ytrain(ind1) = 1;
    
    ind0 = find(ytest==y_uniq(1));
    ind1 = find(ytest==y_uniq(2));
    ytest(ind0) = 0;
    ytest(ind1) = 1;
    
    mdl = TreeBagger(n_tree, xtrain, ytrain, 'method', 'classification');
    
    [~, pr] = predict(mdl, xtest);
    state_pr = pr(:,2);
    
%     cnt = 1;
%     for phq_th = 0:.05:1,
%         state_pred = (state_pr>=phq_th);
%         sensitivity(cnt) = sum(state_pred(ytest==1)==1)/sum(ytest==1);
%         specificity(cnt) = sum(state_pred(ytest==0)==0)/sum(ytest==0);
%         cnt = cnt+1;
%     end
%     auc = abs(trapz(1-specificity, sensitivity));

    state_pred = state_pr>=.5;
    auc = mean(state_pred==ytest);
     
end

end