function R2 = train_randsample(x, y, n_bootstrap, p_train, regressor)

if isempty(x),
    
    R2 = -Inf;
    
else
    
    if iscell(x),
        x = combine_subjects(x);
    end
    if iscell(y),
        y = combine_subjects(y);
    end
    if size(x,1)~=length(y),
        error('train_randsample: x and y must have the same number of rows.')
    end
    
    R2 = zeros(n_bootstrap,1);
    
    parfor k=1:n_bootstrap,
        
        ind_train = randsample(1:size(x,1), round(size(x,1)*p_train), false);
        ind_test = 1:size(x,1);
        ind_test(unique(ind_train)) = [];
        
        if isempty(ind_test),
            fprintf('empty test set. skipping...\n');
            continue;
        end
        
        R2(k) = regressor(x(ind_train,:), y(ind_train), x(ind_test,:), y(ind_test));
        
    end
end

end