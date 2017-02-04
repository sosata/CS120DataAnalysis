clear;
close all;

addpath('functions');

% within subject params
window_size = 12;
window_overlap = 10;

%% reading

load('features_ema.mat');
normalize = false;

feature_all = [];
state_all = [];
for i = 1:length(feature),
    state{i} = [mood{i}, energy{i}, focus{i}, calm{i}];
    if normalize,
        feature{i} = zscore(feature{i});
        state{i} = zscore(state{i});
    end
    feature_all = [feature_all; feature{i}];
    state_all = [state_all; state{i}];
end

%% within subject correlations
figure;
for i=1:length(time),
    cnt = 0;
    for j = 1:(window_size-window_overlap):length(time{i}),
        cnt = cnt+1;
        [rmc(i,cnt), ~] = corr(mood{i}(j:min(j+window_size-1,end)),calm{i}(j:min(j+window_size-1,end)));
        rmc(i,cnt) = abs(rmc(i,cnt));
        [rmf(i,cnt), ~] = corr(mood{i}(j:min(j+window_size-1,end)),focus{i}(j:min(j+window_size-1,end)));
        rmf(i,cnt) = abs(rmf(i,cnt));
        [rme(i,cnt), ~] = corr(mood{i}(j:min(j+window_size-1,end)),energy{i}(j:min(j+window_size-1,end)));
        rme(i,cnt) = abs(rme(i,cnt));
        [ref(i,cnt), ~] = corr(energy{i}(j:min(j+window_size-1,end)),focus{i}(j:min(j+window_size-1,end)));
        ref(i,cnt) = abs(ref(i,cnt));
    end
end
subplot 221;
rmc(rmc==0) = min(min(rmc));
imagesc(rmc);
xlabel('samples');
ylabel('subjects');
title('mood/calmness');
subplot 222;
rmf(rmf==0) = min(min(rmf));
imagesc(rmf);
xlabel('samples');
ylabel('subjects');
title('mood/focus');
subplot 223;
rme(rme==0) = min(min(rme));
imagesc(rme);
xlabel('samples');
ylabel('subjects');
title('mood/energy');
subplot 224;
ref(ref==0) = min(min(ref));
imagesc(ref);
xlabel('samples');
ylabel('subjects');
title('energy/focus');

%% mean of all on the same day
time_start = floor(min(cellfun(@(x) min(x), time))/86400)*86400;
time_end = floor(max(cellfun(@(x) max(x), time))/86400)*86400;
cnt = 0;
for t=time_start:86400:time_end,
    cnt = cnt+1;
    mood_daily(cnt) = 0;
    calm_daily(cnt) = 0;
    energy_daily(cnt) = 0;
    focus_daily(cnt) = 0;
    cnt2 = 0;
    for i=1:length(time),
        ind = find((time{i}>=t)&(time{i}<t+86400));
        if ~isempty(ind),
            mood_daily(cnt) = mood_daily(cnt) + mean(mood{i}(ind));
            calm_daily(cnt) = calm_daily(cnt) + mean(calm{i}(ind));
            energy_daily(cnt) = energy_daily(cnt) + mean(energy{i}(ind));
            focus_daily(cnt) = focus_daily(cnt) + mean(focus{i}(ind));
            cnt2 = cnt2+1;
        end
    end
    mood_daily(cnt) = mood_daily(cnt)/cnt2;
    calm_daily(cnt) = calm_daily(cnt)/cnt2;
    energy_daily(cnt) = energy_daily(cnt)/cnt2;
    focus_daily(cnt) = focus_daily(cnt)/cnt2;
end
figure;
subplot 411;
plot(time_start:86400:time_end,mood_daily);
set_date_ticks(gca, 7);
subplot 412;
plot(time_start:86400:time_end,focus_daily);
set_date_ticks(gca, 7);
subplot 413;
plot(time_start:86400:time_end,energy_daily);
set_date_ticks(gca, 7);
subplot 414;
plot(time_start:86400:time_end,calm_daily);
set_date_ticks(gca, 7);

