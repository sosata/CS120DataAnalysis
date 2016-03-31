% This function clips data based on time_start and time_end and timestamp
% values in the first column of data.

% This function handles both table and cell data types.

function data = clip_data(data, time_start, time_end)
    
if istable(data),

    ind_start = find(data.Var1>=time_start, 1, 'first');
    ind_end = find(data.Var1<=time_end, 1, 'last');
    data = data(ind_start:ind_end, :);

elseif iscell(data),    

    ind_start = find(data{1}>=time_start, 1, 'first');
    ind_end = find(data{1}<=time_end, 1, 'last');
    for i=1:length(data),
        data{i} = data{i}(ind_start:ind_end);
    end

else
    error('data type unknown.');
end

end