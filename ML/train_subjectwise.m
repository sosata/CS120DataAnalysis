% leave one-subject-out

function out = train_subjectwise(x, y, n_fold, regressor)

if isempty(x)||isempty(y),
    
    out.performance = [NaN NaN NaN];
    out.target = [];
    out.prediction1 = [];
    out.prediction2 = [];
    out.prediction3 = [];
    
else
    
    if ~iscell(x)||~iscell(y),
        error('train_subjectwise: x and y must cell arrays.')
    end
    
    perf = cell(n_fold,1);
    target = cell(n_fold,1);
    prediction1 = cell(n_fold,1);
    prediction2 = cell(n_fold,1);
    prediction3 = cell(n_fold,1);
    
    l_fold = round(length(y)/n_fold);
    
    parfor k=1:n_fold,

        ind_train = [1:(k-1)*l_fold, (k*l_fold+1):length(y)];
        ind_test = ((k-1)*l_fold+1):min(k*l_fold,length(y));
        
        xtrain = x(ind_train);
        xtrain = combine_subjects(xtrain);
        ytrain = y(ind_train);
        ytrain = combine_subjects(ytrain);
        
        xtest = x(ind_test);
        ytest = y(ind_test);
        
        outreg = regressor(xtrain, ytrain, xtest, ytest);
        perf{k} = outreg.performance;
        target{k} = ytest;
        prediction1{k} = outreg.rf;
        prediction2{k} = outreg.medianfilter;
        prediction3{k} = outreg.hmm;
%         fprintf('fold %d:\n',k);
%         fprintf(' %.2f', perf{k});
%         fprintf('\n');
        
    end
    
    % combining outputs from different folds into single cell arrays
    perf = combine_subjects(perf);
    target_new = {};
    prediction1_new = {};
    prediction2_new = {};
    prediction3_new = {};
    for k=1:n_fold
        target_new = [target_new; target{k}];
        prediction1_new = [prediction1_new, prediction1{k}];
        prediction2_new = [prediction2_new, prediction2{k}];
        prediction3_new = [prediction3_new, prediction3{k}];
    end
    target = target_new;
    prediction1 = prediction1_new;
    prediction2 = prediction2_new;
    prediction3 = prediction3_new;
    
    out.performance = perf;
    out.prediction1 = prediction1;
    out.prediction2 = prediction2;
    out.prediction3 = prediction3;
    out.target = target;

end

end