clear;
close all;

naive_features = true;
naive_feature_set = [1:3, 19];
expert_feature_set = [24];

save_vars = true;
plot_results = false;

n_bootstrap = 1000;
save_results = false;

load('features_Infdays.mat');
load('phq9.mat');

%% finding common ground
cnt = 1;
for i=1:length(subject_phq9),
    ind = find(strcmp(subject_feature, subject_phq9{i}));
    if ~isempty(ind),
%         if length(time_feature{ind})<4,
%             continue;
%         end
        subject_phq9_new{cnt} = subject_phq9{i};
        phq9_new.w0(cnt,1) = phq9.w0(i);
        phq9_new.w3(cnt,1) = phq9.w3(i);
        phq9_new.w6(cnt,1) = phq9.w6(i);
        feature_new{cnt} = feature{ind};
        time_feature_new{cnt} = time_feature{ind};
        cnt = cnt+1;
    end
end

subject_phq9_feature = subject_phq9_new;
phq9_feature = phq9_new;
phq9_mean = (phq9_feature.w0+phq9_feature.w3+phq9_feature.w6)/3;
feature = feature_new;
time_feature = time_feature_new;

if save_vars,
    save('vars_features.mat', 'subject_phq9_feature', 'phq9_feature', 'feature', 'time_feature');
end

% Shuffling
% phq9.w0 = randsample(phq9.w0, length(phq9.w0));

days_min = min(cellfun(@(x) length(x), time_feature));

for j=1:days_min,
    
    for i=1:length(feature_labels),
        ft = [];
        for k = 1:length(phq9_feature.w0),
            ft = [ft; feature{k}(j,i)];
        end
        feature_all(:,i) = ft;
        
        % single feature correaltions
        [r_0w(i,j),p_0w(i,j)] = corr(feature_all(:,i), phq9_feature.w0);
        [r_3w(i,j),p_3w(i,j)] = corr(feature_all(:,i), phq9_feature.w3);
        [r_6w(i,j),p_6w(i,j)] = corr(feature_all(:,i), phq9_feature.w6);
        [r_mean(i,j),p_mean(i,j)] = corr(feature_all(:,i), phq9_mean);
        
    end
    
    if naive_features,
        feature_all = feature_all(:,naive_feature_set);
    else
        feature_all = feature_all(:,expert_feature_set);
    end
    
%     feature_all = zscore(feature_all);
%     feature_all = feature_all(:,[7,end-1]);
%     feature_all = [feature_all, feature_all(:,1).*feature_all(:,2), feature_all(:,2).*feature_all(:,3), feature_all(:,1).*feature_all(:,3)];
    
    cnt = 1;
        
        for k=1:n_bootstrap,
            ind_train = randsample(1:size(feature_all,1), round(size(feature_all,1)*1.5), true);
            ind_test = 1:size(feature_all,1);
            ind_test(unique(ind_train)) = [];
            if isempty(ind_test),
                disp('empty test set. skipping...');
                continue;
            end
            
            %% linear regression
%             mdl = fitlm(feature_all(ind_train,:), phq9_mean(ind_train));%, 'VarNames', [var_labels, 'PHQ-9'])
            [B, fitinfo] = lassoglm(feature_all(ind_train,:), phq9_mean(ind_train), 'normal', 'alpha', .5, 'Lambda', .05);
%             R2(cnt,k) = mdl.Rsquared.Ordinary;
%             R2_adjusted(cnt,k) = mdl.Rsquared.Adjusted;
%             MSE(cnt,k) = mdl.MSE;
            phq_pred = feature_all(ind_test,:)*B + fitinfo.Intercept;
            R2(k) = 1-sum((phq_pred-phq9_mean(ind_test)).^2)/sum((mean(phq9_mean(ind_train))-phq9_mean(ind_test)).^2);
            
            %% logistic regression
%             cl_train = (phq9_feature.(sprintf('w%d',i))(ind_train)>=10);
%             cl_test = (phq9_feature.(sprintf('w%d',i))(ind_test)>=10);
            cl_train = (phq9_mean(ind_train)>10);
            cl_test = (phq9_mean(ind_test)>10);
            [B, fitinfo] = lassoglm(zscore(feature_all(ind_train,:)), cl_train, 'binomial', 'alpha', .5, 'Lambda', .01);
            phq_pred = logsig(zscore(feature_all(ind_test,:))*B + fitinfo.Intercept);
%             model = TreeBagger(100, feature_all(ind_train,:), cl_train);
%             [output, phq_pred] = predict(model, feature_all(ind_test,:));
%             phq_pred = phq_pred(:,2);
            cnt = 1;
            for cl_th = 0:.05:1,
                cl_pred = (phq_pred>=cl_th);
                sensitivity(cnt,k) = sum(cl_pred(cl_test==1)==1)/sum(cl_test==1);
                specificity(cnt,k) = sum(cl_pred(cl_test==0)==0)/sum(cl_test==0);
                cnt = cnt+1;
            end
            auc(k) = abs(trapz(1-specificity(:,k), sensitivity(:,k)));
        end
        
    clear feature_all;
    
end

mean(R2,2)
nanmean(auc,2)

if plot_results,
    
    figure;
    plot(1-nanmean(nanmean(specificity,3),2),nanmean(nanmean(sensitivity,3),2), '.','markersize',10);
%     plot(1-specificity, sensitivity, '.', 'markersize', 10);
    ylabel('sensitivity');
    xlabel('1 - specificity');
    xlim([0 1]);
    ylim([0 1]);
%     title(sprintf('AUC: %.3f',auc(end)));
    
    % for i=[0 3 6],
    %
    %     eval(sprintf('r = r_%dw;',i));
    %     eval(sprintf('p = p_%dw;',i));
    %
    %     figure;
    %     imagesc(r, [-1 1]);
    %     set(gca, 'ydir', 'normal');
    %     set(gca, 'ytick', 1:length(feature_labels), 'yticklabel', feature_labels);
    %     colorbar;
    %     xlabel('window #');
    %     ylabel(sprintf('week %d', i));
    %     title('r');
    %
    %     [indx, indy] = find(p<.05);
    %     hold on;
    %     for j=1:length(indx),
    %         plot(indy(j), indx(j), '.k', 'markersize', 10);
    %     end
    %
    %
    % end
    
%     figure;
%     imagesc(r_mean, [-1 1]);
%     set(gca, 'ydir', 'normal');
%     set(gca, 'ytick', 1:length(feature_labels), 'yticklabel', feature_labels);
%     colorbar;
%     xlabel('window #');
%     title('r (mean)');
%     [indx, indy] = find(p_mean<.05);
%     hold on;
%     for j=1:length(indx),
%         plot(indy(j), indx(j), '.k', 'markersize', 10);
%     end
    
end

if save_results,
    if naive_features,
        save('results_phq9_layer1.mat', 'auc', 'R2', 'sensitivity', 'specificity');
    else
        save('results_phq9_layer2.mat', 'auc', 'R2', 'sensitivity', 'specificity');
    end
end