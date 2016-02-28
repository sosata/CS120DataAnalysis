function [labs, centroids] = cluster_kmeans(lat, lng, n_init, distance_max)

distances_mean_max = distance_max;
n = n_init;
while distances_mean_max>=distance_max,
    [labs, centroids, ~, ~] = kmeans([lng, lat], n, 'emptyaction', 'singleton', 'start', 'plus', 'distance', 'sqeuclidean', 'MaxIter', 1000);
    distance_cluster_max = zeros(size(centroids,1),1);
    for i = 1:size(centroids,1),
        distance_cluster_max(i) = max(sqrt(sum((ones(length(lng(labs==i)),1)*centroids(i,:)-[lng(labs==i),lat(labs==i)]).^2,2)));
    end
    distances_mean_max = max(distance_cluster_max);
    n = n+1;
end
