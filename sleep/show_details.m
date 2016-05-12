clear;
close all;

load('results.mat');
load('features_sleepdetection.mat');

subject = 34;

h = figure;
set(h,'position',[3          69        1668         866]);

subplot 211;
hold on;
set(gca,'position',[0.07 0.5 .92 .45]);

plot(out.target{subject},'color',[.5 .8 .5],'linewidth',2);
plot(1-out.prediction1{subject},'.r','markersize',10);
plot(1-out.prediction2{subject},'.b','markersize',10);

box off;
axis tight;
set(gca,'ytick',[0 .5 1],'yticklabel',{'awake',[],'asleep'},'fontsize',16);
ylim([-.1 1.1]);
set(gca, 'YGrid', 'on', 'XGrid', 'off');

title(sprintf('subject %d (%s), accuracy: %.3f',subject,subject_sleep{subject},out.performance(subject,1)),'fontsize',16);
h = legend('ground truth','RF','RF + median filter');
set(h, 'fontsize',16);

subplot 212;
hold on;
set(gca,'position',[0.07 0.05 .92 .4]);
for i=1:size(feature{subject},2),
    plot(i+0*feature{subject}(:,i),'.k','markersize',10);
end
box off;
axis tight;
ylim([0 size(feature{subject},2)+1]);
set(gca,'ytick',1:9, 'yticklabel',{'still','lgt pwr','lgt rng','aud pwr','screen','loc var','charging','wifi name','workday'});
set(gca,'fontsize',16);