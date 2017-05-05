% sleep interruption features
% NOTE: times in data.ems must already be corrected (both units and
% timezones)

function [feature, feature_label] = extract_features_slinter(data)

feature_label = {'slinter nonstill','slinter tilt','slinter bike','slinter unknown','slinter aud amp','slinter aud frq','slinter aud amp var','slinter aud frq var','slinter aud highfreq','slinter aud amp event','slinter aud frq event',...
    'slinter light mean','slinter light var','slinter light event','slinter scr mean','slinter scr var','wifi mean',...
    'slinter callin', 'slinter callout', 'slinter callmiss', 'slinter smsin', 'slinter smsout'};

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

t_bed = data.ems.Var2;
t_sleep = data.ems.Var3;
t_wake = data.ems.Var4;
t_getup = data.ems.Var5;

% activity-related
if ~isempty(data.act),
    data.act.Var2 = categorical(data.act.Var2);
    data_midsleep = [];
    for i=1:length(t_sleep),
        datac = clip_data(data.act, t_sleep(i)+(t_wake(i)-t_sleep(i))/10, t_wake(i)-(t_wake(i)-t_sleep(i))/10);
        data_midsleep = [data_midsleep; datac.Var2];
    end
    act_nonstill = 1 - sum(ismember(data_midsleep, 'STILL'))/length(data_midsleep);
    act_tilt = sum(ismember(data_midsleep, 'TILTING'))/length(data_midsleep);
    act_bike = sum(ismember(data_midsleep, 'ON_BICYCLE'))/length(data_midsleep);
    act_unknown = sum(ismember(data_midsleep, 'UNKNOWN'))/length(data_midsleep);
else
    act_nonstill = 0;
    act_tilt = 0;
    act_bike = 0;
    act_unknown = 0;
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
        data_amp_event = [data_amp_event; sum(abs(data_amp_diff)>(median(data_amp_diff)+4*std(data_amp_diff)))];
        data_frq_event = [data_frq_event; sum(abs(data_frq_diff)>(median(data_frq_diff)+4*std(data_frq_diff)))];
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
        data_event = [data_event; sum(abs(data_diff)>(median(data_diff)+4*std(data_diff)))];
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
    scr_mean = 0;
    scr_var = 0;
end

% wifi-related
if ~isempty(data.wif),
    num_wif = [];
    for i=1:length(t_sleep),
        datac = clip_data(data.wif, t_sleep(i)+(t_wake(i)-t_sleep(i))/10, t_wake(i)-(t_wake(i)-t_sleep(i))/10);
        num_wif = [num_wif; length(unique(datac.Var2))];
    end
    wif_mean = nanmean(num_wif);
else
    wif_mean = 0;
end

% communication-related
if ~isempty(data.coe),
    num_smsin = [];
    num_smsout = [];
    num_callin = [];
    num_callout = [];
    num_callmiss = [];
    for i=1:length(t_sleep),
        datac = clip_data(data.coe, t_sleep(i)+(t_wake(i)-t_sleep(i))/10, t_wake(i)-(t_wake(i)-t_sleep(i))/10);
        num_callin = [num_callin, sum(strcmp(datac.Var4,'PHONE')&strcmp(datac.Var5,'INCOMING'))];
        num_callout = [num_callout, sum(strcmp(datac.Var4,'PHONE')&strcmp(datac.Var5,'OUTGOING'))];
        num_callmiss = [num_callmiss, sum(strcmp(datac.Var4,'PHONE')&strcmp(datac.Var5,'MISSED'))];
        num_smsin = [num_smsin, sum(strcmp(datac.Var4,'SMS')&strcmp(datac.Var5,'INCOMING'))];
        num_smsout = [num_smsout, sum(strcmp(datac.Var4,'SMS')&strcmp(datac.Var5,'OUTGOING'))];
    end
    callin = mean(num_callin);
    callout = mean(num_callout);
    callmiss = mean(num_callmiss);
    smsin = mean(num_smsin);
    smsout = mean(num_smsout);
else
    callin = 0;
    callout = 0;
    callmiss = 0;
    smsin = 0;
    smsout = 0;
end


feature = [act_nonstill, act_tilt, act_bike, act_unknown, aud_amp_mean, aud_frq_mean, aud_amp_var, aud_frq_var, aud_high_frq, aud_amp_event, aud_frq_event...
    lgt_mean, lgt_var, lgt_event, scr_mean, scr_var, wif_mean, callin, callout, callmiss, smsin, smsout];

end