function [n_clusters, labs] = estimate_clusters(lat, lng, kmeans_distance_max, n_kmeans_init)


if length(lat)==1,
    n_clusters = 1;
    labs = 1;
else
    distances_mean_max = kmeans_distance_max;
    n = n_kmeans_init;
    while distances_mean_max>=kmeans_distance_max,
        [labs, ~, error, ~] = kmeans([lng, lat], n, 'emptyaction', 'singleton', 'start', 'plus', 'distance', 'sqeuclidean', 'MaxIter', 1000);
        kmeans_frequency = zeros(max(labs),1);
        for i=1:length(labs),
            kmeans_frequency(labs(i)) = kmeans_frequency(labs(i)) + 1;
        end
        distances_mean = error./kmeans_frequency;
        distances_mean_max = max(distances_mean);
        n = n+1;
    end
    n_clusters = length(unique(labs));
end


end