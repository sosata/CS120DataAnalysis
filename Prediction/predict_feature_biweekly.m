clear;
close all;

addpath('../functions');

n_bootstrap = 12*10;

% delete(gcp('nocreate'));
% pool = parpool(24);

% load('../General/features_biweekly.mat');
% load('../General/features_biweekly_weekend.mat');
% load('../General/features_biweekly_weekday.mat');
% load('../General/features_biweekly_offday.mat');
load('../General/features_biweekly_workday.mat');
load('../Assessment/phq9.mat');
load('../Assessment/gad7.mat');
load('../Assessment/spin.mat');
load('../Assessment/tipi.mat');
load('../Assessment/psqi.mat');
load('../Demographics/demo.mat');

% PHQ-9 change
% from baseline to week 3
cnt = 1;
for i = 1:length(phq.w3),
    ind = find(strcmp(subject_phq.w0, subject_phq.w3{i}));
    if ~isempty(ind),
        subject_phq03{cnt} = subject_phq.w3{i};
        phq03(cnt) = phq.w3(i) - phq.w0(ind);
        cnt = cnt+1;
    end
end
        
% from week 3 to 6
cnt = 1;
for i = 1:length(phq.w6),
    ind = find(strcmp(subject_phq.w3, subject_phq.w6{i}));
    if ~isempty(ind),
        subject_phq36{cnt} = subject_phq.w6{i};
        phq36(cnt) = phq.w6(i) - phq.w3(ind);
        cnt = cnt+1;
    end
end

% target assessment
assessment = psqi.w3;
subject_assessment = subject_psqi.w3;

% remove if NaN (for big5 only) %%%%%%%%%%
indnan = isnan(assessment);
assessment(indnan) = [];
subject_assessment(indnan) = [];

% which 2-week blocks to consider for the analysis
win_to_analyze = [1 2 3 4 5];

R2 = zeros(length(win_to_analyze), n_bootstrap);

for win = win_to_analyze,
    
    cnt = 1;
    target = [];
    feature_new = [];
    
    for i=1:length(subject_assessment),

        % find subject in feature data
        ind_ft = find(strcmp(subject_feature, subject_assessment{i}));
        
        % skip if subject doesn't have data up to current 2-week block
        if size(feature{ind_ft},1)<win,
            continue;
        end
        
        % find subject in Big5 data
        ind_tipi = find(strcmp(subject_tipi, subject_assessment{i}));

        % find subject in demo data
        ind_demo = find(strcmp(subject_demo, subject_assessment{i}));
        
        if ~isempty(ind_ft),
            target(cnt,1) = assessment(i);
            feature_new{cnt} = [feature{ind_ft}(win,:), ...
                age(ind_demo), female(ind_demo) ...   % adding age and gender
                tipi(ind_tipi, :)]; % adding big5
            cnt = cnt+1;
        else
            disp('subject from assessment was not found in feature data.');
        end
        
    end
    
    feature_all = combine_subjects(feature_new);
    
    % zscore
    % feature_all = myzscore(feature_all);
    
    parfor k=1:n_bootstrap,
        
%         fprintf('%d ',k);
        
        ind_train = randsample(1:size(feature_all,1), round(size(feature_all,1)*.7), false);
        ind_test = 1:size(feature_all,1);
        ind_test(unique(ind_train)) = [];
        if isempty(ind_test),
            disp('empty test set. skipping...');
            continue;
        end
        
        % random forest
        mdl = TreeBagger(800, feature_all(ind_train,:), target(ind_train), 'Method', 'regression');
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
        
        R2(win,k) = 1-mean((out-target(ind_test)).^2)/mean((mean(target(ind_train))-target(ind_test)).^2);
        
        out_all{k} = out;
        target_all{k} = target(ind_test);
        
    end
    
    fprintf('\nwin#%d n=%d R2: %.3f (%.3f)\n', win, length(target), mean(R2(win,:)), std(R2(win,:))/sqrt(n_bootstrap));
    
%     target_all = combine_subjects(target_all);
%     out_all = combine_subjects(out_all);
    
end

% save('prediction.mat', 'R2', 'out_all', 'target_all');
save('results/prediction.mat', 'R2');
