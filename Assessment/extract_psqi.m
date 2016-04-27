% Extracts SPIN scores from the datasheet
% The answer 'Prefer not to say' (999) is replaced by the rounded average of the rest of the answers

clear;
close all;

%% reading baseline (screener) scores

tab = readtable('../../../../Data/CS120Clinical/CS120Final_Baseline.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_psqi.w0 = tab.ID;

q1_h = tab.psqi01_h;
q1_m = cellfun(@str2num, tab.psqi01_m);
q1_ampm = cellfun(@str2num, tab.psqi01_p);
q2 = tab.psqi02;
q3_h = tab.psqi03_h;
q3_m = cellfun(@str2num, tab.psqi03_m);
q3_ampm = cellfun(@str2num, tab.psqi03_p);
q4 = tab.psqi04;
q5_a = cellfun(@str2num, tab.psqi05aCannotGetToSleepWithin30Minutes);
q5_b = cellfun(@str2num, tab.psqi05bWakeUpInTheMiddleOfTheNightOrEarlyMorning);
q5_c = cellfun(@str2num, tab.psqi05cHaveToGetUpToUseTheBathroom);
q5_d = cellfun(@str2num, tab.psqi05dCannotBreatheComfortably);
q5_e = cellfun(@str2num, tab.psqi05eCoughOrSnoreLoudly);
q5_f = cellfun(@str2num, tab.psqi05fFeelTooCold);
q5_g = cellfun(@str2num, tab.psqi05gFeelTooHot);
q5_h = cellfun(@str2num, tab.psqi05hHaveBadDreams);
q5_i = cellfun(@str2num, tab.psqi05iHavePain);
q5_j = cellfun(@str2num, tab.psqi05j_IsThereAnyOtherReasonNotPreviouslyMentionedThatIsAffect);
q5_ja = tab.psqi05j_a;
q5_jb = cellfun(@str2num, tab.psqi05j_b, 'UniformOutput', false);
q6 = cellfun(@str2num, tab.psqi06);
q7 = cellfun(@str2num, tab.psqi07);
q8 = cellfun(@str2num, tab.psqi08);
q9 = cellfun(@str2num, tab.psqi09);

% subjective sleep quality
q6(q6==999) = round(mean(q6(q6~=999)));
comp(:,1) = q6;

% sleep latency
q2 = 1*((q2>=15)&(q2<=30)) + 2*((q2>=31)&(q2<=60)) + 3*(q2>60);
comp(:,2) = q2 + q5_a;
comp(:,2) = ceil(comp(:,2)/2);

% sleep duration
comp(:,3) = 1*((q4>6)&(q4<=7)) + 2*((q4>5)&(q4<=6)) + 3*(q4<=5);

% habitual sleep efficiency
sleep_dur = q4;
q1_ampm(q1_h==12) = 3 - q1_ampm(q1_h==12);  % switching am/pm for 12 as they are wrong by definition
q3_ampm(q3_h==12) = 3 - q3_ampm(q3_h==12);  % switching am/pm for 12 as they are wrong by definition
bed_dur_h = (q1_ampm==q3_ampm).*(q3_h - q1_h) + (q1_ampm~=q3_ampm).*(q3_h - q1_h + 12);
fprintf('%d negative bed duration(s) corrected.\n', sum(bed_dur_h<0));
bed_dur_h(bed_dur_h<0) = bed_dur_h(bed_dur_h<0) + 12;   % subject's miskates
bed_dur = bed_dur_h + (q3_m - q1_m)/60;
efficieny = sleep_dur./bed_dur*100;
comp(:,4) = 1*((efficieny>=75)&(efficieny<85)) + 2*((efficieny>=65)&(efficieny<75)) + 3*(efficieny<65);

% sleep disturbances
q5_sum = q5_b+q5_c+q5_d+q5_e+q5_f+q5_g+q5_h+q5_i;
q5_sum(q5_j==1) = q5_sum(q5_j==1) + cell2mat(q5_jb(q5_j==1));
comp(:,5) = 1*((q5_sum>=1)&(q5_sum<=9)) + 2*((q5_sum>=10)&(q5_sum<=18)) + 3*((q5_sum>=19)&(q5_sum<=27));

% use of sleeping medication
q7(q7==999) = round(mean(q7(q7~=999)));
comp(:,6) = q7;

% daytime dysfunction
q8(q8==999) = round(mean(q8(q8~=999)));
q9(q9==999) = round(mean(q9(q9~=999)));
comp(:,7) = ceil((q8+q9)/2);

psqi.w0 = sum(comp,2);

%% reading week 3 scores

tab = readtable('../../../../Data/CS120Clinical/CS120Final_3week.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_psqi.w3 = tab.ID;

q1_h = tab.psqi01_h_3wk;
q1_m = cellfun(@str2num, tab.psqi01_m_3wk);
q1_ampm = cellfun(@str2num, tab.psqi01_p_3wk);
q2 = tab.psqi02_3wk;
q3_h = tab.psqi03_h_3wk;
q3_m = cellfun(@str2num, tab.psqi03_m_3wk);
q3_ampm = cellfun(@str2num, tab.psqi03_p_3wk);
q4 = tab.psqi04_3wk;
q5_a = cellfun(@str2num, tab.psqiPrompt02_3wkCannotBreatheComfortably);
q5_b = cellfun(@str2num, tab.psqiPrompt02_3wkCannotGetToSleepWithin30Minutes);
q5_c = cellfun(@str2num, tab.psqiPrompt02_3wkCoughOrSnoreLoudly);
q5_d = cellfun(@str2num, tab.psqiPrompt02_3wkFeelTooCold);
q5_e = cellfun(@str2num, tab.psqiPrompt02_3wkFeelTooHot);
q5_f = cellfun(@str2num, tab.psqiPrompt02_3wkHaveBadDreams);
q5_g = cellfun(@str2num, tab.psqiPrompt02_3wkHavePain);
q5_h = cellfun(@str2num, tab.psqiPrompt02_3wkHaveToGetUpToUseTheBathroom);
q5_i = cellfun(@str2num, tab.psqiPrompt02_3wkWakeUpInTheMiddleOfTheNightOrEarlyMorning);
q5_j = cellfun(@str2num, tab.psqi05j_3wk);
% q5_ja = tab.psqi05j_a;    % missing
q5_jb = cellfun(@str2num, tab.psqi05j_3wk_1, 'UniformOutput', false);
q6 = cellfun(@str2num, tab.psqi06_3wk);
q7 = cellfun(@str2num, tab.psqi07_3wk);
q8 = cellfun(@str2num, tab.psqi08_3wk);
q9 = cellfun(@str2num, tab.psqi09_3wk);

% subjective sleep quality
comp = [];
q6(q6==999) = round(mean(q6(q6~=999)));
comp(:,1) = q6;

% sleep latency
q2 = 1*((q2>=15)&(q2<=30)) + 2*((q2>=31)&(q2<=60)) + 3*(q2>60);
comp(:,2) = q2 + q5_a;
comp(:,2) = ceil(comp(:,2)/2);

% sleep duration
comp(:,3) = 1*((q4>6)&(q4<=7)) + 2*((q4>5)&(q4<=6)) + 3*(q4<=5);

% habitual sleep efficiency
sleep_dur = q4;
q1_ampm(q1_h==12) = 3 - q1_ampm(q1_h==12);  % switching am/pm for 12 as they are wrong by definition
q3_ampm(q3_h==12) = 3 - q3_ampm(q3_h==12);  % switching am/pm for 12 as they are wrong by definition
bed_dur_h = (q1_ampm==q3_ampm).*(q3_h - q1_h) + (q1_ampm~=q3_ampm).*(q3_h - q1_h + 12);
fprintf('%d negative bed duration(s) corrected.\n', sum(bed_dur_h<0));
bed_dur_h(bed_dur_h<0) = bed_dur_h(bed_dur_h<0) + 12;   % subject's miskates
bed_dur = bed_dur_h + (q3_m - q1_m)/60;
efficieny = sleep_dur./bed_dur*100;
comp(:,4) = 1*((efficieny>=75)&(efficieny<85)) + 2*((efficieny>=65)&(efficieny<75)) + 3*(efficieny<65);

% sleep disturbances
q5_sum = q5_b+q5_c+q5_d+q5_e+q5_f+q5_g+q5_h+q5_i;
q5_sum(q5_j==1) = q5_sum(q5_j==1) + cell2mat(q5_jb(q5_j==1));
comp(:,5) = 1*((q5_sum>=1)&(q5_sum<=9)) + 2*((q5_sum>=10)&(q5_sum<=18)) + 3*((q5_sum>=19)&(q5_sum<=27));

% use of sleeping medication
q7(q7==999) = round(mean(q7(q7~=999)));
comp(:,6) = q7;

% daytime dysfunction
q8(q8==999) = round(mean(q8(q8~=999)));
q9(q9==999) = round(mean(q9(q9~=999)));
comp(:,7) = ceil((q8+q9)/2);

psqi.w3 = sum(comp,2);

%% reading week 6 scores

tab = readtable('../../../../Data/CS120Clinical/CS120Final_6week.xlsx');
ind = cellfun(@(x) isempty(x), tab.ID);
tab(ind, :) = [];

subject_psqi.w6 = tab.ID;

q1_h = tab.psqi01_h_6wk;
q1_m = cellfun(@str2num, tab.psqi01_m_6wk);
q1_ampm = cellfun(@str2num, tab.psqi01_p_6wk);
q2 = tab.psqi02_6wk;
q3_h = tab.psqi03_h_6wk;
q3_m = cellfun(@str2num, tab.psqi03_m_6wk);
q3_ampm = cellfun(@str2num, tab.psqi03_p_6wk);
q4 = tab.psqi04_6wk;
q5_a = cellfun(@str2num, tab.psqiPrompt02_6wkCannotBreatheComfortably);
q5_b = cellfun(@str2num, tab.psqiPrompt02_6wkCannotGetToSleepWithin30Minutes);
q5_c = cellfun(@str2num, tab.psqiPrompt02_6wkCoughOrSnoreLoudly);
q5_d = cellfun(@str2num, tab.psqiPrompt02_6wkFeelTooCold);
q5_e = cellfun(@str2num, tab.psqiPrompt02_6wkFeelTooHot);
q5_f = cellfun(@str2num, tab.psqiPrompt02_6wkHaveBadDreams);
q5_g = cellfun(@str2num, tab.psqiPrompt02_6wkHavePain);
q5_h = cellfun(@str2num, tab.psqiPrompt02_6wkHaveToGetUpToUseTheBathroom);
q5_i = cellfun(@str2num, tab.psqiPrompt02_6wkWakeUpInTheMiddleOfTheNightOrEarlyMorning);
q5_j = cellfun(@str2num, tab.psqi05j_6wk);
% q5_ja = tab.psqi05j_a;    % missing
q5_jb = cellfun(@str2num, tab.psqi05j_6wk_1, 'UniformOutput', false);
q6 = cellfun(@str2num, tab.psqi06_6wk);
q7 = cellfun(@str2num, tab.psqi07_6wk);
q8 = cellfun(@str2num, tab.psqi08_6wk);
q9 = cellfun(@str2num, tab.psqi09_6wk);

% subjective sleep quality
comp = [];
q6(q6==999) = round(mean(q6(q6~=999)));
comp(:,1) = q6;

% sleep latency
q5_a(q5_a==999) = round(mean(q5_a(q5_a~=999)));
q2 = 1*((q2>=15)&(q2<=30)) + 2*((q2>=31)&(q2<=60)) + 3*(q2>60);
comp(:,2) = q2 + q5_a;
comp(:,2) = ceil(comp(:,2)/2);

% sleep duration
comp(:,3) = 1*((q4>6)&(q4<=7)) + 2*((q4>5)&(q4<=6)) + 3*(q4<=5);

% habitual sleep efficiency
sleep_dur = q4;
q1_ampm(q1_h==12) = 3 - q1_ampm(q1_h==12);  % switching am/pm for 12 as they are wrong by definition
q3_ampm(q3_h==12) = 3 - q3_ampm(q3_h==12);  % switching am/pm for 12 as they are wrong by definition
bed_dur_h = (q1_ampm==q3_ampm).*(q3_h - q1_h) + (q1_ampm~=q3_ampm).*(q3_h - q1_h + 12);
fprintf('%d negative bed duration(s) corrected.\n', sum(bed_dur_h<0));
bed_dur_h(bed_dur_h<0) = bed_dur_h(bed_dur_h<0) + 12;   % subject's miskates
bed_dur = bed_dur_h + (q3_m - q1_m)/60;
efficieny = sleep_dur./bed_dur*100;
comp(:,4) = 1*((efficieny>=75)&(efficieny<85)) + 2*((efficieny>=65)&(efficieny<75)) + 3*(efficieny<65);

% sleep disturbances
q5_sum = q5_b+q5_c+q5_d+q5_e+q5_f+q5_g+q5_h+q5_i;
q5_sum(q5_j==1) = q5_sum(q5_j==1) + cell2mat(q5_jb(q5_j==1));
comp(:,5) = 1*((q5_sum>=1)&(q5_sum<=9)) + 2*((q5_sum>=10)&(q5_sum<=18)) + 3*((q5_sum>=19)&(q5_sum<=27));

% use of sleeping medication
q7(q7==999) = round(mean(q7(q7~=999)));
comp(:,6) = q7;

% daytime dysfunction
q8(q8==999) = round(mean(q8(q8~=999)));
q9(q9==999) = round(mean(q9(q9~=999)));
comp(:,7) = ceil((q8+q9)/2);

psqi.w6 = sum(comp,2);

save('psqi.mat', 'subject_psqi', 'psqi');
