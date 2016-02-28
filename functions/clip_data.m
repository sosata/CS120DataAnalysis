function data = clip_data(data, time_start, time_end)
    
    ind_start = find(data{1}>=time_start, 1, 'first');
    ind_end = find(data{1}<=time_end, 1, 'last');

    for i=1:length(data),
        data{i} = data{i}(ind_start:ind_end);
    end

end