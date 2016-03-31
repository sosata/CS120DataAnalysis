clear;
close all;

tab = readtable('C:\Users\Sohrob\Dropbox\Data\CS120Clinical\CS120GroupLabels_BasicDemos.xlsx');
% tab = readtable('C:\Users\cbits\Dropbox\Data\CS120Clinical\CS120GroupLabels_BasicDemos.xlsx');

age = (now-datenum(tab.DOB))/365;

hist(age);
xlabel('age');
title(sprintf('mean: %.1f\nSD: %.1f', mean(age), std(age)));
