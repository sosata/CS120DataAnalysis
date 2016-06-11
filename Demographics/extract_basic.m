% Extracts demographics data

clear;
close all;

tab = readtable('../../../../Data/CS120Clinical/CS120GroupLabels_BasicDemos.xlsx');

subject_basic = tab.STUDYID;
age = cellfun(@(x) (now-datenum(x))/365, tab.DOB);
female = strcmp(tab.GENDER, 'Female');
race = tab.RACE;
ethnicity = tab.ETHNICITY;

save('demo_basic.mat', 'subject_basic', 'age', 'female', 'race', 'ethnicity');

