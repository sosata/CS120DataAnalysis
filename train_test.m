clear;
close all;

run_mode = 'personal'; % 'global','personal'
plot_results = false;

n_bootstrap = 10;
split = .9;
n_tree = 400;

alpha = .0001;%1/3;
lambda_linear = 1;          % where fixed lambda is used
lambda_logistic = 0.01;     % where fixed lambda is used

% load('features_stress.mat');
% load('features_mood.mat');
% load('features_energy.mat');
% load('features_focus.mat');

load('features_ema.mat');

% load('features_sleep.mat');

if strcmp(run_mode, 'global'),
    
%     ind = find(cellfun(@(x) length(x), state)<5);
%     feature(ind) = [];
%     state(ind) = [];
    
    iter = n_bootstrap;
%     state normalization
%     for i = 1:length(state),
%         state{i} = state{i}-mean(state{i});
%     end
    
elseif strcmp(run_mode, 'personal'),
    
%     ind = find(cellfun(@(x) length(x), state)<5);
%     ind = [ind, find(cellfun(@(x) length(unique(x)), state)<2)];
%     feature(ind) = [];
%     state(ind) = [];
    
    iter = length(feature);
else
    error('run mode unknown.');
end

accuracy_rf = zeros(iter,1);
accuracy_hmm = zeros(iter,1);

for cnt = 1:iter,
    
    %% building train and test sets
    if strcmp(run_mode, 'global'),
        ind_train = randsample(1:length(feature), round(length(feature)*split));
        ind_test = find(~ismember(1:length(feature), ind_train));
        
        feature_train = [];
        state_train = [];
        for i = ind_train,
            feature_train = [feature_train; feature{i}];
            state_train = [state_train; mood{i}+calm{i}+focus{i}+energy{i}];
        end
        feature_test = [];
        state_test = [];
        for i = ind_test,
            feature_test = [feature_test; feature{i}];
            state_test = [state_test; mood{i}+calm{i}+focus{i}+energy{i}];
        end
    else
        ind_split = round(size(feature{cnt},1)*split);
        if ind_split==size(feature{cnt},1),
            ind_split=size(feature{cnt},1)-1;
        end
        feature_train = feature{cnt}(1:ind_split, :);
        state_train = mood{cnt}(1:ind_split)+calm{cnt}(1:ind_split)+focus{cnt}(1:ind_split)+energy{cnt}(1:ind_split);
        feature_test = feature{cnt}(ind_split+1:end, :);
        state_test = mood{cnt}(ind_split+1:end)+calm{cnt}(ind_split+1:end)+focus{cnt}(ind_split+1:end)+energy{cnt}(ind_split+1:end);
    end
    
    % feature_train = double(feature_train);
    % feature_test = double(feature_test);
%     feature_train(:,10) = []; %%%%%%%%%%
%     feature_test(:,10) = []; %%%%%%%%
%     feature_train = feature_train(:,7);    %%%%%%%%%%
%     feature_test = feature_test(:,7); %%%%%%%%
    
    %% feature normalization
%     feature_train = zscore(feature_train);
%     feature_test = zscore(feature_test);
    n_sample_train = size(feature_train,1);
    n_sample_test = size(feature_test,1);
    feature_train = (feature_train - ones(n_sample_train,1)*mean(feature_train))./...
        (ones(n_sample_train,1)*std(feature_train));
    feature_test = (feature_test - ones(n_sample_test,1)*mean(feature_train))./...
        (ones(n_sample_test,1)*std(feature_train));
    state_train = (state_train - mean(state_train))/std(state_train);
    state_test = (state_test - mean(state_train))/std(state_train);
    
    
    %% stratification
    % TODO
    
    %% training
    model = TreeBagger(n_tree, feature_train, state_train, 'method', 'regression');
    % net = patternnet([10 8 6], 'trainfcn', 'trainscg', 'performfcn', 'crossentropy');
    % net = train(net, feature_train', output_train');
%     model = fitlm(zscore(feature_train), zscore(state_train), 'linear');
%     [B, fitinfo] = lasso(feature_train, state_train, 'alpha', alpha, 'Lambda', lambda_linear);%, 'CV', size(features_train,1));
%     B_best = B;
%     intercept_best = fitinfo.Intercept;

    %% test
    [state_pred, ~] = predict(model, feature_test);
%     state_pred = round(state_pred);
    % state_pred = str2num(cell2mat(state_pred));
    % output  = vec2ind(net(feature_test'))';
%     state_pred = predict(model, zscore(feature_test));
%     state_pred = feature_test*B_best + intercept_best;

    
    %% HMM
%     TR = [.99 .01; .01 .99];
%     EM = [.8 .2; .2 .8];
%     state_hmm{cnt} = hmmviterbi(state_rf{cnt}, TR, EM)';
    
    %% accuracy/error
%     accuracy_rf(cnt) = mean(state_rf==state_test);
%     accuracy_hmm(cnt) = mean(state_hmm{cnt}==state_test{cnt});
%     error(cnt) = sqrt(mean((state_test-state_rf).^2))/(8-0);
%     error_0R(cnt) = sqrt(mean((mean(state_train)-state_test).^2))/(8-0);

    error(cnt) = 1 - sum((state_pred-state_test).^2)/sum((mean(state_train)-state_test).^2);
    
end

fprintf('Model R^2: %.3f (%.3f)\n', mean(error), std(error));
% fprintf('ZeroR NRMSD: %.3f (%.3f)\n', mean(error_0R), std(error_0R));

% plot(error_0R, 'r');
% hold on;
% plot(error, 'b');
% legend('ZeroR', 'RF');

% fprintf('RF Accuracy: %.1f%% (+-%.1f%%)\n', mean(accuracy_rf)*100, std(accuracy_rf)/sqrt(iter)*1.96*100);
% fprintf('HMM Accuracy: %.1f%% (+-%.1f%%)\n', mean(accuracy_hmm)*100, std(accuracy_hmm)/sqrt(iter)*1.96*100);

%% plotting results
if plot_results,
    figure;
    hold on;
    ind1 = find(diff(state_test{end})==1);
    ind2 = find(diff(state_test{end})==-1);
    if ind2(1)<ind1(1),
        ind2(1) = [];
    end
    for i=1:length(ind1)-1,
        rectangle('position', [ind1(i) 2 ind2(i)-ind1(i) 1], 'facecolor', 'g', 'edgecolor', 'g');
    end
    ind1 = find(diff(state_pred{end})==1);
    ind2 = find(diff(state_pred{end})==-1);
    if ind2(1)<ind1(1),
        ind2(1) = [];
    end
    for i=1:length(ind1)-1,
        rectangle('position', [ind1(i) 1 ind2(i)-ind1(i) 1], 'facecolor', 'b', 'edgecolor', 'b');
    end
    ind1 = find(diff(state_hmm{end})==1);
    ind2 = find(diff(state_hmm{end})==-1);
    if ind2(1)<ind1(1),
        ind2(1) = [];
    end
    for i=1:length(ind1)-1,
        rectangle('position', [ind1(i) 0 ind2(i)-ind1(i) 1], 'facecolor', 'k', 'edgecolor', 'k');
    end
    ylim([0 3]);
end
