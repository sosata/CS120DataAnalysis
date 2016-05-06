% leave one-subject-out

function R2 = train_loso(x, y, regressor)

if isempty(x),
    
    R2 = -Inf;
    
else
    
    if ~iscell(x)||~iscell(y),
        error('train_loso: x and y must cell arrays.')
    end
    
    R2 = zeros(length(y),1);
    
    parfor k=1:length(y),
        
        xtrain = x([1:k-1,k+1:end]);
        xtrain = combine_subjects(xtrain);
        ytrain = y([1:k-1,k+1:end]);
        ytrain = combine_subjects(ytrain);
        
        xtest = x{k};
        ytest = y{k};
        
        R2(k) = regressor(xtrain, ytrain, xtest, ytest);
        
    end
end

end