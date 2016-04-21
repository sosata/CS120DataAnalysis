clear;
close all;

addpath('../functions');

n_bootstrap = 12*10;

load('../General/features_biweekly.mat');
load('../Assessment/phq9.mat');
load('../Assessment/tipi.mat');
load('../Demographics/demo.mat');

assessment = phq.w6;
subject_assessment = subject_phq.w6;

% extracting first 2-week features
cnt = 1;
for i=1:length(subject_assessment),
    ind_ft = find(strcmp(subject_feature, subject_assessment{i}));
    ind_tipi = find(strcmp(subject_tipi, subject_assessment{i}));
    ind_demo = find(strcmp(subject_demo, subject_assessment{i}));
    if ~isempty(ind_ft),
        target(cnt,1) = assessment(i);
        feature_new{cnt} = [feature{ind_ft}(1,:), tipi(ind_tipi, :), ... % adding big5
            age(ind_demo), female(ind_demo)];   % adding age and gender
        cnt = cnt+1;
    else
        disp('subject from assessment was not found in feature data.');
    end
end

feature_all = combine_subjects(feature_new);
clear feature feature_new;

% remove EMA
% feature_all = feature_all(:,[1:44,65:69]);

% zscore
% feature_all = myzscore(feature_all);

R2 = zeros(n_bootstrap,1);

parfor k=1:n_bootstrap,
    
    disp(k);
    
    ind_train = randsample(1:size(feature_all,1), round(size(feature_all,1)*.7), false);
    ind_test = 1:size(feature_all,1);
    ind_test(unique(ind_train)) = [];
    if isempty(ind_test),
        disp('empty test set. skipping...');
        continue;
    end
    
    % random forest
    mdl = TreeBagger(5000, feature_all(ind_train,:), target(ind_train), 'Method', 'regression');
    out = predict(mdl, feature_all(ind_test,:));
    
    % elastic net GLM
%     feature_train = feature_all(ind_train,:);
%     % replacing missing values with zero
%     feature_train(isnan(feature_train)) = 0;
%     [B, fitinfo] = lassoglm(feature_train, target(ind_train), 'normal', 'alpha', 0.9, 'CV', 2);
%     [~, ind] = min(fitinfo.SE);
%     B_best = B(:,ind);
%     Inter_best = fitinfo.Intercept(ind);
%     % to handle NaN values in features
%     feature_test = feature_all(ind_test,:);
%     feature_test(isnan(feature_test)) = 0;
%     out = feature_test*B_best + Inter_best;
    
    R2(k) = 1-mean((out-target(ind_test)).^2)/mean((mean(target(ind_train))-target(ind_test)).^2);
    
    out_all{k} = out;
    target_all{k} = target(ind_test);
    
end

fprintf('R2: %.3f (%.3f)\n', mean(R2), std(R2)/sqrt(length(R2)));

target_all = combine_subjects(target_all);
out_all = combine_subjects(out_all);

save('prediction.mat', 'R2', 'out_all', 'target_all');
