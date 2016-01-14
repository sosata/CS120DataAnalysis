clear;
close all;

plot_results = false;
correlation_type = 'pearson';

% load('features_stress.mat');
load('features_mood.mat');
% load('features_energy.mat');
% load('features_focus.mat');

cnt = 1;
cutoff_range = 2:20;

for cutoff = cutoff_range,
    
    
    %% global correlation
    feature_all = [];
    state_all = [];
    for i = 1:length(feature),
        feature_all = [feature_all; feature{i}(1:min(cutoff,end),:)];
        state_all = [state_all; state{i}(1:min(cutoff,end))];
    end
    feature_all = feature_all(:,[1,2,3,5,8,11,12]);
    for i=1:size(feature_all,2),
        [r(cnt,i), p(cnt,i)] = corr(feature_all(:,i), state_all, 'type', correlation_type);
%         fprintf('%s: r=%.3f p=%.3f\n',feature_labels{i},r,p);
    end
    
    cnt = cnt+1;
    
end

h = figure;
set(h, 'position', [680   678   816   420]);
hold on;
colors = jet(size(r,2));
for i=1:size(r,2),
    plot(cutoff_range, abs(r(:,i)), 'color', colors(i,:));
end
legend(feature_labels([1,2,3,5,8,11,12]),'location','northeastoutside');
for i=1:size(r,2),
    plot(cutoff_range(p(:,i)<.05), abs(r(p(:,i)<.05,i)), '.', 'markersize', 10, 'color', colors(i,:));
end
xlabel('until day #');
ylabel('r');

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
            %             if isnan(r(cnt,j)),
            %                 return;
            %             end
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