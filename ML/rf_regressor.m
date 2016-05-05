function R2 = rf_regressor(xtrain, ytrain, xtest, ytest)

n_tree = 1000;

if isempty(xtrain)||isempty(xtest),
    R2 = -Inf;
else
    
    mdl = TreeBagger(n_tree, xtrain, ytrain, 'Method', 'regression');
    out = predict(mdl, xtest);
    
    R2 = 1-mean((out-ytest).^2)/mean((mean(ytrain)-ytest).^2);
    
end

end