clear;
close all;

window_size = Inf;
shift_size = Inf;

save_vars = true;

load('ema.mat');
load('ems.mat');
load('eml.mat');
load('phq9.mat');

%% finding common ground
cnt = 1;
for i=1:length(subject_phq9),

    ind = find(strcmp(subject_ema, subject_phq9{i}));
    if ~isempty(ind),
        if length(time_ema{ind})<30,
            continue;
        end
        calm_new{cnt} = calm{ind};
        energy_new{cnt} = energy{ind};
        focus_new{cnt} = focus{ind};
        mood_new{cnt} = mood{ind};
        time_ema_new{cnt} = time_ema{ind};
    else
        continue;
    end
    
    ind = find(strcmp(subject_ems, subject_phq9{i}));
    if ~isempty(ind),
        if length(time_ems{ind})<30,
            continue;
        end
        sleep_duration_new{cnt} = sleep_duration{ind};
        bed_duration_new{cnt} = bed_duration{ind};
        sleep_quality_new{cnt} = sleep_quality{ind};
        sleep_time_new{cnt} = sleep_time{ind};
        wake_time_new{cnt} = wake_time{ind};
        time_ems_new{cnt} = time_ems{ind};
    else
        continue;
    end
    
    ind = find(strcmp(subject_eml, subject_phq9{i}));
    if ~isempty(ind),
        if length(time_eml{ind})<30,
            continue;
        end
        accomplishment_new{cnt} = accomplishment{ind};
        pleasure_new{cnt} = pleasure{ind};
        time_eml_new{cnt} = time_eml{ind};
    else
        continue;
    end

    subject_phq9_new{cnt} = subject_phq9{i};
    phq9_new.w0(cnt,1) = phq9.w0(i);
    phq9_new.w3(cnt,1) = phq9.w3(i);
    phq9_new.w6(cnt,1) = phq9.w6(i);
    
    cnt = cnt+1;
end

subject_phq9_ema = subject_phq9_new;
phq9 = phq9_new;

mood = mood_new;
energy = energy_new;
focus = focus_new;
calm = calm_new;
sleep_time = sleep_time_new;
wake_time = wake_time_new;
sleep_duration = sleep_duration_new;
bed_duration = bed_duration_new;
sleep_quality = sleep_quality_new;
accomplishment = accomplishment_new;
pleasure = pleasure_new;

time_ema = time_ema_new;
time_ems = time_ems_new;
time_eml = time_eml_new;


%% extracting stats of variables

[mood_mean, mood_var] = get_moving_stats(mood, window_size, shift_size);
[focus_mean, focus_var] = get_moving_stats(focus, window_size, shift_size);
[energy_mean, energy_var] = get_moving_stats(energy, window_size, shift_size);
[calm_mean, calm_var] = get_moving_stats(calm, window_size, shift_size);
[sleep_duration_mean, sleep_duration_var] = get_moving_stats(sleep_duration, window_size, shift_size);
[bed_duration_mean, bed_duration_var] = get_moving_stats(bed_duration, window_size, shift_size);
[sleep_time_mean, sleep_time_var] = get_moving_stats(sleep_time, window_size, shift_size);
[wake_time_mean, wake_time_var] = get_moving_stats(wake_time, window_size, shift_size);
[sleep_quality_mean, sleep_quality_var] = get_moving_stats(sleep_quality, window_size, shift_size);
[pleasure_mean, pleasure_var] = get_moving_stats(pleasure, window_size, shift_size);
[accomplishment_mean, accomplishment_var] = get_moving_stats(accomplishment, window_size, shift_size);

%% final variables

