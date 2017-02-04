clear;
close all;

addpath('../functions');

load('../FeatureExtraction/features_biweekly_all');
load('../Assessment/phq9.mat');
load('../Assessment/gad7.mat');
load('../Demographics/demo.mat');
load('../Assessment/tipi.mat');
load('../Assessment/spin.mat');
load('../Assessment/dast.mat');
load('../Assessment/psqi.mat');

week = 1;
assessment = phq.w6;
subject_assessment = subject_phq.w6;

ft = [];
target = [];
subject_analyze = {};
for s = 1:length(feature),
    if size(feature{s},1)>=week,
        ind = find(strcmp(subject_assessment,subject_feature{s}));
        if isempty(ind),
            continue;
        else
            ft = [ft; feature{s}(week,:)];
            target = [target; assessment(ind)];
            subject_analyze = [subject_analyze, subject_feature{s}];
        end
    else
        fprintf('Week %d: subject %s removed due to lack of data', week, subject_feature{s});
    end
end

dlmwrite('python/features.csv',ft,'delimiter','\t');
dlmwrite('python/targets.csv',target,'delimiter','\t');