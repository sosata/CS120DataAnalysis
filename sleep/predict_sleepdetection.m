clear;
close all;

addpath('../functions');
addpath('../ML');

n_bootstrap = 12;
p_train = .85;
k_train = 3;

add_other_vars = true;
add_history = true;

load('features_sleepdetection.mat');
load('../Demographics/demo_baseline');
load('../Demographics/demo_basic');

% including only time
for i=1:length(feature),
    feature{i} = feature{i}(:,end);
end

% removing time
% for i=1:length(feature),
%     feature{i}(:,end) = [];
% end

cnt = 1;
if add_other_vars,
    for s=1:length(subject_sleep)
        % find basic demo info
        ind_basic = find(strcmp(subject_basic,subject_sleep{s}));
        ind_baseline = find(strcmp(subject_baseline,subject_sleep{s}));
        
        if isempty(ind_basic)||isempty(ind_basic),
            fprintf('skipping subject %s as it did not exist in either screener or baseline data.\n',subject_sleep{s});
        else
            demoage(cnt) = age(ind_basic);
            demofemale(cnt) = female(ind_basic);
            demoalone(cnt) = alone(ind_baseline);
            demosleepalone(cnt) = sleepalone(ind_baseline);
            demoemployed(cnt) = employed(ind_baseline);
            demonumjobs(cnt) = numjobs(ind_baseline);
            demophonelocation(cnt) = phonelocation(ind_baseline);
            feature_new{cnt} = feature{s};
            state_new{cnt} = state{s};
            cnt = cnt+1;
        end
        
    end
    feature = feature_new;
    state = state_new;
    clear feature_new state_new;
    
end

if add_history,
    for i=1:length(feature)
        
        feature{i} = [feature{i}(5:end,:),feature{i}(4:end-1,:),feature{i}(3:end-2,:),feature{i}(2:end-3,:),feature{i}(1:end-4,:)];
        state{i} = state{i}(5:end);
        
    end
end

%% personal model
% out = train_personal_random(feature, state, n_bootstrap, p_train, @rf_binaryclassifier);
% out = train_personal_temporal(feature, state, k_train, @rf_binaryclassifier);
out = train_personal_temporal(feature, state, k_train, @rfhmm_binaryclassifier);

%% global model
% adding demo features to the features vector
% for i=1:length(feature)
%     feature{i} = [feature{i}, ones(size(feature{i},1),1)*[demoage(i) demofemale(i) demoalone(i) demosleepalone(i)...
%         demoemployed(i) demonumjobs(i) demophonelocation(i)]];
% end
% out = train_loso(feature, state, @rf_binaryclassifier);
% out = train_loso(feature, state, @rfhmm_binaryclassifier);

perf = out.performance;

fprintf('accuracy: %.3f (%.3f)\nprecision: %.3f (%.3f)\nrecall: %.3f (%.3f)\n', ...
    nanmean(perf(:,1)),nanstd(perf(:,1))/sqrt(size(perf,1)),nanmean(perf(:,2)),nanstd(perf(:,2))/sqrt(size(perf,1)),...
    nanmean(perf(:,3)),nanstd(perf(:,3))/sqrt(size(perf,1)));

save('results.mat', 'out', 'demoage','demofemale','demoemployed','demoalone','demosleepalone','demonumjobs','demophonelocation');