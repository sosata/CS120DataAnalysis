clear;
close all;

load('phq9.mat');

h = figure;
set(h, 'position', [526   475   863   272]);
subplot 121;
hist(phq9_3w-phq9, -20:20);
title('week3 - baseline');
xlim([-20 20]);
subplot 122;
hist(phq9_6w-phq9, -20:20);
title('week6 - week3');
xlim([-20 20]);

figure;
hist((phq9_6w-phq9_3w)-(phq9_3w-phq9), -30:30);
xlim([-30 30]);
title('change(week6) - change(week3)');
