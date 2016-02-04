function y = cat2num(x)

x_u = unique(x);

y = zeros(length(x), 1);
for i=1:length(x),
    y(i) = find(x_u==x(i));
end
    

end