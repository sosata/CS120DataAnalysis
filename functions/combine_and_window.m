function data_out = combine_and_window(data_in, window_size)

% only combines the second dimension

t_min = Inf;
for i = 1:length(data_in),
    if t_min>data_in{i}{1}(1),
        t_min = data_in{i}{1}(1);
    end
end

t_max = -Inf;
for i = 1:length(data_in),
    if t_max<data_in{i}{1}(end),
        t_max = data_in{i}{1}(end);
    end
end

t = t_min;
cnt = 1;

while t <= t_max,
    for i = 1:length(data_in),
        ind{i} = find((data_in{i}{1}>=t)&(data_in{i}{1}<t+window_size));
    end
%     if sum(cellfun(@(x) isempty(x), ind))==0,
        for i = 1:length(data_in),
%             if ~isempty(ind{i})
%             for j = 2:length(data_in{i}),
%                 data_out{cnt}{i}(:,j-1) = data_in{i}{j}(ind{i});
%             end
%             end
            data_out{cnt}{i} = data_in{i}{2}(ind{i});   %only considering the second dimension
            
            % check for nan values in numerical features
%             if sum(iscategorical(data_out{cnt}{i}))==0,
%                 if sum(isnan(data_out{cnt}{i}))>0,
%                     error('nan');
%                 end
%             end
        end
%     end
    cnt = cnt+1;
    t = t+window_size;
end

end