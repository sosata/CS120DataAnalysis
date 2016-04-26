% Extracts SPIN scores from the datasheet
% The answer 'Prefer not to say' (999) is replaced by the rounded average of the rest of the answers

clear;
close all;

% reading baseline (screener) scores

tab = readtable('../../../../Data/CS120Clinical/CS120Final_Baseline.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_spin.w0 = tab.ID;

spin_items = [cellfun(@str2num, tab.spin01_IAmAfraidOfPeopleInAuthority_), ...
    cellfun(@str2num, tab.spin02_IAmBotheredByBlushingInFrontOfPeople_), ...
    cellfun(@str2num, tab.spin03_PartiesAndSocialEventsScareMe_), ...
    cellfun(@str2num, tab.spin04_IAvoidTalkingToPeopleIDon_tKnow_), ...
    cellfun(@str2num, tab.spin05_BeingCriticizedScaresMeALot_), ...
    cellfun(@str2num, tab.spin06_FearOfEmbarrassmentCausesMeToAvoidDoingThingsOrSpeakingT), ...
    cellfun(@str2num, tab.spin07_SweatingInFrontOfPeopleCausesMeDistress_), ...
    cellfun(@str2num, tab.spin08_IAvoidGoingToParties_), ...
    cellfun(@str2num, tab.spin09_IAvoidActivitiesInWhichIAmTheCenterOfAttention_), ...
    cellfun(@str2num, tab.spin10_TalkingToStrangersScaresMe_)];

rows_with_999 = find(any(spin_items==999,2));
for i=rows_with_999',
    spin_cur = spin_items(i,:);
    spin_mean = round(mean(spin_cur(spin_cur~=999)));
    spin_cur(spin_cur==999) = spin_mean;
    spin_items(i,:) = spin_cur;
end

spin.w0 = sum(spin_items,2);

% reading week 3 scores

tab = readtable('../../../../Data/CS120Clinical/CS120Final_3week.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_spin.w3 = tab.ID;

spin_items = [cellfun(@str2num, tab.spinPrompt01_3wkIAmAfraidOfPeopleInAuthority_), ...
    cellfun(@str2num, tab.spinPrompt01_3wkIAmBotheredByBlushingInFrontOfPeople_), ...
    cellfun(@str2num, tab.spinPrompt01_3wkPartiesAndSocialEventsScareMe_), ...
    cellfun(@str2num, tab.spinPrompt01_3wkIAvoidTalkingToPeopleIDon_tKnow_), ...
    cellfun(@str2num, tab.spinPrompt01_3wkBeingCriticizedScaresMeALot_), ...
    cellfun(@str2num, tab.spinPrompt01_3wkFearOfEmbarrassmentCausesMeToAvoidDoingThingsOrSpeakingT), ...
    cellfun(@str2num, tab.spinPrompt01_3wkSweatingInFrontOfPeopleCausesMeDistress_), ...
    cellfun(@str2num, tab.spinPrompt01_3wkIAvoidGoingToParties_), ...
    cellfun(@str2num, tab.spinPrompt01_3wkIAvoidActivitiesInWhichIAmTheCenterOfAttention_), ...
    cellfun(@str2num, tab.spinPrompt01_3wkTalkingToStrangersScaresMe_)];

rows_with_999 = find(any(spin_items==999,2));
for i=rows_with_999',
    spin_cur = spin_items(i,:);
    spin_mean = round(mean(spin_cur(spin_cur~=999)));
    spin_cur(spin_cur==999) = spin_mean;
    spin_items(i,:) = spin_cur;
end

spin.w3 = sum(spin_items,2);

% reading week 6 scores

tab = readtable('../../../../Data/CS120Clinical/CS120Final_6week.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_spin.w6 = tab.ID;

spin_items = [cellfun(@str2num, tab.spinPrompt01_6wkIAmAfraidOfPeopleInAuthority_), ...
    cellfun(@str2num, tab.spinPrompt01_6wkIAmBotheredByBlushingInFrontOfPeople_), ...
    cellfun(@str2num, tab.spinPrompt01_6wkPartiesAndSocialEventsScareMe_), ...
    cellfun(@str2num, tab.spinPrompt01_6wkIAvoidTalkingToPeopleIDon_tKnow_), ...
    cellfun(@str2num, tab.spinPrompt01_6wkBeingCriticizedScaresMeALot_), ...
    cellfun(@str2num, tab.spinPrompt01_6wkFearOfEmbarrassmentCausesMeToAvoidDoingThingsOrSpeakingT), ...
    cellfun(@str2num, tab.spinPrompt01_6wkSweatingInFrontOfPeopleCausesMeDistress_), ...
    cellfun(@str2num, tab.spinPrompt01_6wkIAvoidGoingToParties_), ...
    cellfun(@str2num, tab.spinPrompt01_6wkIAvoidActivitiesInWhichIAmTheCenterOfAttention_), ...
    cellfun(@str2num, tab.spinPrompt01_6wkTalkingToStrangersScaresMe_)];

rows_with_999 = find(any(spin_items==999,2));
for i=rows_with_999',
    spin_cur = spin_items(i,:);
    spin_mean = round(mean(spin_cur(spin_cur~=999)));
    spin_cur(spin_cur==999) = spin_mean;
    spin_items(i,:) = spin_cur;
end

spin.w6 = sum(spin_items,2);

save('spin.mat', 'subject_spin', 'spin');
