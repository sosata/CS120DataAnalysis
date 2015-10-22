function evaluate_allprobes(subject)

load('settings.mat');

probes = {'act', 'aud', 'coe', 'emm', 'lgt', 'fus', 'scr', 'ems', 'tch'};

close all;
h = figure(1);
set(h,'position',[835    84   560   923]);

for i = 1:length(probes),
    filename = [data_dir, subject, '\', probes{i}, '.csv'];
    ax(i) = subplot(length(probes),1,i);
    if exist(filename, 'file'),
        data = readtable(filename, 'delimiter', '\t', 'readvariablenames', false);
        time = data.Var1 + time_zone*3600;
        plot(time, ones(size(time)), '.k', 'markersize', 12);
    end
    ylabel(probes{i});
    set(gca, 'xticklabel', [], 'yticklabel', [], 'xgrid', 'on');
end

linkaxes(ax,'x');
subplot(length(probes),1,length(probes));
a = get(gca,'xlim');
xmin = floor(a(1)/86400)*86400;
xmax = floor(a(2)/86400)*86400;
set(gca, 'xtick', xmin:86400:xmax, 'xticklabel', datestr(((xmin/86400):(xmax/86400))+datenum(1970,1,1),6));

end