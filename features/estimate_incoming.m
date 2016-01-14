function f = estimate_incoming(data, option)

if strcmp(option, 'PHONE'),
    in = sum(strcmp(data{4},'PHONE')&strcmp(data{5},'INCOMING'));
    out = sum(strcmp(data{4},'PHONE')&strcmp(data{5},'OUTGOING'));
    miss = sum(strcmp(data{4},'PHONE')&strcmp(data{5},'MISSED'));
    f = in + miss - out;    
elseif strcmp(option, 'SMS'),
    in = sum(strcmp(data{4},'SMS')&strcmp(data{5},'INCOMING'));
    out = sum(strcmp(data{4},'SMS')&strcmp(data{5},'OUTGOING'));
    f = in - out;    
else
    error('Unknown option.');
end

end