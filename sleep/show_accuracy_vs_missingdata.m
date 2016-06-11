clear;
close all;

addpath('../Functions/');

save_bad_subjects = true;

load('results_personal.mat');
load('features_sleepdetection.mat');

features_to_analyze = [2 3 4 5 6 7 8 10 11 12 13 14 15];
features_to_analyze_labels = feature_label(features_to_analyze);

for i=1:length(feature),
    if ~isempty(feature{i})
        p_nan(i) = sum(sum(isnan(feature{i}(:,features_to_analyze))))/(size(feature{i},1)*length(features_to_analyze));
    else
        p_nan(i) = nan;
    end
end
acc = out.performance(:,1);

ind_bad = find(p_nan>.5);

figure;
plot(p_nan, acc,'.','markersize',12); hold on;
mdl = fitlm(p_nan, acc);
plot([min(p_nan) max(p_nan)], mdl.Coefficients.Estimate(2)*[min(p_nan) max(p_nan)]+mdl.Coefficients.Estimate(1),'--k');
xlabel('Proportion of Missing Sensor Data');
ylabel('Classification Accuracy');
text(.7,mdl.Coefficients.Estimate(2)*.7+mdl.Coefficients.Estimate(1)+.01,...
    sprintf('r = %.3f', mycorr(p_nan',acc,'pearson')),'fontweight','bold','fontsize',12);
box off;

fprintf('accuracy (missing <50%% - n=%d): %.3f (%.3f)\n',sum(p_nan<=.5),mean(acc(p_nan<=.5)),std(acc(p_nan<=.5))/sqrt(sum(p_nan<=.5)));
fprintf('accuracy (missing <10%% - n=%d): %.3f (%.3f)\n',sum(p_nan<=.1),mean(acc(p_nan<=.1)),std(acc(p_nan<=.1))/sqrt(sum(p_nan<=.1)));

for i=1:length(feature)
    cnt = 0;
    if ~isempty(feature{i}),
        for j=features_to_analyze,
            cnt = cnt+1;
            p_feature_nan(i,cnt) = sum(isnan(feature{i}(:,j)))/size(feature{i},1);
        end
    else
        p_feature_nan = nan*ones(1,length(features_to_analyze));
    end
end

figure;
for i=1:size(p_feature_nan,2),
    subplot(ceil(sqrt(size(p_feature_nan,2))),ceil(sqrt(size(p_feature_nan,2))),i);
    plot(p_feature_nan(:,i), acc,'.','markersize',12);
    xlabel('proportion of missing data');
    ylabel('accuracy');
    title(sprintf('%s (r=%.3f)',features_to_analyze_labels{i},mycorr(p_feature_nan(:,i),acc,'pearson')));
    box off;
end

% finding missing data in EMA
p_nan = [];
for i=1:length(state),
    if ~isempty(state{i})
        p_nan(i) = sum(isnan(state{i}))/length(state{i});
    else
        p_nan(i) = nan;
    end
end
figure;
plot(p_nan, acc,'.','markersize',12); hold on;
mdl = fitlm(p_nan, acc);
plot([min(p_nan) max(p_nan)], mdl.Coefficients.Estimate(2)*[min(p_nan) max(p_nan)]+mdl.Coefficients.Estimate(1),'--k');
xlabel('Proportion of Missing EMA Data');
ylabel('Classification Accuracy');
text(.5,mdl.Coefficients.Estimate(2)*.5+mdl.Coefficients.Estimate(1)+.01,...
    sprintf('r = %.3f', mycorr(p_nan',acc,'pearson')),'fontweight','bold','fontsize',12);
box off;

if save_bad_subjects
    save('bad_subjects','ind_bad');
end
