clear;
close all;

load('features_sleepdetection');

features_to_analyze = [2 3 4 5 6 7 8 10 11 12 13 14 15];

p_nan_sleep = [];
p_nan_awake = [];

for i=1:length(feature)
    
    if ~isempty(feature{i}),
        
        ind_awake = find(state{i}==0);
        ind_sleep = find(state{i}==1);
        
        n_nan_sleep = sum(sum(~isnan(feature{i}(ind_sleep,features_to_analyze)),2)==0);
        n_nan_awake = sum(sum(~isnan(feature{i}(ind_awake,features_to_analyze)),2)==0);
        
        p_nan_sleep(i) = n_nan_sleep/length(ind_sleep);
        p_nan_awake(i) = n_nan_awake/length(ind_awake);
        
    else
        p_nan_sleep(i) = nan;
        p_nan_awake(i) = nan;
    end
end

figure
% plot(.9+.2*rand(length(feature),1),p_nan_awake,'.');
% hold on;
% plot(1.9+.2*rand(length(feature),1),p_nan_sleep,'.');
bar([1 2],[nanmean(p_nan_awake),nanmean(p_nan_sleep)],'barwidth',.5,'facecolor',[.5 .5 1])
hold on
n = sqrt(length(feature));
errorbar([1 2],[nanmean(p_nan_awake),nanmean(p_nan_sleep)],[nanstd(p_nan_awake)/n*1.98,nanstd(p_nan_sleep)/n*1.98],'.k',...
    'linewidth',3);
xlim([0 3])
ylim([0 .3])
set(gca, 'xtick',[1 2],'xticklabel',{'Awake','Sleep'});
set(gca, 'ygrid', 'on')
box off
ylabel('Proportion of Missing Sensor Data')