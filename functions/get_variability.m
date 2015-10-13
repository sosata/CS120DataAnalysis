function y = get_variability(x)

if iscategorical(x),
    
    cats = categories(x);
    xx = zeros(1,length(x));
    for i=1:length(x),
        xx(i) = find(cats==x(i));
    end
    x = xx;
    
end

if length(unique(x))>1,
    x = x/max(abs(x));
    y = entropy(x)/log(length(unique(x)));
else
    y = 0;
end

end