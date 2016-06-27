clear
close all

tab = readtable('coverage.csv', 'delimiter', '\t', 'readvariablenames', false);

h = figure
set(h, 'position', [352   288   783   420]);
histogram(tab.Var2, 20)
pr_mean = nanmean(tab.Var2);
hold on
plot([pr_mean pr_mean], [0 40], '--k'); 
text(pr_mean, 35, sprintf('mean: %.3f', pr_mean))
xlabel('% Purple Robot (communication events) contacts found in mapping')
ylabel('N');

h = figure
set(h, 'position', [352   288   783   420]);
histogram(tab.Var3, 20)
cs120_mean = nanmean(tab.Var3);
hold on
plot([cs120_mean cs120_mean], [0 200], '--k'); 
text(cs120_mean, 200, sprintf('mean: %.3f', cs120_mean))
xlabel('% CS120 (self-report) contacts found in mapping')
ylabel('N');