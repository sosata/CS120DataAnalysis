% leave one-subject-out

function perf = train_loso(x, y, regressor)

if isempty(x),
    
    perf = -Inf;
    
else
    
    if ~iscell(x)||~iscell(y),
        error('train_loso: x and y must cell arrays.')
    end

    perf = [];

    parfor k=1:length(y),

        fprintf('%d/%d\n',k,length(y));

        xtrain = x([1:k-1,k+1:end]);
        xtrain = combine_subjects(xtrain);
        ytrain = y([1:k-1,k+1:end]);
        ytrain = combine_subjects(ytrain);
        
        xtest = x{k};
        ytest = y{k};
        
        perf(k,:) = regressor(xtrain, ytrain, xtest, ytest);
        
    end
    
end

end