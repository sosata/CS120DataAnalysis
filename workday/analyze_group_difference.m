clear;
close all;

addpath('../Functions');

load('../settings.mat');
load('features_workday.mat');

state_all = combine_subjects(state);
feature_all = combine_subjects(feature);

% for workday only
ind = find(state_all=='partial');
state_all(ind) = [];
feature_all(ind,:) = [];

state_u = unique(state_all);
feature_all = zscore(feature_all);

tick_size = 0;
colors = lines(length(state_u));

h = figure;
set(h, 'position', [284         453        1205         420]);
hold on;
for i=1:length(state_u),
    plot([0 .01],[0 0],'color', colors(i,:),'linewidth',2);
end
legend(cellstr(state_u));
for i=1:length(state_u),
    for j=1:size(feature_all,2),
        X1 = feature_all(state_all==state_u(i),j);
        bar(j+i/8, mean(X1), 'facecolor', colors(i,:), 'edgecolor', 'k', 'barwidth', 1/8);
        he = errorbar(j+i/8, mean(X1), std(X1)/sqrt(length(X1)), 'linewidth',1,'color', 'k'); 
%         plot((j+i/8)*ones(length(X1),1), X1, '.', 'color', colors(i,:));
    end
end
errorbar_tick(he, tick_size, 'units');
my_xticklabels(1:length(feature_labels), feature_labels, 'rotation', 45, 'HorizontalAlignment','right');
