% This function only combines second columns in the input data and returns them
% each cell in input/output data is one source (e.g., activity, location)
% input data can be cell or table
% output data is cell

function data_out = combine_and_window2(data_in, t_start, t_end, window_size)

% skip if input data vector is empty
if isempty(data_in),
    data_out = [];
    return;
end

if ~isstruct(data_in),
    error('input must be a structure');
end

probes = fieldnames(data_in);

n_windows = ceil((t_end - t_start) / window_size);

for i = 1:length(probes)
    if isempty(data_in.(probes{i}))
        window_idx.(probes{i}) = NaN;
    else
        window_idx.(probes{i}) = ...
            ceil((data_in.(probes{i}).Var1 - t_start) / window_size);
    end
end

for ct = 1:n_windows
    for i = 1:length(probes)
        if isempty(data_in.(probes{i}))
            data_out.(probes{i}){ct} = [];
        else
            inds = find(window_idx.(probes{i}) == ct);
            if isempty(inds)
                data_out.(probes{i}){ct} = [];
            else
                data_out.(probes{i}){ct} = data_in.(probes{i})(inds,:);
            end
        end
    end
end


% t = t_start;
% cnt = 1;
% while t <= t_end,
%     for i = 1:length(probes),
%         if isempty(data_in.(probes{i})),
%             data_out.(probes{i}){cnt} = [];
%         else
%             log_inds = (data_in.(probes{i}).Var1>=t)&(data_in.(probes{i}).Var1<t+window_size);
%             inds = find(log_inds);
%             if isempty(inds),
%                 data_out.(probes{i}){cnt} = [];
%             else
%                 data_out.(probes{i}){cnt} = data_in.(probes{i})(inds,:);
%             end
%         end
%     end
%     cnt = cnt+1;
%     t = t+window_size;
% end

% if ~exist('data_out','var')
%     data_out = [];
% end

% for i = 1:length(probes),
%     if ~exist(sprintf('data_out.%s',probes{i}),'var')
%         data_out.(probes{i}){cnt} = [];
%     end
% end


end