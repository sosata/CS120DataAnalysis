clear;
close all;

addpath('../Functions/');

load('results_personal.mat');
load('features_sleepdetection.mat');

acc = out.performance(:,1);

% find sleep duration maximum
sleep_dur_max = zeros(length(subject_sleep),1);
sleep_dur_mean = zeros(length(subject_sleep),1);
for i=1:length(subject_sleep),
    
    filename = ['C:\Users\Sohrob\Dropbox\Data\CS120\',subject_sleep{i},'\ems.csv'];
    
    if exist(filename,'file'),
        tab = readtable(filename, 'delimiter','\t','readvariablenames',false);
        sleep_dur_max(i) = max(tab.Var4-tab.Var3)/3600/1000;
        sleep_dur_mean(i) = mean(tab.Var4-tab.Var3)/3600/1000;
    else
        sleep_dur_max(i) = nan;
        sleep_dur_mean(i) = nan;
    end
    
end

h = figure;
set(h,'position',[520   727   831   371]);
subplot 121;
plot(sleep_dur_mean, acc,'.','markersize',12);
xlabel('sleep duration mean');
ylabel('accuracy');
title(sprintf('r = %.3f', mycorr(sleep_dur_mean,acc,'pearson')));
box off;

subplot 122;
plot(sleep_dur_max, acc,'.','markersize',12);
xlabel('sleep duration max');
ylabel('accuracy');
title(sprintf('r = %.3f', mycorr(sleep_dur_max,acc,'pearson')));
box off;
