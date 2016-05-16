clear;
close all;

addpath('../Functions/');

load('results_personal.mat');
load('features_sleepdetection.mat');

features_to_analyze = [2 3 4 6 7 8];
features_to_analyze_labels = {'lgt pwr','lgt rng','aud pwr','loc var','charging','wifi name'};

for i=1:length(feature),
    p_nan(i) = sum(sum(isnan(feature{i}(:,features_to_analyze))))/(size(feature{i},1)*length(features_to_analyze));
end
acc = out.performance(:,1);

figure;
plot(p_nan, acc,'.','markersize',12);
xlabel('proportion of missing data');
ylabel('accuracy');
title(sprintf('r = %.3f', mycorr(p_nan',acc,'pearson')));
box off;

fprintf('accuracy (missing <50%% - n=%d): %.3f (%.3f)\n',sum(p_nan<=.5),mean(acc(p_nan<=.5)),std(acc(p_nan<=.5))/sqrt(sum(p_nan<=.5)));
fprintf('accuracy (missing <10%% - n=%d): %.3f (%.3f)\n',sum(p_nan<=.1),mean(acc(p_nan<=.1)),std(acc(p_nan<=.1))/sqrt(sum(p_nan<=.1)));

return;

for i=1:length(feature)
    cnt = 0;
    for j=features_to_analyze,
        cnt = cnt+1;
        p_feature_nan(i,cnt) = sum(isnan(feature{i}(:,j)))/size(feature{i},1);
    end
end

figure;
for i=1:size(p_feature_nan,2),
    subplot(floor(sqrt(size(p_feature_nan,2))),ceil(sqrt(size(p_feature_nan,2))),i);
    plot(p_feature_nan(:,i), acc,'.','markersize',12);
    xlabel('proportion of missing data');
    ylabel('accuracy');
    title(sprintf('%s (r=%.3f)',features_to_analyze_labels{i},mycorr(p_feature_nan(:,i),acc,'pearson')));
    box off;
end

