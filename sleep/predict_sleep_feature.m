clear;
close all;

addpath('../functions');
addpath('../ML');

plot_results = false;

n_bootstrap = 12;
p_train = .85;
k_train = 3;

add_other_vars = false;
add_history = true;

load('features_sleepdetection.mat');
load('../Demographics/demo_baseline');
load('../Demographics/demo_basic');

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

% removing work day info
% for i=1:length(feature),
%     feature{i}(:,end) = [];
% end

if add_history,
    for i=1:length(feature)
        
        feature{i} = [feature{i}(37:end,:), feature{i}(36:end-1,:), feature{i}(31:end-6,:), feature{i}(1:end-36,:)];
        state{i} = state{i}(37:end);
        
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

fprintf('accuracy: %.3f\nprecision: %.3f\nrecall: %.3f\n', nanmean(out(:,1)),nanmean(out(:,2)),nanmean(out(:,3)));

save('results.mat', 'out', 'demoage','demofemale','demoemployed','demoalone','demosleepalone','demonumjobs','demophonelocation');