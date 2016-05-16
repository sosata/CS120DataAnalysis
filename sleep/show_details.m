clear;
close all;

load('results.mat');
load('features_sleepdetection.mat');

subject = 10;

feature_label = {'still','lgt pwr','lgt rng','aud pwr','screen','loc var','charging','wifi name','time','workday'};

h = figure;
set(h,'position',[3          69        1668         866]);

ax(1) = subplot(2,1,1);
hold on;
set(gca,'position',[0.07 0.5 .92 .45]);
plot(out.target{subject},'color',[.5 .8 .5],'linewidth',2);
plot(1-out.prediction1{subject},'r','color',[1 .7 .7]);
plot(1-out.prediction1{subject},'.r','markersize',10);
plot(1-out.prediction2{subject},'color',[.7 .7 1]);
plot(1-out.prediction2{subject},'.b','markersize',10);
box off;
axis tight;
set(gca,'ytick',[0 .5 1],'yticklabel',{'awake',[],'asleep'},'fontsize',16);
ylim([-.1 1.1]);
set(gca, 'YGrid', 'on', 'XGrid', 'off');
title(sprintf('subject %d (%s), accuracy: %.3f',subject,subject_sleep{subject},out.performance(subject,1)),'fontsize',16);
h = legend('ground truth','RF','RF + median filter');
set(h, 'fontsize',16);

% ax(2) = subplot(2,1,2);
% hold on;
% set(gca,'position',[0.07 0.05 .92 .4]);
% for i=1:size(feature{subject},2),
%     plot(i+0*feature{subject}(:,i),'.k','markersize',10);
% end
% box off;
% axis tight;
% ylim([0 size(feature{subject},2)+1]);
% set(gca,'ytick',1:size(feature{subject},2), feature_label);
% set(gca,'fontsize',16);

ax(2) = subplot(2,1,2);
hold on;
set(gca,'position',[0.07 0.05 .92 .4]);
for i=1:size(feature{subject},2),
    plot((i-1)*5+myzscore(feature{subject}(:,i)));%,'.','markersize',10);
end
box off;
axis tight;
set(gca,'ytick',(0:size(feature{subject},2)-1)*5, 'yticklabel',feature_label);
set(gca,'fontsize',16);

linkaxes(ax,'x');

h = figure;
set(h, 'position',[560   196   840   752]);
for i=1:size(feature{subject},2),
    subplot(floor(sqrt(size(feature{subject},2))),ceil(sqrt(size(feature{subject},2))),i);
    hold on;
    if sum(i==[1 7]), % still,charging
        scatter(-.1+.2*rand(sum(out.target{subject}==0),1), -.1+.2*rand(sum(out.target{subject}==0),1)+feature{subject}(out.target{subject}==0,i),'filled');
        scatter(-.1+.2*rand(sum(out.target{subject}==1),1)+1, -.1+.2*rand(sum(out.target{subject}==1),1)+feature{subject}(out.target{subject}==1,i),'filled');
    else
        scatter(-.1+.2*rand(sum(out.target{subject}==0),1), feature{subject}(out.target{subject}==0,i),'filled');
        scatter(.9+.2*rand(sum(out.target{subject}==1),1), feature{subject}(out.target{subject}==1,i),'filled');
    end
    hold off;
    alpha(.1);
    title(sprintf('%s',feature_label{i}));
    set(gca,'xtick',[0 1],'xticklabel',{'awake','asleep'});
end