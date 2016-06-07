% leave one-subject-out

function out = train_loso(x, y, regressor)

if isempty(x),
    
    out.performance = NaN;
    out.target = [];
    out.prediction1 = [];
    out.prediction2 = [];
    out.prediction3 = [];
    
else
    
    if ~iscell(x)||~iscell(y),
        error('train_loso: x and y must cell arrays.')
    end

    perf = [];
    target = cell(length(y),1);
    prediction1 = cell(length(y),1);
    prediction2 = cell(length(y),1);
    prediction3 = cell(length(y),1);
    
    parfor k=1:length(y),

        if isempty(y{k}),
            fprintf('no data for subject %d - skipping\n',k);
            continue;
        end

        xtrain = x([1:k-1,k+1:end]);
        xtrain = combine_subjects(xtrain);
        ytrain = y([1:k-1,k+1:end]);
        ytrain = combine_subjects(ytrain);
        
        xtest = x{k};
        ytest = y{k};
        
        outreg = regressor(xtrain, ytrain, xtest, ytest);
        perf(k,:) = outreg.performance;
        target{k} = [target{k}; ytest];
        prediction1{k} = [prediction1{k}; outreg.rf];
        prediction2{k} = [prediction2{k}; outreg.medianfilter];
        prediction3{k} = [prediction3{k}; outreg.hmm];
        
        fprintf('%d ',k);
        fprintf(' %.2f', perf(k,:));
        fprintf('\n');
    end
    
    out.performance = perf;
    out.prediction1 = prediction1;
    out.prediction2 = prediction2;
    out.prediction3 = prediction3;
    out.target = target;

end

end