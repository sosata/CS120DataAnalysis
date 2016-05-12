function out = rfhmm_binaryclassifier(xtrain, ytrain, xtest, ytest)

n_tree = 500;

if isempty(xtrain)||isempty(xtest),
    out = [0 0 0];
else
    
    if length(unique(ytrain))~=2,
        error('rf_binaryclassifier: ytrain must be binary.');
    end
    
    y_uniq = unique(ytrain);
    ind0 = (ytrain==y_uniq(1));
    ind1 = (ytrain==y_uniq(2));
    ytrain(ind0) = 0;
    ytrain(ind1) = 1;
    
    ind0 = (ytest==y_uniq(1));
    ind1 = (ytest==y_uniq(2));
    ytest(ind0) = 0;
    ytest(ind1) = 1;
    
    % stratification of training data
    [xtrain, ytrain] = stratify(xtrain, ytrain);
    
    % TODO: stratify test data as well and see what happens
    
    % training RF
    mdl = TreeBagger(n_tree, xtrain, ytrain, 'method', 'classification');
    
    % testing RF
    [~, pr] = predict(mdl, xtest);
%     state_pred = cellfun(@str2num, state_pred);
    out.staterf = pr(:,1);

    % median filter
    pr(:,1) = medfilt1(pr(:,1),7);
    state_pred = (pr(:,1)<.5);
    out.statefilter = pr(:,1);

    % HMM
%     p_transit = 1/(6*24);
%     state_pred = hmmviterbi(state_pred+1, [1-p_transit p_transit; p_transit 1-p_transit], [.99 .01;.01 .99]) - 1;
    
    [accuracy, precision, recall] = calculate_accuracy(ytest, state_pred);
    out.performance = [accuracy, precision, recall];
end

end