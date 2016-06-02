clear;
close all;

addpath('../Functions/');
load('results_personal_notime.mat');
load('features_sleepdetection.mat');

%% Find Bad Subjects

figure(111)
subplot(3,1,1)
histogram(out.performance(:,1))
subplot(3,1,2)
histogram(out.performance(:,2))
subplot(3,1,3)
histogram(out.performance(:,3))

figure(112)
h = plot(demoage, out.performance(:,1), '.');
xlabel('Age')
ylabel('Accuracy (?)')
customDataCursor(h, ...
    cellfun(@num2str, num2cell(1:size(out.performance, 1)), ...
            'UniformOutput', false));

%% Look at individual subjects

subject = 101;

figure(113)
clf
for i = 1:size(feature{subject}, 2)
    f = feature{subject}(:,i);
    
    subplot(size(feature{subject}, 2),1,i)
    hold on
    plot(out.target{subject})
    plot(mat2gray(f))
    title(feature_label{i})
end


%% Individual feature plots

feature_label = {'still','lgt pwr','lgt rng','aud pwr','screen','loc var','charging','wifi name','time'};

figure(1)
subplot(2,1,1);
hold on;
plot(out.target{subject},'color',[.6 .9 .6],'linewidth',4);
plot(1-out.prediction1{subject},'r','color',[1 .7 .7]);
plot(1-out.prediction1{subject},'.r','markersize',8);
plot(1-out.prediction2{subject},'color',[.7 .7 1]);
plot(1-out.prediction2{subject},'.b','markersize',8);
plot(out.prediction3{subject},'color',[.7 .7 .7]);
plot(out.prediction3{subject},'.k','markersize',8);
box off;
axis tight;
set(gca,'ytick',[0 .5 1],'yticklabel',{'awake',[],'asleep'},'fontsize',16);
ylim([-.1 1.1]);
set(gca, 'YGrid', 'on', 'XGrid', 'off');
title(sprintf('subject %d (%s), accuracy: %.3f',subject,subject_sleep{subject},out.performance(subject,1)),'fontsize',24);
h = legend('ground truth','','RF','','RF + median filter','','HMM');
set(h, 'fontsize',16);

ax(2) = subplot(2,1,2);
hold on;
% set(gca,'position',[0.07 0.05 .92 .4]);
plot(out.target{subject}*10 + 50)
for i=1:size(feature{subject},2),
    plot((i-1)*5+myzscore(feature{subject}(:,i)));%,'.','markersize',10);
end
box off;
axis tight;
set(gca,'ytick',(0:size(feature{subject},2)-1)*5, 'yticklabel',feature_label);
set(gca,'fontsize',16);

linkaxes(ax,'x');

h = figure;
% set(h, 'position',[256         196        1144         752]);
for i=1:size(feature{subject},2),
    subplot(floor(sqrt(size(feature{subject},2))),ceil(sqrt(size(feature{subject},2))),i);
    hold on;
    if sum(i==[1 7 10]), % still,charging,workday
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