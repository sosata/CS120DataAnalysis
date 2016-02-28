function plot_rectangle_crossdays(t1, t2, date_start, date_end, color)

if length(t1)~=length(t2),
    error('Vectors must have the same length.');
end
if sum((t2-t1)<0)>0,
    error('Times are inconsistent.');
end

t1_time = mod(t1, 86400);
t1_day = floor(t1/86400);
t2_time = mod(t2, 86400);
t2_day = floor(t2/86400);

hold on;

for i=1:length(t1),
    if t1_day(i)==t2_day(i),
        rectangle('position', [t1_time(i), t1_day(i)-.3, t2_time(i)-t1_time(i), .6], ...
            'facecolor',color,'edgecolor', color);
    elseif t2_day(i)==(t1_day(i)+1),
        rectangle('position', [t1_time(i), t1_day(i)-.3, 24*3600-t1_time(i), .6], ...
            'facecolor',color,'edgecolor', color);
        rectangle('position', [0, t2_day(i)-.3, t2_time(i), .6], ...
            'facecolor',color,'edgecolor', color);
    else
        error('Times are insconsistent');
    end
end

set(gca, 'xtick', 0:3600:23*3600, 'xticklabel', num2str((0:23)'));
xlim([0 24*3600]);
set(gca, 'ytick', date_start:date_end, 'yticklabel', datestr((date_start:date_end)+datenum(1970,1,1),6));
ylim([date_start-1 date_end+1]);
set(gca, 'ygrid', 'on');
xlabel('Time of the day');
ylabel('Days');

set(gca, 'ydir', 'reverse');

end