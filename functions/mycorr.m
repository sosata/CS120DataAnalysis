% A version of correlation function that can handle missing (NaN) values

function r = mycorr(x,y,type)

if strcmp(type, 'pearson'),
    
    x = x - nanmean(x);
    y = y - nanmean(y);

    r = nanmean(x.*y)/nanstd(x)/nanstd(y);

elseif strcmp(type, 'spearman'),
    
    indnanx = find(isnan(x));
    indnany = find(isnan(y));
    
    x(union(indnanx, indnany)) = [];
    y(union(indnanx, indnany)) = [];
    
    r = corr(x,y,'type','spearman');
    
else
    
    error(['correlation type ',type,' is unknown.']);
    
end

end