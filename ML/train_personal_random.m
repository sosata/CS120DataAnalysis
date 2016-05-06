function perf = train_personal_random(x, y, n_bootstrap, p_train, regressor)

if isempty(x),
    
    perf = -Inf;
    
else
    
    if ~iscell(x)||~iscell(y),
        error('train_personal_random: each subject data must be in a cell.');
    end
    
    perf = zeros(length(x),1);
    for i = 1:length(x),
        
        fprintf('%d/%d\n',i,length(x));
        if length(unique(y{i}))~=2 || length(y{i})<10,
            fprintf('skipping subject %d...\n',i);
            perf(i) = nan;
        else
            
            out = zeros(n_bootstrap,1);
            parfor k=1:n_bootstrap,
                
                state_train = [];
                state_test = [];
                while (length(unique(state_train))~=2)||(length(unique(state_test))~=2),
                    ind_train = randsample(1:length(y), round(length(y)*p_train), false);
                    ind_test = 1:length(y);
                    ind_test(ind_train) = [];
                    feature_train = x{i}(ind_train, :);
                    state_train = y{i}(ind_train);
                    feature_test = x{i}(ind_test, :);
                    state_test = y{i}(ind_test);
                end
                
                %% stratification
                %[feature_train, state_train] = stratify(feature_train, state_train);
                %[feature_test, state_test] = stratify(feature_test, state_test);
                
                out(k) = regressor(feature_train, state_train, feature_test, state_test);
                
            end
            perf(i) = mean(out);
            fprintf('acc: %.2f\n',perf(i));
        end
    end
    
end

end