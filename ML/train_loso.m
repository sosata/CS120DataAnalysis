% leave one-subject-out

function out = train_loso(x, y, regressor)

if isempty(x),
    
    out.performance = -Inf;
    
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
        
        outreg = regressor(xtrain, ytrain, xtest, ytest);
        perf(k,:) = outreg.performance;
        
        fprintf(' %.2f', perf(k,:));
        fprintf('\n');
    end
    
    out.performance = perf;
end

end