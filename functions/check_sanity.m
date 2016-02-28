function out = check_sanity(data)

out.min = min(data);
out.max = max(data);
out.mean = nanmean(data);
out.std = nanstd(data);
out.nans = sum(isnan(data));

end