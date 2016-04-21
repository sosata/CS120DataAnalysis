%% Extracts PHQ9 scores from the datasheet
%% The answer 'Prefer not to say' (999) is replaced by the rounded average of the rest of the answers

clear;
close all;

%% reading baseline (screener) scores

tab = readtable('../../../../Data/CS120Clinical/CS120Final_Baseline.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_spin = tab.ID;

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

spin = sum(spin_items,2);

save('spin.mat', 'subject_spin', 'spin');
