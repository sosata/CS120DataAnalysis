function ent = estimate_entropy(lab)

ent = 0;

labs = unique(lab);

for i=labs',
    p = sum(lab==i)/length(lab);
    ent = ent - p*log(p);
end


end