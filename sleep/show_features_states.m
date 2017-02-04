clear;
close all;

load('features_sleepdetection.mat');

h = figure;
set(h,'position',[39 309 1456 420]);

subject = 185;

subplot 211;
cla;
hold on;
for j=1:size(feature{subject},2)
    plot(~isnan(feature{subject}(:,j))*j,'.');
end
ylim([.5 size(feature{subject},2)+.5]);
box off;
title(sprintf('%i - %s',subject,subject_sleep{subject}));
axis tight;

subplot 212;
plot(state{subject},'.');
box off;
axis tight;
ylim([-.5 1.5]);

