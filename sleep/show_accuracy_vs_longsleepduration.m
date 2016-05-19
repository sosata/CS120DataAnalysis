clear;
close all;

addpath('../Functions/');

load('results_personal.mat');
load('features_sleepdetection.mat');

acc = out.performance(:,1);

% find sleep duration maximum
sleep_dur_max = zeros(length(subject_sleep),1);
sleep_dur_std = zeros(length(subject_sleep),1);
for i=1:length(subject_sleep),
    tab = readtable(['C:\Users\Sohrob\Dropbox\Data\CS120\',subject_sleep{i},'\ems.csv'], ...
        'delimiter','\t','readvariablenames',false);
    
    sleep_dur_max(i) = max(tab.Var4-tab.Var3)/3600/1000;
    sleep_dur_std(i) = std(tab.Var4-tab.Var3)/3600/1000;
    
end

figure;
subplot 121;
plot(sleep_dur_max, acc,'.','markersize',12);
xlabel('sleep duration max');
ylabel('accuracy');
title(sprintf('r = %.3f', mycorr(sleep_dur_max,acc,'pearson')));
box off;

subplot 122;
plot(sleep_dur_std, acc,'.','markersize',12);
xlabel('sleep duration std');
ylabel('accuracy');
title(sprintf('r = %.3f', mycorr(sleep_dur_std,acc,'pearson')));
box off;
