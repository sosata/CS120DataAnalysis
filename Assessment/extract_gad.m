%% Extracts PHQ9 scores from the datasheet
%% The answer 'Prefer not to say' (999) is replaced by the rounded average of the rest of the answers

clear;
close all;

%% reading baseline (screener) scores

tab = readtable('../../../../Data/CS120Clinical/CS120Final_Screener.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_gad.w0 = tab.ID;
gad.w0 = zeros(size(tab,1),1);
for x=1:7,
    gad.w0 = gad.w0 + str2num(cell2mat(tab.(sprintf('gad0%d',x))));
end

%% reading week 3 scores

tab = readtable('../../../../Data/CS120Clinical/CS120Final_3week.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_gad.w3 = tab.ID;
gad.w3 = cellfun(@(x) str2num(x), tab.gadintro01_3wkBecomingEasilyAnnoyedOrIrritable)+...
    cellfun(@(x) str2num(x), tab.gadintro01_3wkBeingSoRestlessThatItIsHardToSitStill)+...
    cellfun(@(x) str2num(x), tab.gadintro01_3wkFeelingAfraidAsIfSomethingAwfulMightHappen)+...
    cellfun(@(x) str2num(x), tab.gadintro01_3wkFeelingNervous_Anxious_OrOnEdge)+...
    cellfun(@(x) str2num(x), tab.gadintro01_3wkHavingTroubleRelaxing)+...
    cellfun(@(x) str2num(x), tab.gadintro01_3wkNotBeingAbleToStopOrControlWorrying)+...
    cellfun(@(x) str2num(x), tab.gadintro01_3wkWorryingTooMuchAboutDifferentThings);
ind = find(gad.w3>=999);
subject_gad.w3(ind) = [];
gad.w3(ind) = [];

%% reading week 6 scores

tab = readtable('../../../../Data/CS120Clinical/CS120Final_6week.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_gad.w6 = tab.ID;
gad.w6 = cellfun(@(x) str2num(x), tab.gadintro01_6wkBecomingEasilyAnnoyedOrIrritable)+...
    cellfun(@(x) str2num(x), tab.gadintro01_6wkBeingSoRestlessThatItIsHardToSitStill)+...
    cellfun(@(x) str2num(x), tab.gadintro01_6wkFeelingAfraidAsIfSomethingAwfulMightHappen)+...
    cellfun(@(x) str2num(x), tab.gadintro01_6wkFeelingNervous_Anxious_OrOnEdge)+...
    cellfun(@(x) str2num(x), tab.gadintro01_6wkHavingTroubleRelaxing)+...
    cellfun(@(x) str2num(x), tab.gadintro01_6wkNotBeingAbleToStopOrControlWorrying)+...
    cellfun(@(x) str2num(x), tab.gadintro01_6wkWorryingTooMuchAboutDifferentThings);
ind = find(gad.w6>=999);
subject_gad.w6(ind) = [];
gad.w6(ind) = [];

save('gad7.mat', 'subject_gad', 'gad');
