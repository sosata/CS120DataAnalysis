clear;
close all;

load('settings.mat');

h = figure;
set(h, 'position', [680          49         560        1068]);
hold on;

plot(timestamp_senddata(~isinf(timestamp_senddata)), find(~isinf(timestamp_senddata)), '.', 'markersize', 12);
plot([min(timestamp_senddata); max(timestamp_senddata(~isinf(timestamp_senddata)))]*ones(1,sum(isinf(timestamp_senddata))), ...
    ones(2,1)*find(isinf(timestamp_senddata)), 'k');

set(gca, 'ytick', 1:length(subjects), 'yticklabel', subjects);
set_date_ticks(gca, 1);