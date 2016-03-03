function r = mycorr(x,y)

x = x - nanmean(x);
y = y - nanmean(y);

r = nanmean(x.*y)/nanstd(x)/nanstd(y);

end