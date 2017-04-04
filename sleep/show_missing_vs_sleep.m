clear;
close all;

load('features_sleepdetection');

features_to_analyze = [2 3 4 5 6 7 8 10 11 12 13 14 15];

p_nan_sleep = [];
p_nan_awake = [];

for i=1:length(feature)
    
    if ~isempty(feature{i}),
        
        ind_sleep = find(state{i}==1);
        ind_awake = find(state{i}==0);
        
        n_nan_sleep = sum(sum(~isnan(feature{i}(ind_sleep,features_to_analyze)),2)==0);
        n_nan_sleep_light = sum(isnan(feature{i}(ind_sleep,2)));
        n_nan_sleep_sound = sum(isnan(feature{i}(ind_sleep,6)));
        n_nan_sleep_gps = sum(isnan(feature{i}(ind_sleep,10)));
        n_nan_sleep_battery = sum(isnan(feature{i}(ind_sleep,12)));
        n_nan_sleep_wifi = sum(isnan(feature{i}(ind_sleep,10)));
        
        n_nan_awake = sum(sum(~isnan(feature{i}(ind_awake,features_to_analyze)),2)==0);
        n_nan_awake_light = sum(isnan(feature{i}(ind_awake,2)));
        n_nan_awake_sound = sum(isnan(feature{i}(ind_awake,6)));
        n_nan_awake_gps = sum(isnan(feature{i}(ind_awake,10)));
        n_nan_awake_battery = sum(isnan(feature{i}(ind_awake,12)));
        n_nan_awake_wifi = sum(isnan(feature{i}(ind_awake,10)));
        
        p_nan_sleep(i) = n_nan_sleep/length(ind_sleep);
        p_nan_sleep_light(i) = n_nan_sleep_light/length(ind_sleep);
        p_nan_sleep_sound(i) = n_nan_sleep_sound/length(ind_sleep);
        p_nan_sleep_gps(i) = n_nan_sleep_gps/length(ind_sleep);
        p_nan_sleep_battery(i) = n_nan_sleep_battery/length(ind_sleep);
        p_nan_sleep_wifi(i) = n_nan_sleep_wifi/length(ind_sleep);

        p_nan_awake(i) = n_nan_awake/length(ind_awake);
        p_nan_awake_light(i) = n_nan_awake_light/length(ind_awake);
        p_nan_awake_sound(i) = n_nan_awake_sound/length(ind_awake);
        p_nan_awake_gps(i) = n_nan_awake_gps/length(ind_awake);
        p_nan_awake_battery(i) = n_nan_awake_battery/length(ind_awake);
        p_nan_awake_wifi(i) = n_nan_awake_wifi/length(ind_awake);
        
    else
%         p_nan_sleep(i) = nan;
%         p_nan_awake(i) = nan;
    end
end

p_nan = p_nan_sleep./p_nan_awake;
p_nan_light = p_nan_sleep_light./p_nan_awake_light;
p_nan_sound = p_nan_sleep_sound./p_nan_awake_sound;
p_nan_gps = p_nan_sleep_gps./p_nan_awake_gps;
p_nan_battery = p_nan_sleep_battery./p_nan_awake_battery;
p_nan_wifi = p_nan_sleep_wifi./p_nan_awake_wifi;

figure
n = sqrt(length(feature))/1.98;
% bar([1:5 8], [nanmean(p_nan_light) nanmean(p_nan_sound) nanmean(p_nan_gps), ...
%     nanmean(p_nan_battery) nanmean(p_nan_wifi) nanmean(p_nan)],'facecolor',[.6 .8 1]);
hold on;
errorbar([1:5 8], [nanmean(p_nan_light) nanmean(p_nan_sound) nanmean(p_nan_gps), ...
    nanmean(p_nan_battery) nanmean(p_nan_wifi) nanmean(p_nan)],...
    [nanstd(p_nan_light)/n nanstd(p_nan_sound)/n nanstd(p_nan_gps)/n, ...
    nanstd(p_nan_battery)/n nanstd(p_nan_wifi)/n nanstd(p_nan)/n],...
    'o','linewidth',1,'markersize',7);
plot([0 9],[1 1],'color',[.2 .2 .2],'linewidth',2);
text(1,nanmean(p_nan_light)+nanstd(p_nan_light)/n+.1,'Light','horizontalalignment','center');
text(2,nanmean(p_nan_sound)+nanstd(p_nan_sound)/n+.1,'Sound','horizontalalignment','center');
text(3,nanmean(p_nan_gps)+nanstd(p_nan_gps)/n+.1,'GPS','horizontalalignment','center');
text(4,nanmean(p_nan_battery)+nanstd(p_nan_battery)/n+.1,'Battery','horizontalalignment','center');
text(5,nanmean(p_nan_wifi)+nanstd(p_nan_wifi)/n+.1,'WiFi','horizontalalignment','center');
text(8,nanmean(p_nan)+nanstd(p_nan)/n+.1,'All','horizontalalignment','center');
set(gca,'xtick',[]);
set(gca, 'xcolor', [1 1 1]);
set(gca,'ygrid','on');

% bar([1 2],[nanmedian(p_nan_awake_light),nanmedian(p_nan_sleep_light)],'barwidth',.1,'facecolor',[.6 .8 1])
% hold on
% bar([1.1 2.1],[nanmedian(p_nan_awake_sound),nanmedian(p_nan_sleep_sound)],'barwidth',.1,'facecolor',[.6 .8 1])
% bar([1.2 2.2],[nanmedian(p_nan_awake_gps),nanmedian(p_nan_sleep_gps)],'barwidth',.1,'facecolor',[.6 .8 1])
% bar([1.3 2.3],[nanmedian(p_nan_awake_battery),nanmedian(p_nan_sleep_battery)],'barwidth',.1,'facecolor',[.6 .8 1])
% bar([1.4 2.4],[nanmedian(p_nan_awake_wifi),nanmedian(p_nan_sleep_wifi)],'barwidth',.1,'facecolor',[.6 .8 1])
% bar([1.5 2.5],[nanmedian(p_nan_awake),nanmedian(p_nan_sleep)],'barwidth',.1,'facecolor',[.6 .8 1])


% errorbar([1 2],[nanmedian(p_nan_awake),nanmedian(p_nan_sleep)],...
%     [nanstd(p_nan_awake)/n,nanstd(p_nan_sleep)/n],'.k','linewidth',1);
% plot(.9+.2*rand(length(feature),1),p_nan_awake,'.k');
% plot(1.9+.2*rand(length(feature),1),p_nan_sleep,'.k');

xlim([0 9])
ylim([.75 2.5])
box off
ylabel('Sleep-to-Awake Missing Sensor Data Ratio')
set(gca, 'Ticklength', [0 0])
