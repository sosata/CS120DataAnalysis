% Extracts demographics data

clear;
close all;

tab = readtable('../../../Data/CS120Clinical/CS120GroupLabels_BasicDemos.xlsx');

subject_demo = tab.STUDYID;
age = cellfun(@(x) (now-datenum(x))/365, tab.DOB);
female = strcmp(tab.GENDER, 'Female');

save('demo.mat', 'subject_demo', 'age', 'female');
