% This function only combines second columns in the input data and returns them
% each cell in input/output data is one source (e.g., activity, location)
% input data can be cell or table
% output data is cell

function data_out = combine_and_window(data_in, window_size)

if iscell(data_in{1}),
    
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
        for i = 1:length(data_in),
            data_out{cnt}{i} = data_in{i}{2}(ind{i});   %only considering the second column
        end
        cnt = cnt+1;
        t = t+window_size;
        
    end
elseif istable(data_in{1}),
    
    t_min = Inf;
    for i = 1:length(data_in),
        if t_min>data_in{i}.Var1(1),
            t_min = data_in{i}.Var1(1);
        end
    end
    t_max = -Inf;
    for i = 1:length(data_in),
        if t_max<data_in{i}.Var1(end),
            t_max = data_in{i}.Var1(end);
        end
    end
    t = t_min;
    cnt = 1;
    while t <= t_max,
        for i = 1:length(data_in),
            ind{i} = find((data_in{i}.Var1>=t)&(data_in{i}.Var1<t+window_size));
        end
        for i = 1:length(data_in),
            data_out{cnt}{i} = data_in{i}.Var2(ind{i});   %only considering the second column
        end
        cnt = cnt+1;
        t = t+window_size;
    end

    
else
    error('unknown data type');
end

end