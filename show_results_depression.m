clear;
close all;

addpath('functions');

n_bins = 20;
h = figure;
set(h, 'position', [445   530   675   418]);
title('Detecting Depression (PHQ9>=10)');

load('results_phq9_layer1');
auc_1 = auc;
sensitivity_1 = sensitivity;
specificity_1 = specificity;

load('results_phq9_layer2');
auc_2 = auc;
sensitivity_2 = sensitivity;
specificity_2 = specificity;

% load('results_phq9_layer3_sleep');
% auc_3 = auc;
% sensitivity_3 = sensitivity;
% specificity_3 = specificity;

load('results_phq9_layer3');
auc_3 = auc;
sensitivity_3 = sensitivity;
specificity_3 = specificity;

n_bootstrap = size(R2,2);
layer_labels = {'Sensors','Features','Behavioral Targets'};

subplot(1,3,[1 2]);

spec_range = sort([1-logspace(-1,0,n_bins)+(10^-1),0]);

for i=1:length(spec_range)-1,
    [indx, indy] = find((specificity_1>=spec_range(i))&(specificity_1<spec_range(i+1)));
    sen(i) = nanmean(nanmean(sensitivity_1(indx, indy)));
    spec(i) = (spec_range(i)+spec_range(i+1))/2;
end
indnan = isnan(sen);
sen(indnan) = [];
spec(indnan) = [];
plot([1, 1-spec, 0], [1, sen, 0],'--','color',[.6 .6 .6]);
hold on;

for i=1:length(spec_range)-1,
    [indx, indy] = find((specificity_2>=spec_range(i))&(specificity_2<spec_range(i+1)));
    sen(i) = nanmean(nanmean(sensitivity_2(indx, indy)));
    spec(i) = (spec_range(i)+spec_range(i+1))/2;
end
indnan = isnan(sen);
sen(indnan) = [];
spec(indnan) = [];
plot([1, 1-spec, 0], [1, sen, 0], 'color',[.6 .6 .6]);

for i=1:length(spec_range)-1,
    [indx, indy] = find((specificity_3>=spec_range(i))&(specificity_3<spec_range(i+1)));
    sen(i) = nanmean(nanmean(sensitivity_3(indx, indy)));
    spec(i) = (spec_range(i)+spec_range(i+1))/2;
end
indnan = isnan(sen);
sen(indnan) = [];
spec(indnan) = [];
plot([1, 1-spec, 0], [1, sen, 0], '--k');

% for i=1:length(spec_range)-1,
%     [indx, indy] = find((specificity_4>=spec_range(i))&(specificity_4<spec_range(i+1)));
%     sen(i) = nanmean(nanmean(sensitivity_4(indx, indy)));
%     spec(i) = (spec_range(i)+spec_range(i+1))/2;
% end
% indnan = isnan(sen);
% sen(indnan) = [];
% spec(indnan) = [];
% plot([1, 1-spec, 0], [1, sen, 0], 'k');

xlim([0 1]);
ylim([0 1]);
xlabel('1-specificity');
ylabel('sensitivity');
legend(layer_labels, 'location','southeast');

subplot(1,3,3);
hold on;
dbar(1:3, [nanmean(nanmean(auc_1)),nanmean(nanmean(auc_2)),nanmean(nanmean(auc_3))]*100,'facecolor',[0 1 1]);
errorbar(1:3, [nanmean(nanmean(auc_1)),nanmean(nanmean(auc_2)),nanmean(nanmean(auc_3))]*100, [nanstd(nanstd(auc_1)),nanstd(nanstd(auc_2)),nanstd(nanstd(auc_3))]*100,'.','linewidth',2,'color','k');
my_xticklabels([1 2.2 3.4], layer_labels, 'rotation', 45, 'horizontalalignment', 'right');
ylabel('AUC (%)');
xlim([0 4]);
ylim([50 90]);