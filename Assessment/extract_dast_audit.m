%% Extracts PHQ9 scores from the datasheet

clear;
close all;

%% reading baseline (screener) scores

tab = readtable('../../../../Data/CS120Clinical/CS120Final_Screener.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_dast = tab.ID;
dast = tab.score_DAST;
audit = tab.Score_AUDIT;

save('dast.mat', 'subject_dast', 'dast', 'audit');
