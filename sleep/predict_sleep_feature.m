clear;
close all;

addpath('../functions');
addpath('../ML');

good_features = true;

plot_results = false;
save_results = false;

n_tree = 50;
n_bootstrap = 12;

if good_features,
    load('features_sleep_workdayinfo.mat');
else
    load('features_sleep.mat');
end

for i=1:length(state),
   state{i}(state{i}==1) = 0;
   state{i}(state{i}==2) = 1;
end

cnt = 1;
for i = 1:length(state),
    
    fprintf('%d/%d\n',i,length(state));
    if length(unique(state{i}))~=2 || length(state{i})<10,
        fprintf('skipping subject %d...\n',i);
        continue;
    end
    
    if ~good_features,
        feature{i}(:,6) = [];
    end
    
%     if i==44 || i==109,%%%%%%%%%%%%%%%%
%         continue;
%     end

    parfor k=1:n_bootstrap,
        
        state_train = [];
        state_test = [];
        while (length(unique(state_train))~=2)||(length(unique(state_test))~=2),%(isempty(state_test)),
            ind_train = randsample(1:length(state{i}), round(length(state{i})*3), true);
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
        
%         %% training
%         model = TreeBagger(n_tree, feature_train, state_train, 'method', 'classification');
%         
%         %% test
%         [state_pred, pr] = predict(model, feature_test);
%         %     state_pred = cellfun(@(x) str2num(x), state_pred);
%         state_pr = pr(:,2);
%         
%         cnt2 = 1;
%         for phq_th = 0:.05:1,
%             state_pred = (state_pr>=phq_th);
%             sensitivity(cnt2,cnt,k) = sum(state_pred(state_test==1)==1)/sum(state_test==1);
%             specificity(cnt2,cnt,k) = sum(state_pred(state_test==0)==0)/sum(state_test==0);
%             cnt2 = cnt2+1;
%         end
%         auc(cnt,k) = abs(trapz(1-specificity(:,cnt,k), sensitivity(:,cnt,k)));

        auc(cnt,k) = rf_binaryclassifier(feature_train, state_train, feature_test, state_test);
        
    end
    cnt = cnt+1;
end

nanmean(nanmean((auc)))

if save_results,
    if good_features,
        save('results_sleep_workdayinfo.mat', 'auc', 'sensitivity', 'specificity');
    else
        save('results_sleep.mat', 'auc', 'sensitivity', 'specificity');
    end
end
