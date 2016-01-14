function data_wined = window_data(data, window_size)

if isempty(data{1}),
    error('No data.');
end

t = data{1}(1);
cnt = 1;
while t<=data{1}(end),
   
    ind = find((data{1}>=t)&(data{1}<t+window_size));
    if ~isempty(ind),
       
        for j=1:length(data),
            data_wined{cnt}(:,j) = data{j}(ind);
        end

        cnt = cnt+1;
    end
    t = t+window_size;
    
end

end