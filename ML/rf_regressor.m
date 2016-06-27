function out = rf_regressor(xtrain, ytrain, xtest, ytest)

n_tree = 1000;

if isempty(xtrain)||isempty(xtest),
    out = [];
else

    mdl = TreeBagger(n_tree, xtrain, ytrain, 'Method', 'regression');
    
    if ~iscell(xtest),
        y_pred = predict(mdl, xtest);
        
        out.rf = nan;
        out.medianfilter = nan;
        out.hmm = nan;
        
        out.performance = 1-nanmean((y_pred-ytest).^2)/nanmean((nanmean(ytrain)-ytest).^2);
    else
        for i=1:length(xtest)
            y_pred = predict(mdl, xtest{i});
            out.rf{i} = nan;
            out.medianfilter{i} = nan;
            out.hmm{i} = nan;
            
            out.performance(i,:) = 1-nanmean((y_pred-ytest{i}).^2)/nanmean((nanmean(ytrain)-ytest{i}).^2);
            
        end
        
    end
end

end