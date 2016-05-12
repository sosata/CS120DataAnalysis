function out = train_personal_temporal(x, y, k_train, regressor)

if isempty(x),
    out.performance = NaN;
    out.target = [];
    out.prediction1 = [];
    out.prediction2 = [];
else
    
    if ~iscell(x)||~iscell(y),
        error('train_personal_temporal: each subject data must be in a cell.');
    end
    
    perf = [];
    target = cell(length(x),1);
    prediction1 = cell(length(x),1);
    prediction2 = cell(length(x),1);
    parfor i = 1:length(x),
        
        if size(x{i},1)~=length(y{i})
            error('something is wrong');
        end
        
        if length(unique(y{i}))~=2 || length(y{i})<2*k_train,
            fprintf('skipping subject %d...\n',i);
            perf(i,:) = nan;
        else
            fprintf('%d: ', i);
            perf2 = [];
            for k=1:k_train,
                foldsize = floor(length(y{i})/k_train);
                feature_train = x{i}([1:((k-1)*foldsize),(k*foldsize+1):end],:);
                feature_test = x{i}(((k-1)*foldsize+1):k*foldsize,:);
                state_train = y{i}([1:((k-1)*foldsize),(k*foldsize+1):end]);
                state_test = y{i}(((k-1)*foldsize+1):k*foldsize);
                if (length(unique(state_train))~=2),
                    fprintf('training set did not include all classes. skipping subject %d / fold %d\n',i,k);
                    perf2(k,:) = [nan nan nan];
                else
                    outreg = regressor(feature_train, state_train, feature_test, state_test);
                    perf2(k,:) = outreg.performance;
                    target{i} = [target{i}; state_test];
                    prediction1{i} = [prediction1{i}; outreg.staterf];
                    prediction2{i} = [prediction2{i}; outreg.statefilter];

                end
            end
            perf(i,:) = nanmean(perf2,1);
            fprintf(' %.2f',perf(i,:));
            fprintf('\n');
        end
    end
    
    out.performance = perf;
    out.prediction1 = prediction1;
    out.prediction2 = prediction2;
    out.target = target;
    
end

end