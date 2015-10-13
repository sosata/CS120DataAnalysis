function plot_time(time, res)

time_dif = diff(time);
lim = mean(time_dif) + std(time_dif)*2;
time_dif = time_dif(time_dif<=lim);
[n, ~] = hist3([time_dif(1:end-1), time_dif(2:end)], {0:res:lim, 0:res:lim});
imagesc(0:res:lim, 0:res:lim, log((n+.01)/max(max(n))));
colormap hot;
xlabel('time before');
ylabel('time after');
set(gca, 'ydir', 'normal');

end