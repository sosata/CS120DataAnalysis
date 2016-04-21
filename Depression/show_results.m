clear;
close all;

load('prediction.mat');

plot(R2,'.','markersize',12);

figure;
plot(target_all, '.', 'markersize', 10);
hold on;
plot(out_all, '.r', 'markersize', 10);