% if there are multiple test subjects, pass them as a cell array to xtest
% and ytest

function out = rfhmm_binaryclassifier(xtrain, ytrain, xtest, ytest)

n_tree = 400;

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
    
%     y_uniq = unique(ytrain);
%     ind0 = (ytrain==y_uniq(1));
%     ind1 = (ytrain==y_uniq(2));
%     ytrain(ind0) = 0;
%     ytrain(ind1) = 1;
    
    % This is not needed anymore
    %     ind0 = (ytest==y_uniq(1));
    %     ind1 = (ytest==y_uniq(2));
    %     ytest(ind0) = 0;
    %     ytest(ind1) = 1;
    
    % stratification of training data
    [xtrain, ytrain] = stratify(xtrain, ytrain);
    
    % TODO: stratify test data as well and see what happens
    
    % training RF
    mdl = TreeBagger(n_tree, xtrain, ytrain, 'method', 'classification');
    % mdl = fitensemble(xtrain,ytrain,'Subspace',n_tree,'Tree', 'type', 'classification');
    % mdl = fitensemble(xtrain,ytrain,'GentleBoost',n_tree,'Tree', 'type', 'classification');
    
    % testing RF
    if ~iscell(xtest)
        % single test subject
        [~, pr] = predict(mdl, xtest);
        out.rf = pr(:,1);
        
        % median filter
        pr(:,1) = medfilt1(pr(:,1),21);
        out.medianfilter = pr(:,1);
        
        state_pred = (pr(:,1)<pr(:,2));
        
        % HMM
        p_transit = 1/(6*24);
        state_pred = hmmviterbi(state_pred+1, [1-p_transit p_transit; p_transit 1-p_transit], [.99 .01;.01 .99])'-1;
        
        out.hmm = state_pred;
        
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
                [~, pr] = predict(mdl, xtest{i});
                out.rf{i} = pr(:,1);
                
                % median filter
                pr(:,1) = medfilt1(pr(:,1),21);
                out.medianfilter{i} = pr(:,1);
                
                state_pred = (pr(:,1)<pr(:,2));
                
                % HMM
                p_transit = 1/(6*24);
                state_pred = hmmviterbi(state_pred+1, [1-p_transit p_transit; p_transit 1-p_transit], [.99 .01;.01 .99])'-1;
                
                out.hmm{i} = state_pred;
                
                [accuracy, precision, recall] = calculate_accuracy(ytest{i}, state_pred);
                out.performance(i,:) = [accuracy, precision, recall];
            end
        end
    end
end

end