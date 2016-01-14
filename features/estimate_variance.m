function variance = estimate_variance(lat, lng)

%variance = sqrt(var(lng)^2 + var(lat)^2);

variance = log(var(lng) + var(lat));

if isinf(variance),
    variance = -100;    % approximating -Inf
end

end