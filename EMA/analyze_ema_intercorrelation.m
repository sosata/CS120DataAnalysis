clear;
close all;

slsh = '/';

% addpath('functions\');
load('settings.mat');

time = [];
stress = [];
mood = [];
energy = [];
focus = [];

%% reading data
cnt = 1;
for i = 1:length(subjects),
    
    % loading focus data
    filename = [data_dir, subjects{i}, slsh, 'emm.csv'];
    if ~exist(filename, 'file'),
        disp(['No EMA data for ', subjects{i}]);
    else
        data = readtable(filename, 'delimiter', '\t', 'ReadVariableNames', false);
        time{cnt} = data.Var1 + time_zone*3600;
        stress{cnt} = data.Var2;  
        mood{cnt} = data.Var3;  
        energy{cnt} = data.Var4; 
        focus{cnt} = data.Var5;  
        cnt = cnt+1;
    end
    
end

%% global correlation
stress_all = [];
mood_all = [];
energy_all = [];
focus_all = [];
for i=1:length(time),
    stress_all = [stress_all; stress{i}];
    mood_all = [mood_all; mood{i}];
    energy_all = [energy_all; energy{i}];
    focus_all = [focus_all; focus{i}];
end
[r, p] = corr(stress_all,mood_all);
fprintf('stress vs mood: %.3f (%.3f)\n', r, p);
[r, p] = corr(focus_all,mood_all);
fprintf('focus vs mood: %.3f (%.3f)\n', r, p);
[r, p] = corr(focus_all,energy_all);
fprintf('focus vs energy: %.3f (%.3f)\n', r, p);
[r, p] = corr(energy_all,mood_all);
fprintf('energy vs mood: %.3f (%.3f)\n', r, p);

%% within subject correlations
for i=1:length(time),
    [rsm(i), psm(i)] = corr(stress{i}, mood{i});
    [rmf(i), pmf(i)] = corr(mood{i}, focus{i});
    [rfe(i), pfe(i)] = corr(focus{i}, energy{i});
    [rem(i), pem(i)] = corr(energy{i}, mood{i});
end
h = figure;
hold on;
set(h, 'position', [31         220        1648         420]);
plot(rsm,'r');
plot(rmf,'b');
plot(rfe,'k');
plot(rem,'g');
legend('stress/mood','mood/focus','focus/energy','energy/mood');
plot(find(psm<.01), rsm(psm<.01),'.r','markersize',10);
plot(find(pmf<.01), rmf(pmf<.01),'.b','markersize',10);
plot(find(pfe<.01), rfe(pfe<.01),'.k','markersize',10);
plot(find(pem<.01), rem(pem<.01),'.g','markersize',10);
plot([1 length(time)],[0 0],':k');
plot([1 length(time)],[.5 .5],':k');
plot([1 length(time)],[-.5 -.5],':k');
ylim([-1 1]);
xlabel('subject #');
ylabel('r');

%% factor analysis
[lambda,psi,T] = factoran([stress_all, mood_all, energy_all, focus_all],1);
[coefs, score, latent] = pca([stress_all, mood_all, energy_all, focus_all]);
% coefs = nnmf([stress_all, mood_all, energy_all, focus_all],4);

%% plotting relationships
h = figure;
pic_sf = zeros(range(stress_all)+1, range(focus_all)+1);
pic_fm = zeros(range(focus_all)+1, range(mood_all)+1);
pic_em = zeros(range(energy_all)+1, range(mood_all)+1);
pic_sm = zeros(range(stress_all)+1, range(mood_all)+1);
for i = 1:length(stress_all),
    pic_sf(stress_all(i)+1,focus_all(i)+1) = pic_sf(stress_all(i)+1,focus_all(i)+1) + 1;
    pic_fm(focus_all(i)+1,mood_all(i)+1) = pic_fm(focus_all(i)+1,mood_all(i)+1) + 1;
    pic_em(energy_all(i)+1,mood_all(i)+1) = pic_em(energy_all(i)+1,mood_all(i)+1) + 1;
    pic_sm(stress_all(i)+1,mood_all(i)+1) = pic_sm(stress_all(i)+1,mood_all(i)+1) + 1;
end
subplot 221;
scatter_discrete(stress_all,focus_all);
xlabel('stress');
ylabel('focus');
subplot 222;
scatter_discrete(focus_all,mood_all);
xlabel('focus');
ylabel('mood');
subplot 223;
scatter_discrete(energy_all,mood_all);
xlabel('energy');
ylabel('mood');
subplot 224;
scatter_discrete(stress_all,mood_all);
xlabel('stress');
ylabel('mood');

