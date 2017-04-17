clear;
close all;

addpath('results');

% PSQI

h = figure;
set(h, 'position', [100   234   560   714]);
subplot 311;
load('prediction_psqi_w0.mat');
plot([1 1],[-.05 .2],'g','linewidth',4); hold on;
errorbar(mean(R2,2), std(R2,[],2)/sqrt(size(R2,2)),'b');
set(gca,'xtick',1:5);
xlabel('Window #');
ylabel('R^2');
ylim([-.02 .2]);
xlim([1 5]);
legend('Assessment','PSQI','location','eastoutside');
subplot 312;
load('prediction_psqi_w3.mat');
plot([3 3],[-.05 .2],'g','linewidth',4); hold on;
errorbar(mean(R2,2), std(R2,[],2)/sqrt(size(R2,2)),'b');
set(gca,'xtick',1:5);
xlabel('Window #');
ylabel('R^2');
ylim([-.02 .2]);
xlim([1 5]);
legend('Assessment','PSQI','location','eastoutside');
subplot 313;
load('prediction_psqi_w6.mat');
plot([5 5],[-.05 .2],'g','linewidth',4); hold on;
errorbar(mean(R2,2), std(R2,[],2)/sqrt(size(R2,2)),'b');
set(gca,'xtick',1:5);
xlabel('Window #');
ylabel('R^2');
ylim([-.02 .2]);
xlim([1 5]);
legend('Assessment','PSQI','location','eastoutside');

