% This function outputs the confusion matrix between weekday/weekend and
% normal/off days reported by subjects

clear;
close all;

addpath('../Functions');

load('features_workday');

state_all = combine_subjects(state);
feature_all = combine_subjects(feature);

ind = find(state_all=='partial');
state_all(ind) = [];
feature_all(ind, :) = [];

[~, CM, ~, ~] = confusion(cat2num(state_all)'-1, feature_all(:,end)');

fprintf('\t\tweekday\tweekend\n');
fprintf('normal\t%d\t%d\n', CM(1,1), CM(1,2));
fprintf('off\t\t%d\t%d\n', CM(2,1), CM(2,2));

fprintf('chance level: %.4f\n',5/7*CM(1,1)/(CM(1,1)+CM(2,1))+2/7*CM(2,2)/(CM(1,2)+CM(2,2)));