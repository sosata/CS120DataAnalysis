% This function breaks data into separate days.
% The first cell is assumed to contain Unix timestamps in ascending order.
% attribute: The dimention (attribute) to be extracted

function out = separate_days(data, dim, date_start, date_end)

if length(data)<2,
    error('Data format incorrect.');
end

time = data{1};
value = data{dim+1};
clear data;

if isempty(time)||isempty(value),
    error('Data contains no values in dimension #%d',dim);
end

sd = 86400; % seconds in a day

out.day = date_start:date_end;

cnt = 0;
for d=out.day,
    cnt = cnt+1;
    out.date{cnt} = datestr(d + datenum(1970,1,1), 6);
    ind_rng = find(time>=d*sd,1,'first'):find(time<=(d+1)*sd,1,'last');
    if ~isempty(ind_rng)
        out.timestamp{cnt} = time(ind_rng);
        out.timeofday{cnt} = mod(time(ind_rng),sd);
        out.value{cnt} = value(ind_rng);
        if iscategorical(value),
            out.samplingduration(cnt) = sd/length(ind_rng);
        else
            out.samplingduration(cnt) = sd/sum(~isnan(value(ind_rng)));
        end
        if length(ind_rng)>1,
            out.maxgap(cnt) = max(diff([d*sd;time(ind_rng);(d+1)*sd]));
        else
            out.maxgap(cnt) = 0;
        end
    else
        out.timestamp{cnt} = [];
        out.timeofday{cnt} = [];
        out.value{cnt} = [];
        out.samplingduration(cnt) = sd;
        out.maxgap(cnt) = sd;
    end
end

% out.original.time = time;
% out.original.value = value;

end