clear;
close all

load('results_personal')
acc1 = out.performance(:,1);

load('results_personal_timeonly')
acc2 = out.performance(:,1);

load('results_personal_notime')
acc3 = out.performance(:,1);

figure(1)
n = sqrt(length(acc1));
bar([1 2 3],[nanmean(acc3),nanmean(acc2),nanmean(acc1)],'barwidth',.5,'facecolor',[.5 .5 1])
hold on
errorbar([1 2 3],[nanmean(acc3),nanmean(acc2),nanmean(acc1)],[nanstd(acc3)/n,nanstd(acc2)/n,nanstd(acc1)/n],'.k',...
    'linewidth',3);
xlim([0 4])
ylim([.8 .95])
set(gca, 'xtick',[1 2 3],'xticklabel',{'Sensor','Time','Time+Sensors'});
set(gca, 'ygrid', 'on')
box off
ylabel('Classification Accuracy')

figure
histogram(acc1,[.5:.025:1])
xlabel('Classification Accuracy')
ylabel('Number of Subjects')
box off

h = figure
set(h,'position',[520   649   521   449])
plot(acc1, acc2, '.','markersize',10)
hold on
plot([.5 1],[.5 1])
xlabel('All-feature model accuracy')
ylabel('Time-only model accuracy')
text(.55,.57,'y = x','rotation',45,'fontweight','bold','fontsize',12,'color',[.7 .3 0])
box off
mdl = fitlm(acc1, acc2);
plot([min(acc1) max(acc1)], mdl.Coefficients.Estimate(2)*[min(acc1) max(acc1)]+mdl.Coefficients.Estimate(1),'--k');


load('results_personal_gentleboost100')
acc4 = out.performance(:,1);
load('results_personal_correctedtimes_timeonly')
acc5 = out.performance(:,1);
load('results_personal_correctedtimes_notime')
acc6 = out.performance(:,1);

load('bad_subjects')
acc7 = acc4;
acc7(ind_bad) = [];
acc8 = acc5;
acc8(ind_bad) = [];
acc9 = acc6;
acc9(ind_bad) = [];

figure
n = sqrt(length(acc1));
bar([.9 1.9 2.9],[nanmean(acc3),nanmean(acc2),nanmean(acc1)],'barwidth',.2,'facecolor',[.7 .7 .7],'edgecolor',[.7 .7 .7])
hold on
bar([1.1 2.1 3.1],[nanmean(acc6),nanmean(acc5),nanmean(acc4)],'barwidth',.2,'facecolor',[.4 .7 1])
bar([1.3 2.3 3.3],[nanmean(acc9),nanmean(acc8),nanmean(acc7)],'barwidth',.2,'facecolor',[.4 1 .7])
errorbar([.9 1.9 2.9],[nanmean(acc3),nanmean(acc2),nanmean(acc1)],[nanstd(acc3)/n,nanstd(acc2)/n,nanstd(acc1)/n],'.k',...
    'linewidth',3,'color',[.7 .7 .7]);

errorbar([1.1 2.1 3.1],[nanmean(acc6),nanmean(acc5),nanmean(acc4)],[nanstd(acc6)/n,nanstd(acc5)/n,nanstd(acc4)/n],'.k',...
    'linewidth',3);
errorbar([1.3 2.3 3.3],[nanmean(acc9),nanmean(acc8),nanmean(acc7)],[nanstd(acc6)/n,nanstd(acc5)/n,nanstd(acc4)/n],'.k',...
    'linewidth',3);
xlim([0 4])
ylim([.8 .95])
set(gca, 'xtick',[1 2 3],'xticklabel',{'Sensor','Time','Time+Sensors'});
set(gca, 'ygrid', 'on')
box off
ylabel('Classification Accuracy')
legend('Before Quality Improvement','After Quality Improvement','After Removing Participants with Missing Data','location','northwest')