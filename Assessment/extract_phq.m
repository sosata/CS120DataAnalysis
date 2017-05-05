%% Extracts PHQ9 scores from the datasheet
%% The answer 'Prefer not to say' (999) is replaced by the rounded average of the rest of the answers

clear;
close all;

%% reading baseline (screener) scores

tab = readtable('../../../../Data/CS120Clinical/CS120Final_Screener.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_phq.w0 = tab.ID;
phq.w0 = zeros(size(tab,1),1);
for x=1:8,
    phq.w0 = phq.w0 + str2num(cell2mat(tab.(sprintf('phq0%d',x))));
end

%% reading week 3 scores

tab = readtable('../../../../Data/CS120Clinical/CS120Final_3week.xlsx');
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

%% reading week 6 scores

tab = readtable('../../../../Data/CS120Clinical/CS120Final_6week.xlsx');
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

%% change in scores

% from baseline to week 3
cnt = 1;
for i = 1:length(phq.w3),
    ind = find(strcmp(subject_phq.w0, subject_phq.w3{i}));
    if ~isempty(ind),
        subject_phq.w03{cnt} = subject_phq.w3{i};
        phq.w03(cnt) = phq.w3(i) - phq.w0(ind);
        cnt = cnt+1;
    end
end
% from week 3 to 6
cnt = 1;
for i = 1:length(phq.w6),
    ind = find(strcmp(subject_phq.w3, subject_phq.w6{i}));
    if ~isempty(ind),
        subject_phq.w36{cnt} = subject_phq.w6{i};
        phq.w36(cnt) = phq.w6(i) - phq.w3(ind);
        cnt = cnt+1;
    end
end

save('phq9.mat', 'subject_phq', 'phq');

