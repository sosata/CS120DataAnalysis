function R2 = rf_regressor(x, y, n_tree, n_bootstrap)

    parfor k=1:n_bootstrap,
        
        ind_train = randsample(1:size(x,1), round(size(x,1)*.7), false);
        ind_test = 1:size(x,1);
        ind_test(unique(ind_train)) = [];
        if isempty(ind_test),
            fprintf('empty test set. skipping...\n');
            continue;
        end
        
        mdl = TreeBagger(n_tree, x(ind_train,:), y(ind_train), 'Method', 'regression');
        out = predict(mdl, x(ind_test,:));
        
        R2(k) = 1-mean((out-y(ind_test)).^2)/mean((mean(y(ind_train))-y(ind_test)).^2);
        
    end
    

end