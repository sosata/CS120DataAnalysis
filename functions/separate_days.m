% This function breaks data into separate days.
% Data must be in table format.
% The first column is Unix timestamps in ascending order, and the rest are
% attribute values.

function [out, jour, stats] = separate_days(data, extract_stats)

% if ~istable(data),
%     error('Data must be in table format.');
% end

if iscell(data),
    time = data{1};
else
    time = data.Var1;
end

if isempty(time),
    error('Table contains no data');
end

sd = 86400; % seconds in a day

if iscell(data),
    date_start = floor(data{1}(1)/sd);
    date_end = floor(data{1}(end)/sd);
else
    date_start = floor(data.Var1(1)/sd);
    date_end = floor(data.Var1(end)/sd);
end
jour = date_start:date_end;

out = cell(length(jour),1);
stats.samplingduration = NaN*ones(length(jour),1);
stats.maxgap = NaN*ones(length(jour),1);

cnt = 0;
for d = jour,
    
    cnt = cnt+1;
    %out.date{cnt} = datestr(d + datenum(1970,1,1), 6);
    ind_rng = find(time>=d*sd,1,'first'):find(time<=(d+1)*sd,1,'last');
    
    if ~isempty(ind_rng)
        
        if iscell(data),
            for i=1:length(data),
                out{cnt}{i} = data{i}(ind_rng);
            end
        else
            out{cnt} = data(ind_rng, :);
        end
        
        if extract_stats,
            stats.samplingduration(cnt) = sd/length(ind_rng);
            stats.maxgap(cnt) = max(diff([d*sd;time(ind_rng);(d+1)*sd]));
        end
        
    else
        
        out{cnt} = [];
        stats.samplingduration(cnt) = NaN;
        stats.maxgap(cnt) = NaN;
        
    end
end

end