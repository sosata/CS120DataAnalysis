function evaluate_allprobes(subject)

load('settings.mat');

probes = {'act', 'aud', 'coe', 'emm', 'lgt', 'fus', 'scr', 'tch', 'wif', 'emm', 'ems', 'eml', 'emc'};

close all;
h = figure(1);
set(h,'position',[835    84   560   923]);
time_min = inf;
time_max = -inf;
for i = 1:length(probes),
    filename = [data_dir, subject, '\', probes{i}, '.csv'];
    subplot(length(probes),1,i);
    if exist(filename, 'file'),
        data = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
        time = data.Var1 + time_zone*3600;
        plot(time, ones(size(time)), '.k', 'markersize', 12);
        if time_min>min(time),
            time_min = min(time);
        end
        if time_max<max(time),
            time_max = max(time);
        end
    end
    ylabel(probes{i});
    set(gca, 'xticklabel', [], 'yticklabel', [], 'xgrid', 'on');
end

xmin = floor(time_min/86400)*86400;
xmax = floor(time_max/86400)*86400;
for i = 1:length(probes),
    subplot(length(probes),1,i);
    if i==1,
        title(subject);
    end
    xlim([time_min time_max]);
    if i==length(probes),
        set(gca, 'xtick', xmin:86400:xmax, 'xticklabel', datestr(((xmin/86400):(xmax/86400))+datenum(1970,1,1),6));
    else
        set(gca, 'xtick', xmin:86400:xmax);
    end
end

end