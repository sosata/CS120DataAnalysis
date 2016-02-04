%% Extracts PHQ9 scores from the datasheet
%% The answer 'Prefer not to say' (999) is replaced by the rounded average of the rest of the answers

clear;
close all;

tab = readtable('../../../Data/CS120Clinical/CS120Assessment.xlsx');

ind_start = find(cellfun(@(x) ~isempty(x), tab.id),1,'first');
subject_phq9 = tab.id(ind_start:end);
phq9.w0 = tab.score_PHQ(ind_start:end);

phq_3w = tab{ind_start:end, 426:433};
phq_3w = cellfun(@(x) str2num(x), phq_3w);
for i=1:size(phq_3w,1),
    ind_999 = find(phq_3w(i,:)==999);
    ind_not999 = find(phq_3w(i,:)~=999);
    phq_3w(i,ind_999) = round(mean(phq_3w(i,ind_not999)));
end
phq9.w3 = sum(phq_3w,2);

phq_6w = tab{ind_start:end, 519:526};
phq_6w = cellfun(@(x) str2num(x), phq_6w);
for i=1:size(phq_6w,1),
    ind_999 = find(phq_6w(i,:)==999);
    ind_not999 = find(phq_6w(i,:)~=999);
    phq_6w(i,ind_999) = round(mean(phq_6w(i,ind_not999)));
end
phq9.w6 = sum(phq_6w,2);

save('phq9.mat', 'subject_phq9', 'phq9');

