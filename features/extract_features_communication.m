function [feature, feature_label] = extract_features_communication(data)

feature_label = {'call in','call out','call miss','call diff','sms in','sms out','sms diff','resp time'};

if isempty(data),
    feature = NaN*ones(1,length(feature_label));
    return;
end

if isempty(data{1}),
    feature = NaN*ones(1,length(feature_label));
    return;
end

% Phone features
phone_in = sum(strcmp(data{4},'PHONE')&strcmp(data{5},'INCOMING'));
phone_out = sum(strcmp(data{4},'PHONE')&strcmp(data{5},'OUTGOING'));
phone_miss = sum(strcmp(data{4},'PHONE')&strcmp(data{5},'MISSED'));
phone_diff = phone_in + phone_miss - phone_out;

% SMS features
sms_in = sum(strcmp(data{4},'SMS')&strcmp(data{5},'INCOMING'));
sms_out = sum(strcmp(data{4},'SMS')&strcmp(data{5},'OUTGOING'));
sms_diff = sms_in - sms_out;

% Response time
%TODO: needs to be optimized
if sms_in==0||sms_out==0,
    t_resp = NaN;
else
    sms = find(strcmp(data{4},'SMS'));
    for i=1:length(data),
        data_sms{i} = data{i}(sms);
    end
    out = find(strcmp(data_sms{5},'OUTGOING'));
    if out(1)==1,
        out(1) = [];
    end
    cnt = 0;
    t_resp = 0;
    for i = out',
        if strcmp(data_sms{5}(i-1),'INCOMING'),
            t_resp = t_resp + data_sms{1}(i) - data_sms{1}(i-1);
            cnt = cnt+1;
        end
    end
    if cnt~=0,
        t_resp = t_resp/cnt;
    else
        t_resp = NaN;
    end
end

feature = [phone_in,phone_out,phone_miss,phone_diff,sms_in,sms_out,sms_diff,t_resp];

end