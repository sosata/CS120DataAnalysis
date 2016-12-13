% Extracts baseline demographics data

clear;
close all;

tab = readtable('../../../../Data/CS120Clinical/CS120Final_Baseline.xlsx');

subject_baseline = tab.ID;
ind_baseline = find(~cellfun(@isempty, subject_baseline));

subject_baseline = subject_baseline(ind_baseline);

employed = str2num(cell2mat(tab.slabels02(ind_baseline)));
employed(employed==999) = nan;

numjobs = tab.slabels03(ind_baseline);
numjobs(isnan(numjobs)) = 0;

alone = cellfun(@str2num, tab.slabels06(ind_baseline),'UniformOutput',false);
alone = cell2mat(alone);
alone(alone==999) = nan;

sleepalone = cellfun(@str2num, tab.slabels07(ind_baseline),'UniformOutput',false);
sleepalone = cell2mat(sleepalone);
sleepalone(sleepalone==999) = nan;

phonelocation = cellfun(@str2num,tab.slabels05(ind_baseline));

save 'demo_baseline.mat' 'subject_baseline' 'employed' 'numjobs' 'alone' 'sleepalone' 'phonelocation';
