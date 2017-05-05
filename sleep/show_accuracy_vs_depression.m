clear;
close all;

addpath('../Functions/');


load('features_sleepdetection.mat');
load('results_personal.mat');
acc_personal = out.performance(:,1);
load('results_global.mat');
acc_global = out.performance(:,1);

clear feature feature_label state 

%% finding screener PHQ9 scores
data = readtable('/data/CS120Clinical/CS120Final_Screener.xlsx');

phq = [];
gad = [];
for i=1:length(subject_sleep)
    ind_subj = find(strcmp(data.ID,subject_sleep{i}));
    phq = [phq; data.score_PHQ(ind_subj)];
    gad = [gad; data.score_GAD(ind_subj)];
end
%% finding screener GAD7 scores

ind_da = find(phq>=10 & gad>=10);
ind_dna = find(phq>=10 & gad<10);
ind_nda = find(phq<10 & gad>=10);
ind_ndna = find(phq<10 & gad<10);

fprintf('personal models:\n');
fprintf('D,A: ');
fprintf('%.2f (%.2f)\n',nanmean(acc_personal(ind_da)),nanstd(acc_personal(ind_da)));
fprintf('D,NA: ');
fprintf('%.2f (%.2f)\n',nanmean(acc_personal(ind_dna)),nanstd(acc_personal(ind_dna)));
fprintf('ND,A: ');
fprintf('%.2f (%.2f)\n',nanmean(acc_personal(ind_nda)),nanstd(acc_personal(ind_nda)));
fprintf('ND,NA: ');
fprintf('%.2f (%.2f)\n',nanmean(acc_personal(ind_ndna)),nanstd(acc_personal(ind_ndna)));

fprintf('global models:\n');
fprintf('D,A: ');
fprintf('%.2f (%.2f)\n',nanmean(acc_global(ind_da)),nanstd(acc_global(ind_da)));
fprintf('D,NA: ');
fprintf('%.2f (%.2f)\n',nanmean(acc_global(ind_dna)),nanstd(acc_global(ind_dna)));
fprintf('ND,A: ');
fprintf('%.2f (%.2f)\n',nanmean(acc_global(ind_nda)),nanstd(acc_global(ind_nda)));
fprintf('ND,NA: ');
fprintf('%.2f (%.2f)\n',nanmean(acc_global(ind_ndna)),nanstd(acc_global(ind_ndna)));

fprintf('averages:\n');
fprintf('PHQ: %.2f (%.2f)\n', nanmean(phq), nanstd(phq));
fprintf('GAD: %.2f (%.2f)\n', nanmean(gad), nanstd(gad));
fprintf('AUDIT: %.2f (%.2f)\n', nanmean(data.Score_AUDIT), nanstd(data.Score_AUDIT));
fprintf('DAST: %.2f (%.2f)\n', nanmean(data.score_DAST), nanstd(data.score_DAST));
return;
