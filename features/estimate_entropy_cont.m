function ent = estimate_entropy_cont(x, nbins)

n = hist(x, nbins);

ent = 0;

for i=1:nbins,
    
    if n(i)~=0,
        p = n(i)/sum(n);
        ent = ent - p*log(p);
    end
    
end

end