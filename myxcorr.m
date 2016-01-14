% Note: t1 and t2 should have matching values

function y = myxcorr(t1, x1, t2, x2, numlags)

if isempty(t1)||isempty(t2)||isempty(x1)||isempty(x2),
    error('myxcorr: empty input');
end

% subtracting the means
x1 = x1 - mean(x1);
x2 = x2 - mean(x2);

% zero padding missing values in x1
x1_new = [];
for t=t1(1):86400:t1(end),
    ind = find(ismember(t1,t));
    if ~isempty(ind),
        x1_new = [x1_new; x1(ind)];
    else
        x1_new = [x1_new; 0];%zeros(1,size(x1,2))];
    end
end
t1 = t1(1):86400:t1(end);

% zero padding missing values in x2
x2_new = [];
for t=t2(1):86400:t2(end),
    ind = find(ismember(t2, t));
    if ~isempty(ind),
        x2_new = [x2_new; x2(ind)];
    else
        x2_new = [x2_new; 0];%zeros(1,size(x2,2))];
    end
end
t2=t2(1):86400:t2(end);

% calculating cross-correlation
cnt = 1;
y = zeros(2*numlags+1,1);
for lag = -numlags:numlags,
    t2_lagged = t2 + lag*86400;
    for i = 1:length(t1),
        ind = find(t2_lagged==t1(i));
        if ~isempty(ind),
            y(cnt) = y(cnt) + x1_new(i)*x2_new(ind);
        end
    end
    cnt = cnt+1;
end
if (std(x1)~=0)&&(std(x2)~=0),
    y = y/min(length(x1),length(x2))/std(x1)/std(x2);
else
    y = 0*y;
end

end