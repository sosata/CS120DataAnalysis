function [x_mean, x_var] = get_moving_stats(x, n, m)

for i = 1:length(x)
    cnt = 1;
    for j = 1:m:length(x{i})
       x_mean{i}(cnt) = mean(x{i}(j:min(end,j+n-1)));
       x_var{i}(cnt) = var(x{i}(j:min(end,j+n-1)));
       cnt = cnt+1;
    end
end

end