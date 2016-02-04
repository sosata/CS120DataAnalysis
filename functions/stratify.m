function [x_out, target_out] = stratify(x, target)

target_u = unique(target);
if length(target_u)~=2,
    error('There must be 2 target stares.');
end

n_class = max(sum(target==target_u(1)),sum(target==target_u(2)));

x_out = [];
target_out = [];
for i=1:2,
    ind = find(target==target_u(i));
    if length(ind)>=n_class,
        ind_out = randsample(ind, n_class, false); % no replacement
    else
        ind_out = randsample(ind, n_class, true); % replacement
    end
    x_out = [x_out; x(ind_out, :)];
    target_out = [target_out; target(ind_out)];
    
end