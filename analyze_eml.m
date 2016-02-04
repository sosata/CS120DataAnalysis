clear;
close all;

load('eml.mat');
addpath('functions');

%% global
pleasure_all = [];
accomplishment_all = [];
for i=1:length(subject_eml),
    pleasure_all = [pleasure_all; pleasure{i}];
    accomplishment_all = [accomplishment_all; accomplishment{i}];
end
h = figure;
set(h, 'position', [424   192   572   528]);
subplot 221;
scatter_discrete(accomplishment_all, pleasure_all, false);
xlabel('accomplishment');
ylabel('pleasure');
subplot 222;
[counts,bins] = hist(pleasure_all, 0:9);
barh(bins, counts, 1);
ylim([-.5 9.5]);
ylabel('pleasure');
subplot 223;
hist(accomplishment_all, 0:9);
xlim([-.5 9.5]);
xlabel('accomplishment');

[r p] = corr(pleasure_all, accomplishment_all)

%% personal
pleasure_personal = [];
accomplishment_personal = [];
for i=1:length(subject_eml),
    pleasure_personal = [pleasure_personal; zscore(pleasure{i})];
    accomplishment_personal = [accomplishment_personal; zscore(accomplishment{i})];
end
h = figure;
set(h, 'position', [1006         187         560         527]);
subplot 221;
plot(accomplishment_personal, pleasure_personal,'.');
xlabel('accomplishment');
ylabel('pleasure');
axis([-5 5 -5 5]);
subplot 222;
[counts,bins] = hist(pleasure_personal, -5:.2:5);
barh(bins, counts, 1);
ylim([-5 5]);
ylabel('pleasure');
subplot 223;
hist(accomplishment_personal, -5:.2:5);
xlim([-5 5]);
xlabel('accomplishment');

[r p] = corr(pleasure_personal, accomplishment_personal)
