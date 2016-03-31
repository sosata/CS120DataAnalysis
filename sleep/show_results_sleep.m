clear;
close all;

n_bins = 20;
h = figure;
set(h, 'position', [374   491   746   457]);

addpath('functions');

load('results_sleep');
auc_1 = auc;
sensitivity_1 = sensitivity;
specificity_1 = specificity;

load('results_sleep_workdayinfo');
auc_2 = auc;
sensitivity_2 = sensitivity;
specificity_2 = specificity;

layer_labels = {'Sensor features',sprintf('Sensor features + Workday')};

subplot(1,3,[1 2]);
spec_range = sort([1, 1-logspace(-2,0,n_bins)]);

for i=1:length(spec_range)-1,
    sen(i) = 0;
    for j=1:size(specificity_1,3),
        [indx, indy] = find((specificity_1(:,:,j)>=spec_range(i))&(specificity_1(:,:,j)<spec_range(i+1)));
        sen(i) = sen(i) + nanmean(nanmean(sensitivity_1(indx, indy, j)));
    end
    sen(i) = sen(i)/size(specificity_1,3);
    spec(i) = (spec_range(i)+spec_range(i+1))/2;
end
indnan = isnan(sen);
sen(indnan) = [];
spec(indnan) = [];
plot([1, 1-spec, 0], [1, sen, 0], '--k');
hold on;

for i=1:length(spec_range)-1,
    sen(i) = 0;
    for j=1:size(specificity_2,3),
        [indx, indy] = find((specificity_2(:,:,j)>=spec_range(i))&(specificity_2(:,:,j)<spec_range(i+1)));
        sen(i) = sen(i) + nanmean(nanmean(sensitivity_2(indx, indy, j)));
    end
    sen(i) = sen(i)/size(specificity_2,3);
    spec(i) = (spec_range(i)+spec_range(i+1))/2;
end
indnan = isnan(sen);
sen(indnan) = [];
spec(indnan) = [];
plot([1, 1-spec, 0], [1, sen, 0], 'k');

xlim([0 1]);
ylim([0 1]);
legend(layer_labels, 'location', 'southeast');
xlabel('1-specificity');
ylabel('sensitivity');

subplot(1,3,3);
hold on;
bar(1:2, [nanmean(nanmean(auc_1)),nanmean(nanmean(auc_2))]*100,'facecolor',[0 1 1]);
errorbar(1:2, [nanmean(nanmean(auc_1)),nanmean(nanmean(auc_2))]*100, [nanstd(nanstd(auc_1)),nanstd(nanstd(auc_2))],'.','linewidth',2,'color','k');
my_xticklabels(1:2, layer_labels, 'rotation', 30, 'horizontalalignment', 'right');
ylabel('AUC (%)');
xlim([0 3]);
ylim([85 95]);