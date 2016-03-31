%% Extracts PHQ9 scores from the datasheet
%% The answer 'Prefer not to say' (999) is replaced by the rounded average of the rest of the answers

clear;
close all;

%% reading baseline (screener) scores

tab = readtable('../../../Data/CS120Clinical/CS120Final_Screener.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_phq.w0 = tab.ID;
phq.w0 = zeros(size(tab,1),1);
for x=1:8,
    phq.w0 = phq.w0 + str2num(cell2mat(tab.(sprintf('phq0%d',x))));
end

subject_gad.w0 = tab.ID;
gad.w0 = zeros(size(tab,1),1);
for x=1:7,
    gad.w0 = gad.w0 + str2num(cell2mat(tab.(sprintf('gad0%d',x))));
end

%% reading week 3 scores

tab = readtable('../../../Data/CS120Clinical/CS120Final_3week.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_phq.w3 = tab.ID;
phq.w3 = cellfun(@(x) str2num(x), tab.phqPrompt01_3wkFeelingBadAboutYourself_OrThatYouAreAFailureOrHa)+...
    cellfun(@(x) str2num(x), tab.phqPrompt01_3wkFeelingDown_Depressed_OrHopeless)+...
    cellfun(@(x) str2num(x), tab.phqPrompt01_3wkFeelingTiredOrHavingLittleEnergy)+...
    cellfun(@(x) str2num(x), tab.phqPrompt01_3wkLittleInterestOrPleasureInDoingThings)+...
    cellfun(@(x) str2num(x), tab.phqPrompt01_3wkMovingOrSpeakingSoSlowlyThatOtherPeopleCouldHave)+...
    cellfun(@(x) str2num(x), tab.phqPrompt01_3wkPoorAppetiteOrOvereating)+...
    cellfun(@(x) str2num(x), tab.phqPrompt01_3wkTroubleConcentratingOnThings_SuchAsReadingTheNew)+...
    cellfun(@(x) str2num(x), tab.phqPrompt01_3wkTroubleFallingOrStayingAsleep_OrSleepingTooMuch);
ind = find(phq.w3>=999);
subject_phq.w3(ind) = [];
phq.w3(ind) = [];

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

tab = readtable('../../../Data/CS120Clinical/CS120Final_6week.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_phq.w6 = tab.ID;
phq.w6 = cellfun(@(x) str2num(x), tab.phqPrompt01_6wkFeelingBadAboutYourself_OrThatYouAreAFailureOrHa)+...
    cellfun(@(x) str2num(x), tab.phqPrompt01_6wkFeelingDown_Depressed_OrHopeless)+...
    cellfun(@(x) str2num(x), tab.phqPrompt01_6wkFeelingTiredOrHavingLittleEnergy)+...
    cellfun(@(x) str2num(x), tab.phqPrompt01_6wkLittleInterestOrPleasureInDoingThings)+...
    cellfun(@(x) str2num(x), tab.phqPrompt01_6wkMovingOrSpeakingSoSlowlyThatOtherPeopleCouldHave)+...
    cellfun(@(x) str2num(x), tab.phqPrompt01_6wkPoorAppetiteOrOvereating)+...
    cellfun(@(x) str2num(x), tab.phqPrompt01_6wkTroubleConcentratingOnThings_SuchAsReadingTheNew)+...
    cellfun(@(x) str2num(x), tab.phqPrompt01_6wkTroubleFallingOrStayingAsleep_OrSleepingTooMuch);
ind = find(phq.w6>=999);
subject_phq.w6(ind) = [];
phq.w6(ind) = [];

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

subplot 321;
hist(phq.w0, 24);
title('PHQ9');
ylabel('week 0');
subplot 322;
hist(gad.w0, 21);
title('GAD7');
subplot 323;
hist(phq.w3, 24);
ylabel('week 3');
subplot 324;
hist(gad.w3, 21);
subplot 325;
hist(phq.w6, 24);
ylabel('week 6');
subplot 326;
hist(gad.w6, 21);

save('phq9.mat', 'subject_phq', 'phq');
save('gad7.mat', 'subject_gad', 'gad');
