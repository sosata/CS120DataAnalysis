function homestay = estimate_homestay(time, labs)

% finding the first 3 clusters

cluster1 = mode(labs);
hours1 = mod(time(labs==cluster1),86400)/3600;

labs2 = labs(labs~=cluster1);
time2 = time(labs~=cluster1);
cluster2 = mode(labs2);
hours2 = mod(time2(labs2==cluster2),86400)/3600;

labs3 = labs2(labs2~=cluster2);
time3 = time2(labs2~=cluster2);
cluster3 = mode(labs3);
hours3 = mod(time3(labs3==cluster3),86400)/3600;

% finding which cluster is mostly visited between 12am-6am

hours1 = hours1(hours1<=6);
hours2 = hours2(hours2<=6);
hours3 = hours3(hours3<=6);

[~, cluster_home] = max([length(hours1) length(hours2) length(hours3)]);

if cluster_home==1,
    homestay = sum(labs==cluster1)/length(labs);
elseif cluster_home==2,
    homestay = sum(labs==cluster2)/length(labs);
elseif cluster_home==3,
    homestay = sum(labs==cluster3)/length(labs);
end

end