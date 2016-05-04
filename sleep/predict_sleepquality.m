clear;
close all;

load('features_sleepquality');

n_tree = 100;

R2s = [];

parfor i = 1:length(state),
    
    fprintf('%d/%d\n',i,length(state));
    
    if length(state{i})<3,
        fprintf('skipping this subject due to lack of data\n');
        continue;
    end

    R2 = [];
    
    for k=1:length(state{i}),
        
        feature_train = feature{i}([1:k-1,k+1:end], :);
        state_train = state{i}([1:k-1,k+1:end]);
        feature_test = feature{i}(k, :);
        state_test = state{i}(k);
        
        %% stratification
        %[feature_train, state_train] = stratify(feature_train, state_train);
        %[feature_test, state_test] = stratify(feature_test, state_test);
        
        %% training
        model = TreeBagger(n_tree, feature_train, state_train, 'method', 'regression');
        
        %% test
        out = predict(model, feature_test);
        R2(k) = 1-mean((out-state_test).^2)/mean((mean(state_train)-state_test).^2);
        
    end
    R2s(i) = mean(R2);
end

nanmean(R2s)
