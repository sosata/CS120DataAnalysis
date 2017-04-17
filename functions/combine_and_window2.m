% This function only combines second columns in the input data and returns them
% each cell in input/output data is one source (e.g., activity, location)
% input data can be cell or table
% output data is cell

function data_out = combine_and_window2(data_in, window_size)

% skip if input data vector is empty
if isempty(data_in),
    data_out = [];
    return;
end

if ~isstruct(data_in),
    error('input must be a structure');
end

probes = fieldnames(data_in);

% if a probe is completely empty, output [] and remove probe from further processing
% ind_remove = [];
% for i = 1:length(probes),
%     if size(data_in.(probes{i}),1)==0,
%         data_out.(probes{i}) = [];
%         ind_remove = [ind_remove, i];
%     end
% end
% probes(ind_remove) = [];

% windowing
t_min = Inf;
for i = 1:length(probes),
    if ~isempty(data_in.(probes{i}))
        if t_min>data_in.(probes{i}).Var1(1),
            t_min = data_in.(probes{i}).Var1(1);
        end
    end
end

t_max = -Inf;
for i = 1:length(probes),
    if ~isempty(data_in.(probes{i}))
        if t_max<data_in.(probes{i}).Var1(end),
            t_max = data_in.(probes{i}).Var1(end);
        end
    end
end

% t_max<t_min means there is no data
if t_max<t_min,
    data_out = [];
    return;
end

t = t_min;
cnt = 1;
while t <= t_max,
    for i = 1:length(probes),
        if isempty(data_in.(probes{i})),
            data_out.(probes{i}){cnt} = [];
        else
            inds = find((data_in.(probes{i}).Var1>=t)&(data_in.(probes{i}).Var1<t+window_size));
            if isempty(inds),
                data_out.(probes{i}){cnt} = [];
            else
                data_out.(probes{i}){cnt} = data_in.(probes{i})(inds,:);
            end
        end
    end
    cnt = cnt+1;
    t = t+window_size;
end

% if ~exist('data_out','var')
%     data_out = [];
% end

% for i = 1:length(probes),
%     if ~exist(sprintf('data_out.%s',probes{i}),'var')
%         data_out.(probes{i}){cnt} = [];
%     end
% end


end