clear;
close all;

r2 = [0.079, 0.226, 0.284];
r2e = [0.006, 0.010, 0.009];

plot(r2, 'o');
hold on;
errorbar(r2, r2e);

set(gca,'xtick',1:3);
xlabel('PHQ-9 assessment #');
ylabel('R2');