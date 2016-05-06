clear;
close all;

addpath('../functions');
addpath('../ML');

load('../FeatureExtraction/features_biweekly_all.mat');
% load('../FeatureExtraction/features_biweekly_weekend.mat');
% load('../FeatureExtraction/features_biweekly_weekday.mat');
% load('../FeatureExtraction/features_biweekly_offday.mat');
% load('../FeatureExtraction/features_biweekly_workday.mat');

% load('../Assessment/phq9.mat');
% load('../Assessment/gad7.mat');
% load('../Assessment/spin.mat');
% load('../Assessment/tipi.mat');
load('../Assessment/psqi.mat');
load('../Demographics/demo_basic.mat');
load('../Demographics/demo_baseline.mat');

% target assessment
assessment = psqi.w3;
subject_assessment = subject_psqi.w3;

% which 2-week blocks to consider for the analysis
win_to_analyze = [1 2 3 4 5];

for win = win_to_analyze,
    
    cnt = 1;
    target = [];
    feature_to_analyze = [];
    
    for i=1:length(subject_assessment),

        % find subject in feature data
        ind_ft = find(strcmp(subject_feature, subject_assessment{i}));
        
        % skip if subject doesn't have data up to current 2-week block
        if size(feature{ind_ft},1)<win,
            continue;
        end
        
        % find subject in Big5 data
        %ind_tipi = find(strcmp(subject_tipi, subject_assessment{i}));

        % find subject in demo data
        ind_demo_basic = find(strcmp(subject_basic, subject_assessment{i}));
        ind_demo_baseline = find(strcmp(subject_baseline, subject_assessment{i}));
        
        if ~isempty(ind_ft),
            target{cnt} = assessment(i);
            feature_to_analyze{cnt} = [feature{ind_ft}(win,:), ...
                age(ind_demo_basic), female(ind_demo_basic), ...   % adding in age and gender
                alone(ind_demo_baseline), sleepalone(ind_demo_baseline), employed(ind_demo_baseline), numjobs(ind_demo_baseline)]; % adding in other demo info
%                 tipi(ind_tipi, :)]; % adding big5
            cnt = cnt+1;
        else
            disp('subject from assessment was not found in feature data.');
        end
        
    end
    
    %R2{win} = train_randsample(feature_to_analyze, target, 12*10, .7, @rf_regressor);
    R2{win} = train_loso(feature_to_analyze, target, @rf_regressor);
    
    fprintf('\nwin#%d n=%d R2: %.3f (%.3f)\n', win, length(target), mean(R2{win}), std(R2{win})/sqrt(length(R2{win})));
    
end

save('results/prediction.mat', 'R2');
