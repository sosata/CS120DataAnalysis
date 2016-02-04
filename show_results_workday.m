clear;
close all;

addpath('functions');

h = figure;
set(h, 'position', [334   510   723   438]);

n_bins = 8;

load('results_workday_naive');
auc_1 = auc;
sensitivity_1 = sensitivity;
specificity_1 = specificity;

% load('results_workday');
% auc_2 = auc;
% sensitivity_2 = sensitivity;
% specificity_2 = specificity;

load('results_workday_homeinfo');
auc_2 = auc;
sensitivity_2 = sensitivity;
specificity_2 = specificity;

layer_labels = {'Sensors','Features'};

subplot(1,3,[1 2]);
hold on;
% spec_range = sort([1, 1-logspace(-2,0,n_bins)]);
spec_range = sort([1-logspace(-1,0,n_bins)+(10^-1),0]);

for i=1:length(spec_range)-1,
    sen(i) = 0;
    cnt = 0;
    for j=1:size(specificity_1,3),
        [indx, indy] = find((specificity_1(:,:,j)>=spec_range(i))&(specificity_1(:,:,j)<spec_range(i+1)));
        if false,%isempty(indx),
            continue;
        else
            sen(i) = sen(i) + nanmean(nanmean(sensitivity_1(indx, indy, j)));
            cnt = cnt+1;
        end
    end
    if cnt>0,
        sen(i) = sen(i)/cnt;
    end
    spec(i) = (spec_range(i)+spec_range(i+1))/2;
end
indnan = isnan(sen);
sen(indnan) = [];
spec(indnan) = [];
plot([1, 1-spec, 0], [1, sen, 0], '--k');

for i=1:length(spec_range)-1,
    sen(i) = 0;
    cnt = 0;
    for j=1:size(specificity_2,3),
        [indx, indy] = find((specificity_2(:,:,j)>=spec_range(i))&(specificity_2(:,:,j)<spec_range(i+1)));
        if false,%isempty(indx),
            continue;
        else
            sen(i) = sen(i) + nanmean(nanmean(sensitivity_2(indx, indy, j)));
            cnt = cnt+1;
        end
    end
    if cnt>0,
        sen(i) = sen(i)/cnt;
    end
    spec(i) = (spec_range(i)+spec_range(i+1))/2;
end
indnan = isnan(sen);
sen(indnan) = [];
spec(indnan) = [];
plot([1, 1-spec, 0], [1, sen, 0], 'k');

% for i=1:length(spec_range)-1,
%     sen(i) = 0;
%     cnt = 0;
%     for j=1:size(specificity_3,3),
%         [indx, indy] = find((specificity_3(:,:,j)>=spec_range(i))&(specificity_3(:,:,j)<spec_range(i+1)));
%         if false,%isempty(indx),
%             continue;
%         else
%             sen(i) = sen(i) + nanmean(nanmean(sensitivity_3(indx, indy, j)));
%             cnt = cnt+1;
%         end
%     end
%     if cnt>0,
%         sen(i) = sen(i)/cnt;
%     end
%     spec(i) = (spec_range(i)+spec_range(i+1))/2;
% end
% indnan = isnan(sen);
% sen(indnan) = [];
% spec(indnan) = [];
% plot([1, 1-spec, 0], [1, sen, 0], 'k');

xlim([0 1]);
ylim([0 1]);
legend(layer_labels, 'location', 'southeast');
xlabel('1-specificity');
ylabel('sensitivity');

subplot 133;
hold on;
bar(1:2, [nanmean(nanmean(auc_1)),nanmean(nanmean(auc_2))]*100,'facecolor',[0 1 1]);
errorbar(1:2, [nanmean(nanmean(auc_1)),nanmean(nanmean(auc_2))]*100, [nanstd(nanstd(auc_1)),nanstd(nanstd(auc_2))]/sqrt(size(auc_1,1))*1.96*100,'.','linewidth',2,'color','k');
my_xticklabels(1:2, layer_labels, 'rotation', 30, 'horizontalalignment', 'right');
ylabel('AUC (%)');
xlim([0 3]);
ylim([60 95]);