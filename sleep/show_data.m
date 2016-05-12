clear;
close all;

load('features_sleepdetection.mat');

h = figure;
set(h,'position',[39 309 1456 420]);

for i=192:length(feature),
    
    subplot 211;
    cla;
    hold on;
    for j=1:size(feature{i},2)
        plot(~isnan(feature{i}(:,j))*j,'.');
    end
    ylim([.5 size(feature{i},2)+.5]);
    box off;
    title(sprintf('%i - %s',i,subject_sleep{i}));

    subplot 212;
    plot(state{i},'.');
    ylim([.5 2.5]);
    box off;

    pause;
end