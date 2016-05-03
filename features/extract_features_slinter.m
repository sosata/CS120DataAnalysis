% sleep interruption features

function [feature, feature_label] = extract_features_slinter(data)

feature_label = {'slinter nonstill','slinter aud amp','slinter aud frq','slinter aud amp var','slinter aud frq var','slinter aud highfreq','slinter aud amp event','slinter aud frq event',...
    'slinter light mean','slinter light var','slinter light event','slinter scr mean','slinter scr var'};

if isempty(data.ems),
    feature = NaN*ones(1,length(feature_label));
    return;
end

if isempty(data.ems.Var1),
    feature = NaN*ones(1,length(feature_label));
    return;
end

% there are cases with negative timestamp values
ind_neg = find(data.ems.Var2<0);
ind_neg = union(ind_neg,find(data.ems.Var3<0));
ind_neg = union(ind_neg,find(data.ems.Var4<0));
ind_neg = union(ind_neg,find(data.ems.Var5<0));
if ~isempty(ind_neg),
    disp(sprintf('Sleep: %d/%d datapoints removed because of negative time values.\n',length(ind_neg),length(data.ems.Var1)));
    data.ems(ind_neg,:) = [];
end

% timestamps are in ms
t_bed = data.ems.Var2/1000;
t_sleep = data.ems.Var3/1000;
t_wake = data.ems.Var4/1000;
t_getup = data.ems.Var5/1000;

% activity-related
if ~isempty(data.act),
    data_midsleep = [];
    for i=1:length(t_sleep),
        datac = clip_data(data.act, t_sleep(i)+(t_wake(i)-t_sleep(i))/10, t_wake(i)-(t_wake(i)-t_sleep(i))/10);
        data_midsleep = [data_midsleep; datac.Var2];
    end
    act_nonstill = 1 - sum(ismember(data_midsleep, 'STILL'))/length(data_midsleep);
else
    act_nonstill = 0;
end

% sound-related
if ~isempty(data.aud),
    data_amp = [];
    data_frq = [];
    data_amp_event = [];
    data_frq_event = [];
    for i=1:length(t_sleep),
        datac = clip_data(data.aud, t_sleep(i)+(t_wake(i)-t_sleep(i))/10, t_wake(i)-(t_wake(i)-t_sleep(i))/10);
        data_amp = [data_amp; datac.Var2];
        data_frq = [data_frq; datac.Var3];
        data_amp_diff = diff(datac.Var2(~isnan(datac.Var2)));   % assuming regular sampling rate
        data_frq_diff = diff(datac.Var3(~isnan(datac.Var3)));   % assuming regular sampling rate
        data_amp_event = [data_amp_event; sum(abs(data_amp_diff)>(median(data_amp_diff)+3*std(data_amp_diff)))];
        data_frq_event = [data_frq_event; sum(abs(data_frq_diff)>(median(data_frq_diff)+3*std(data_frq_diff)))];
    end
    aud_amp_mean = nanmean(data_amp);
    aud_frq_mean = nanmean(data_frq);
    aud_amp_var = nanvar(data_amp);
    aud_frq_var = nanvar(data_frq);
    aud_high_frq = sum(data_frq>200)/length(data_frq);
    aud_amp_event = sum(data_amp_event);
    aud_frq_event = sum(data_frq_event);
else
    aud_amp_mean = NaN;
    aud_frq_mean = NaN;
    aud_amp_var = NaN;
    aud_frq_var = NaN;
    aud_high_frq = NaN;
    aud_amp_event = NaN;
    aud_frq_event = NaN;
end

% light-related
if ~isempty(data.lgt),
    data_amp = [];
    data_event = [];
    for i=1:length(t_sleep),
        datac = clip_data(data.lgt, t_sleep(i)+(t_wake(i)-t_sleep(i))/10, t_wake(i)-(t_wake(i)-t_sleep(i))/10);
        data_amp = [data_amp; datac.Var2];
        data_diff = diff(datac.Var2(~isnan(datac.Var2)));   % assuming regular sampling rate
        data_event = [data_event; sum(abs(data_diff)>(median(data_diff)+3*std(data_diff)))];
    end
    lgt_mean = nanmean(data_amp);
    lgt_var = nanvar(data_amp);
    lgt_event = sum(data_event);
else
    lgt_mean = NaN;
    lgt_var = NaN;
    lgt_event = NaN;
end

% screen-related
if ~isempty(data.scr),
    num_scr = [];
    for i=1:length(t_sleep),
        datac = clip_data(data.scr, t_sleep(i)+(t_wake(i)-t_sleep(i))/10, t_wake(i)-(t_wake(i)-t_sleep(i))/10);
        num_scr = [num_scr; length(datac.Var2)];
    end
    scr_mean = nanmean(num_scr);
    scr_var = nanvar(num_scr);
else
    scr_mean = NaN;
    scr_var = NaN;
end


feature = [act_nonstill, aud_amp_mean, aud_frq_mean, aud_amp_var, aud_frq_var, aud_high_frq, aud_amp_event, aud_frq_event...
    lgt_mean, lgt_var, lgt_event, scr_mean, scr_var];

end