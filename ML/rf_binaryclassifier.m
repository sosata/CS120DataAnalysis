function out = rf_binaryclassifier(xtrain, ytrain, xtest, ytest)

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
    
%     [xtrain, ytrain] = stratify(xtrain, ytrain);
    
    mdl = TreeBagger(n_tree, xtrain, ytrain, 'method', 'classification');
    
    [state_pred, ~] = predict(mdl, xtest);
    state_pred = cellfun(@str2num, state_pred);

    [accuracy, precision, recall] = calculate_accuracy(ytest, state_pred);
    out = [accuracy, precision, recall];
    
end

end