function t_mean = estimate_response_time(data)

t_mean = 0;

sms = find(strcmp(data{4},'SMS'));
if isempty(sms),
    return;
end

for i=1:length(data),
    data{i} = data{i}(sms);
end

out = find(strcmp(data{5},'OUTGOING'));
if isempty(out),
    return;
end

if out(1)==1,
    out(1) = [];
end

cnt = 0;
for i = out',
    if strcmp(data{5}(i-1),'INCOMING'),
        t_mean = t_mean + data{1}(i) - data{1}(i-1);
        cnt = cnt+1;
    end
end

if cnt~=0,
    t_mean = t_mean/cnt;
end

% t_mean

end