vars = {mood_mean, mood_var, energy_mean, energy_var, focus_mean, focus_var, calm_mean, calm_var, sleep_time_mean, sleep_time_var, wake_time_mean, wake_time_var, sleep_duration_mean, sleep_duration_var, bed_duration_mean, bed_duration_var, sleep_quality_mean, sleep_quality_var, accomplishment_mean, accomplishment_var, pleasure_mean, pleasure_var};
var_labels = {'mood mean','mood var','energy mean', 'energy var', 'focus mean', 'focus var', 'calm mean', 'calm var', 'sleep time mean', 'sleep time var', 'wake time mean', 'wake time var', 'sleep duration mean', 'sleep duration var', 'bed duration mean', 'bed duration var', 'sleep quality mean', 'sleep quality var', 'accomplishment mean', 'accomplishment var', 'pleasure mean', 'pleasure var'};

if save_vars,
    save('vars_ema.mat', 'vars', 'var_labels', 'subject_phq9_ema');
end
% for permutation test
% phq9.w0 = randsample(phq9.w0, length(phq9.w0));
% phq9.w3 = randsample(phq9.w3, length(phq9.w3));
% phq9.w6 = randsample(phq9.w6, length(phq9.w6));

days_min = min(cellfun(@(x) length(x), mood_mean));
days_min = min(days_min, min(cellfun(@(x) length(x), pleasure_mean)));
days_min = min(days_min, min(cellfun(@(x) length(x), sleep_duration_mean)));

r_0w = zeros(length(vars), days_min);
p_0w = zeros(length(vars), days_min);
r_3w = zeros(length(vars), days_min);
p_3w = zeros(length(vars), days_min);
r_6w = zeros(length(vars), days_min);
p_6w = zeros(length(vars), days_min);

for j=1:days_min,
    for v = 1:length(vars),
        var_temp = [];
        for k = 1:length(phq9.w0),
            var_temp = [var_temp; vars{v}{k}(j)];
        end
        var_all(:,v) = var_temp;
        % single variable analysis
        [r_0w(v,j),p_0w(v,j)] = corr(var_temp, phq9.w0);
        [r_3w(v,j),p_3w(v,j)] = corr(var_temp, phq9.w3);
        [r_6w(v,j),p_6w(v,j)] = corr(var_temp, phq9.w6);
    end
    
    cnt = 1;
    for i = [0 3 6],
        % multiple linear regressions
        mdl = fitlm(zscore(var_all), zscore(phq9.(sprintf('w%d',i))));%, 'VarNames', [var_labels, 'PHQ-9'])
        R2(cnt) = mdl.Rsquared.Adjusted;
        MSE(cnt) = mdl.MSE;
        % multiple logistic regressions
        cl = (phq9.(sprintf('w%d',i))>=10);
        [B, fitinfo] = lassoglm(zscore(var_all), cl, 'binomial', 'alpha', .5, 'Lambda', .01);
        phq_pred = logsig(zscore(var_all)*B + fitinfo.Intercept);
        cnt2 = 1;
        for phq_th = 0:.05:1,
            cl_pred = (phq_pred>=phq_th);
            sensitivity(cnt2) = sum(cl_pred(cl==1)==1)/sum(cl==1);
            specificity(cnt2) = sum(cl_pred(cl==0)==0)/sum(cl==0);
            cnt2 = cnt2+1;
        end
        auc(cnt) = abs(trapz(1-specificity, sensitivity));
        
        cnt = cnt+1;
    end

end
% figure;
% plot(1-specificity, sensitivity, '.', 'markersize', 10);
% ylabel('sensitivity');
% xlabel('1 - specificity');
% xlim([0 1]);
% ylim([0 1]);
% title(sprintf('AUC: %.3f',auc(end)));

for i=[0 3 6],
   
    eval(sprintf('r = r_%dw;',i));
    eval(sprintf('p = p_%dw;',i));
    
    figure;
    imagesc(r, [-1 1]);
    set(gca, 'ydir', 'normal');
    set(gca, 'ytick', 1:length(var_labels), 'yticklabel', var_labels);
    colorbar;
    xlabel('week #');
    ylabel(sprintf('week %d', i));
    title('r');
    
    [indx, indy] = find(p<.05);
    hold on;
    for j=1:length(indx),
        plot(indy(j), indx(j), '.k', 'markersize', 10);
    end
    
    
end

