function ent = estimate_entropy(lab)

ent = 0;

labs = unique(lab);

if iscell(lab),
    for i=1:length(labs),
        p = sum(strcmp(lab,labs{i}))/length(lab);
        ent = ent - p*log(p);
    end
else
    for i=labs',
        p = sum(lab==i)/length(lab);
        ent = ent - p*log(p);
    end
end

end