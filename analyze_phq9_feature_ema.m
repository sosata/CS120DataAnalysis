clear;
close all;

sleep_only = true;

n_bootstrap = 1000;
save_results = true;

load('vars_features.mat');
load('vars_ema.mat');

if sleep_only,
    vars_to_keep = [13 14 17 18];
else
    vars_to_keep = [1:8,17];
end

%% finding common ground

cnt = 1;
for i = 1:length(subject_phq9_ema),
    ind = find(strcmp(subject_phq9_feature, subject_phq9_ema{i}));
    if ~isempty(ind),
        feature_new{cnt} = feature{ind};
        for j = 1:length(vars),
            vars_new{j}{cnt} = vars{j}{i};
        end
        phq9_feature_new.w0(cnt) = phq9_feature.w0(ind);
        phq9_feature_new.w3(cnt) = phq9_feature.w3(ind);
        phq9_feature_new.w6(cnt) = phq9_feature.w6(ind);
        cnt = cnt+1;
    end
end
feature = feature_new;
vars = vars_new;
phq9 = phq9_feature_new;
phq9_mean = (phq9.w0+phq9.w3+phq9.w6)/3;

%% shuffling
% phq9.w0 = randsample(phq9.w0, length(phq9.w0));
% phq9.w3 = randsample(phq9.w3, length(phq9.w3));
% phq9.w6 = randsample(phq9.w6, length(phq9.w6));
% phq9_mean = randsample(phq9_mean, length(phq9_mean));

%% aggregating all variables
var_all = [];
for i=1:length(feature),
    vars_all_temp = feature{i}(:,[1:4,7:24]);%[7,24]);
    for j=vars_to_keep,
        vars_all_temp = [vars_all_temp, vars{j}{i}];
    end
    var_all = [var_all; vars_all_temp];
end
% labels_all = [feature_labels, var_labels];


for k=1:n_bootstrap,
    
    ind_train = randsample(1:size(var_all,1), round(size(var_all,1)*1.5), true);
    ind_test = 1:size(var_all,1);
    ind_test(unique(ind_train)) = [];
    
    % multiple linear regressions
    %         mdl = fitlm(var_all(ind_train,:), phq9_mean(ind_train));%, 'VarNames', [var_labels, 'PHQ-9'])
    %         R2(cnt,k) = mdl.Rsquared.Ordinary;
    %         R2_adjusted(cnt,k) = mdl.Rsquared.Adjusted;
    %         MSE(cnt,k) = mdl.MSE;
%     [B, fitinfo] = lassoglm(var_all(ind_train,:), phq9_mean(ind_train), 'normal', 'alpha', .5, 'Lambda', .1);
%     phq_pred = var_all(ind_test,:)*B + fitinfo.Intercept;
%     R2(k) = 1-sum((phq_pred'-phq9_mean(ind_test)).^2)/sum((mean(phq9_mean(ind_train))-phq9_mean(ind_test)).^2);
    
    % multiple logistic regressions
    cl_train = (phq9_mean(ind_train)>10);
    cl_test = (phq9_mean(ind_test)>10);
    [B, fitinfo] = lassoglm(zscore(var_all(ind_train,:)), cl_train', 'binomial', 'alpha', .9, 'Lambda', .05);
    phq_pred = logsig(zscore(var_all(ind_test,:))*B + fitinfo.Intercept);
    %         model = TreeBagger(100, var_all(ind_train,:), cl_train);
    %         [output, phq_pred] = predict(model, var_all(ind_test,:));
    %         phq_pred = phq_pred(:,2);
    cnt = 1;
    for phq_th = 0:.05:1,
        cl_pred = (phq_pred>=phq_th);
        sensitivity(cnt,k) = sum(cl_pred(cl_test==1)==1)/sum(cl_test==1);
        specificity(cnt,k) = sum(cl_pred(cl_test==0)==0)/sum(cl_test==0);
        cnt = cnt+1;
    end
    auc(k) = abs(trapz(1-specificity(:,k), sensitivity(:,k)));
    
end

nanmean(auc,2)

if save_results,
    if sleep_only,
        save('results_phq9_layer3_sleep.mat', 'auc', 'sensitivity', 'specificity');
    else
        save('results_phq9_layer3.mat', 'auc', 'sensitivity', 'specificity');
    end
end