function [feature, feature_label] = extract_features_communication(data)

feature_label = {'call in','call out','call miss','call diff','sms in','sms out','sms diff','resp time',...
    'call miss ratio','call in circ','call out circ','sms in circ','sms out circ','late communication', ...
    'contact ent', 'contact norm ent'};

if isempty(data),
    feature = NaN*ones(1,length(feature_label));
    return;
end

if isempty(data.Var1),
    feature = NaN*ones(1,length(feature_label));
    return;
end

time = data.Var1;

% Phone features
phone_in = sum(strcmp(data.Var4,'PHONE')&strcmp(data.Var5,'INCOMING'));
phone_out = sum(strcmp(data.Var4,'PHONE')&strcmp(data.Var5,'OUTGOING'));
phone_miss = sum(strcmp(data.Var4,'PHONE')&strcmp(data.Var5,'MISSED'));
phone_diff = phone_in + phone_miss - phone_out;
if phone_in~=0,
    phone_miss_ratio = phone_miss/phone_in;
else
    phone_miss_ratio = NaN;
end

% SMS features
sms_in = sum(strcmp(data.Var4,'SMS')&strcmp(data.Var5,'INCOMING'));
sms_out = sum(strcmp(data.Var4,'SMS')&strcmp(data.Var5,'OUTGOING'));
sms_diff = sms_in - sms_out;

% SMS Response time
%TODO: needs to be optimized
if sms_in==0||sms_out==0,
    t_resp = NaN;
else
    sms = find(strcmp(data.Var4,'SMS'));
%     for i=1:length(data),
%         data_sms{i} = data{i}(sms);
%     end
    data_sms = data(sms,:);
    out = find(strcmp(data_sms.Var5,'OUTGOING'));
    if out(1)==1,
        out(1) = [];
    end
    cnt = 0;
    t_resp = 0;
    for i = out',
        if strcmp(data_sms.Var5(i-1),'INCOMING'),
            t_resp = t_resp + data_sms.Var1(i) - data_sms.Var1(i-1);
            cnt = cnt+1;
        end
    end
    if cnt~=0,
        t_resp = t_resp/cnt;
    else
        t_resp = NaN;
    end
end

% circadian rhythms
circ_call_in = estimate_circadian_rhythmicity(time(strcmp(data.Var4,'PHONE')&strcmp(data.Var5,'INCOMING')), 86400);
circ_call_out = estimate_circadian_rhythmicity(time(strcmp(data.Var4,'PHONE')&strcmp(data.Var5,'OUTGOING')), 86400);
circ_sms_in = estimate_circadian_rhythmicity(time(strcmp(data.Var4,'SMS')&strcmp(data.Var5,'INCOMING')), 86400);
circ_sms_out = estimate_circadian_rhythmicity(time(strcmp(data.Var4,'SMS')&strcmp(data.Var5,'OUTGOING')), 86400);

% time
comm_late = sum((mod(time,86400)>18*3600)|(mod(time,86400)<3*3600))/length(time);

% contacts
contact_entropy = estimate_entropy(data.Var2);
if length(unique(data.Var2))>1,
    contact_normalized_entropy = contact_entropy/log(length(unique(data.Var2)));
else
    contact_normalized_entropy = 0;
end

feature = [phone_in,phone_out,phone_miss,phone_diff,sms_in,sms_out,sms_diff,t_resp,phone_miss_ratio, ...
    circ_call_in, circ_call_out, circ_sms_in, circ_sms_out, comm_late, contact_entropy, contact_normalized_entropy];

end