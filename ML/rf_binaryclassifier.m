function out = rf_binaryclassifier(xtrain, ytrain, xtest, ytest)

n_tree = 20;

if isempty(xtrain)||isempty(xtest),
    out = [];
else
    
    % removing nans from training data as RF cannot deal with it
    ind_nan = isnan(ytrain);
    xtrain(ind_nan,:) = [];
    ytrain(ind_nan) = [];
    
    if length(unique(ytrain))~=2,
        error('rf_binaryclassifier: ytrain must be binary.');
    end
    
    [xtrain, ytrain] = stratify(xtrain, ytrain);
    
    mdl = TreeBagger(n_tree, xtrain, ytrain, 'method', 'classification');
    %mdl = fitensemble(xtrain,ytrain,'AdaBoostM1',n_tree,'Tree', 'type', 'classification');
    
    % testing RF
    if ~iscell(xtest)
        % single test subject
        [state_pred, ~] = predict(mdl, xtest);
        
        out.rf = state_pred;
        out.medianfilter = nan;
        out.hmm = nan;
        
        [accuracy, precision, recall] = calculate_accuracy(ytest, state_pred);
        out.performance = [accuracy, precision, recall];
    else
        %  multiple test subjects
        for i=1:length(xtest)
            
            if isempty(xtest{i})
               out.performance(i,:) = [nan nan nan];
               out.rf{i} = nan;
               out.medianfilter{i} = nan;
               out.hmm{i} = nan;
            else
%                 xtest{i}
                [state_pred, ~] = predict(mdl, xtest{i});
                state_pred = str2double(state_pred);
                
                out.rf{i} = state_pred;
                out.medianfilter{i} = nan;
                out.hmm{i} = nan;
                
%                 ytest{i}
%                 state_pred
                [accuracy, precision, recall] = calculate_accuracy(ytest{i}, state_pred);
                out.performance(i,:) = [accuracy, precision, recall];
                
            end
        end
    end
    
end

end