%% within subject autocorrelations
figure; colormap gray;
for i=1:length(time),
    a_mood{i} = abs(autocorr(mood{i},min(30,length(time{i})-1)));
    a_calm{i} = abs(autocorr(calm{i},min(30,length(time{i})-1)));
    a_focus{i} = abs(autocorr(focus{i},min(30,length(time{i})-1)));
    a_energy{i} = abs(autocorr(energy{i},min(30,length(time{i})-1)));
end
b_mood = zeros(length(time), max(cellfun(@(x) length(x), a_mood)));
b_calm = zeros(length(time), max(cellfun(@(x) length(x), a_calm)));
b_focus = zeros(length(time), max(cellfun(@(x) length(x), a_focus)));
b_energy = zeros(length(time), max(cellfun(@(x) length(x), a_energy)));
for i=1:length(time),
    for j=1:length(a_mood{i}),
        b_mood(i,j) = a_mood{i}(j);
        b_calm(i,j) = a_calm{i}(j);
        b_focus(i,j) = a_focus{i}(j);
        b_energy(i,j) = a_energy{i}(j);
    end
end
subplot 221;
imagesc(b_mood);
title('mood');
subplot 222;
imagesc(b_focus);
title('focus');
subplot 223;
imagesc(b_calm);
title('calm');
subplot 224;
imagesc(b_energy);
title('energy');

%% cross-subject cross-correlation

day_range = 1:2:21;

figure;
for k = 1:length(day_range),
    feature_daily = [];
    state_daily = [];
    for i=1:length(feature),
        time_start = floor(time{i}(1)/86400)*86400;
        time_end = floor(time{i}(end)/86400)*86400;
        ind = find((time{i}>=time_start+(day(k)-1)*86400)&(time{i}<time_start+(day(k))*86400));
        if ~isempty(ind),
            feature_daily = [feature_daily; feature{i}(ind,:)];
            state_daily = [state_daily; state{i}(ind,:)];
        end
    end
    for i=1:size(feature_daily,2),
       r_mood(k,i) = corr(state_daily(:,1), feature_daily(:,i),'type','spearman') ;
       r_energy(k,i) = corr(state_daily(:,2), feature_daily(:,i),'type','spearman') ;
       r_focus(k,i) = corr(state_daily(:,3), feature_daily(:,i),'type','spearman') ;
       r_calm(k,i) = corr(state_daily(:,4), feature_daily(:,i),'type','spearman') ;
    end
    subplot(floor(sqrt(length(day_range))), ceil(length(day_range)/floor(sqrt(length(day_range)))), k);
    imagesc(cov(zscore(state_daily)));
    title(sprintf('day %d',day_range(k)));
    set(gca, 'xtick', 1:4, 'xticklabel',{'mood','energy','focus','calm'}); 
    set(gca, 'ytick', 1:4, 'yticklabel',{'mood','energy','focus','calm'}); 
    set(gca,'clim',[-1 1]);
    colorbar;

end

figure;
subplot 221;
imagesc(r_mood');
set(gca, 'ytick', 1:length(feature_labels), 'yticklabel', feature_labels);
set(gca, 'xtick', 1:length(day_range), 'xticklabel', num2str(day_range'));
title('mood');
subplot 222;
imagesc(r_energy');
set(gca, 'ytick', 1:length(feature_labels), 'yticklabel', feature_labels);
set(gca, 'xtick', 1:length(day_range), 'xticklabel', num2str(day_range'));
title('energy');
subplot 223;
imagesc(r_focus');
set(gca, 'ytick', 1:length(feature_labels), 'yticklabel', feature_labels);
set(gca, 'xtick', 1:length(day_range), 'xticklabel', num2str(day_range'));
title('focus');
subplot 224;
imagesc(r_calm');
set(gca, 'ytick', 1:length(feature_labels), 'yticklabel', feature_labels);
set(gca, 'xtick', 1:length(day_range), 'xticklabel', num2str(day_range'));
title('calm');