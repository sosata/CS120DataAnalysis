clear;
close all;

load('features_biweekly');
addpath('functions');

num_weeks = 6;%median(cellfun(@(x) size(x,1), feature));

for w = 1:num_weeks,
   
    ft = [];
    for s = 1:length(feature),
        if size(feature{s},1)>=w,
            ft = [ft; feature{s}(w,:)];
        end
    end
%     ft = zscore(ft);
    
    r{w} = zeros(size(ft,2),size(ft,2));
    for i=1:size(ft,2),
        for j=1:size(ft,2),
            r{w}(i,j) = mycorr(ft(:,i), ft(:,j));
        end
    end
    
    h=figure;
    set(h,'position',[553    94   400   400]);
    imagesc(r{w});
    set(gca, 'ytick', 1:length(feature_label), 'yticklabel', feature_label);
    my_xticklabels(1:length(feature_label), feature_label, 'rotation', -45, 'horizontalalignment', 'right');
    colorbar;
    
end