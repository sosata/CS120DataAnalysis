clear;
close all;

addpath('../functions');

good_features = false;
naive_features = true;

plot_results = false;
save_results = true;

n_tree = 20;
n_bootstrap = 20;

if good_features,
    load('features_workday_homeinfo.mat');
else
    load('features_workday.mat');
end

%% removing 'partial'
for i=1:length(state),
    ind = find(state{i}=='partial');
    state{i}(ind) = [];
    feature{i}(ind,:) = [];
end

%% converting categorical to numerical
for i = 1:length(state),
    state_new{i} = zeros(length(state{i}),1);
    state_new{i}(state{i}=='normal') = 1;
end
state = state_new;

cnt = 1;
for i = 1:length(state),
    
    fprintf('%d/%d\n',i,length(state));
    if length(unique(state{i}))~=2 || length(state{i})<10,
        fprintf('skipping subject %d...\n',i);
        continue;
    end
    
    if naive_features,
        feature{i} = feature{i}(:, [4 5 10 11 12 23]);
    end
    
    for k=1:n_bootstrap,
        
        state_train = [];
        state_test = [];
        while (length(unique(state_train))~=2)||(isempty(state_test)),
            ind_train = randsample(1:length(state{i}), length(state{i}), true);
            ind_test = 1:length(state{i});
            ind_test(unique(ind_train)) = [];
            feature_train = feature{i}(ind_train, :);
            state_train = state{i}(ind_train);
            feature_test = feature{i}(ind_test, :);
            state_test = state{i}(ind_test);
        end
        
        
        %% stratification
        %[feature_train, state_train] = stratify(feature_train, state_train);
        %[feature_test, state_test] = stratify(feature_test, state_test);
        
        %% training
        model = TreeBagger(n_tree, feature_train, state_train, 'method', 'classification');
        
        %% test
        [state_pred, pr] = predict(model, feature_test);
        %     state_pred = cellfun(@(x) str2num(x), state_pred);
        state_pr = pr(:,2);
        
        cnt2 = 1;
        for phq_th = 0:.05:1,
            state_pred = (state_pr>=phq_th);
            sensitivity(cnt2,cnt,k) = sum(state_pred(state_test==1)==1)/sum(state_test==1);
            specificity(cnt2,cnt,k) = sum(state_pred(state_test==0)==0)/sum(state_test==0);
            cnt2 = cnt2+1;
        end
        auc(cnt,k) = abs(trapz(1-specificity(:,cnt,k), sensitivity(:,cnt,k)));
        
    end
    
    cnt = cnt+1;
    
end

nanmean(nanmean((auc)))

if save_results,
    if good_features,
        save('results_workday_homeinfo.mat', 'auc', 'sensitivity', 'specificity');
    else
        if naive_features,
            save('results_workday_naive.mat', 'auc', 'sensitivity', 'specificity');
        else
            save('results_workday.mat', 'auc', 'sensitivity', 'specificity');
        end
    end
end
