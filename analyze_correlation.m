clear;
close all;

plot_results = false;
correlation_type = 'spearman';
target_type = 'factor'; % 'normal','diff','factor'

%% loading data
% load('features_stress.mat');
% load('features_mood.mat');
% load('features_energy.mat');
% load('features_focus.mat');
load('features_ema.mat');

%% global correlation
feature_all = [];
state_all = [];
for i = 1:length(feature),
    
    if strcmp(target_type,'diff'),
        state{i} = diff(state{i});
        feature{i}(1,:) = [];
    end
    
    feature_all = [feature_all; feature{i}];
    
    if strcmp(target_type,'factor'),
        state_all = [state_all; [calm{i},mood{i},energy{i},focus{i}]*[0.5;0.5;0.5;0.5]];
    else
        state_all = [state_all; energy{i}];
    end
end

% To handle NaN values %%%%%%
feature_all(isnan(feature_all)) = 0;

for i=1:size(feature_all,2),
    [r, p] = corr(feature_all(:,i), state_all, 'type', correlation_type);
    fprintf('%d. %s: r=%.3f p=%.3f\n', i, feature_labels{i}, r, p);
end

%% multiple regression
model = fitlm(feature_all, state_all, 'linear')

return;

%% personal correlation
cnt=0;
for i=1:length(feature),
    if size(feature{i},1)>1,
        cnt=cnt+1;
        for j=1:size(feature{i},2),
            [r(cnt,j),p(cnt,j)] = corr(state{i},feature{i}(:,j), 'type', correlation_type);
            if isnan(r(cnt,j)),
               error('something is wrong.');
            end
        end
        
    end
end

if plot_results,
    %     h = figure;
    %     set(h, 'position',[193         377        1717         257]);
    %     hold on;
    %     colors = jet(size(p,2));
    %     for i=1:size(p,2),
    %         plot(p(:,i), 'color', colors(i,:),'linewidth',2);
    %     end
    %     legend(feature_labels);
    %     ylabel('p-value');
    %     ylim([0 .1]);
end