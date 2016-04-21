% Extracts TIPI (10-item big 5 personality)
% The answer 'Prefer not to say' (999) is replaced by NaN

clear;
close all;

tab = readtable('../../../../Data/CS120Clinical/CS120Final_Baseline.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_tipi = tab.ID;
tipi = zeros(size(tab,1),5);

tipi(:,1) = cellfun(@str2num,tab.tipi01_Extraverted_Enthusiastic_) + 8-cellfun(@str2num,tab.tipi06_Reserved_Quiet_);  %Extraversion
tipi(:,2) = 8-cellfun(@str2num,tab.tipi02_Critical_Quarrelsome_) + cellfun(@str2num,tab.tipi07_Sympathetic_Warm_);    %Agreeableness
tipi(:,3) = cellfun(@str2num,tab.tipi03_Dependable_Self_disciplined_) + 8-cellfun(@str2num,tab.tipi08_Disorganized_Careless_); %Conscientiousness
tipi(:,4) = 8-cellfun(@str2num,tab.tipi04_Anxious_EasilyUpset_) + cellfun(@str2num,tab.tipi09_Calm_EmotionallyStable_);   %Emotional Stability
tipi(:,5) = cellfun(@str2num,tab.tipi05_OpenToNewExperiences_Complex_) + 8-cellfun(@str2num,tab.tipi10_Conventional_Uncreative_); %Openness to Experience

tipi((tipi<-800)|(tipi>800)) = NaN;

tipi_label = {'extraversion','agreeableness','conscientiousness','stability','openness'};

save('tipi.mat', 'subject_tipi', 'tipi', 'tipi_label');
