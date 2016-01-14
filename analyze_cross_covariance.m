clear;
close all;

load('features_ema.mat');

lag_range = -20:20; % days
correlation_type = 'spearman';

t_start = floor(min(cellfun(@(x) x(1), time))/86400)*86400;
t_end = floor(max(cellfun(@(x) x(end), time))/86400)*86400;

for t = t_start:86400:t_end,
    
    for i = 1:length(time),
        
        feature_days = 
        
    end
    
end
