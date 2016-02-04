function [labs, centroids] = cluster_kmeans(lat, lng, n_init, distance_max)

distances_mean_max = distance_max;
n = n_init;
while distances_mean_max>=distance_max,
    [labs, centroids, error, ~] = kmeans([lng, lat], n, 'emptyaction', 'singleton', 'start', 'plus', 'distance', 'sqeuclidean', 'MaxIter', 1000);
    kmeans_frequency = zeros(max(labs),1);
    for j=1:length(labs),
        kmeans_frequency(labs(j)) = kmeans_frequency(labs(j)) + 1;
    end
    distances_mean = error./kmeans_frequency;
    distances_mean_max = max(distances_mean);
    n = n+1;
end
