function y = myzscore(x)

y = zeros(size(x));

for i=1:size(x,2),
    
    y(:,i) = (x(:,i)-nanmean(x(:,i)))/nanstd(x(:,i));
    
end
    
end