function [ind_feature, R2] = feature_selection(feature, target, regressor, n_pass)

alpha_add = 1.1;
alpha_remove = 0.9;

ind_feature = [];
R2 = -Inf;
for p = 1:n_pass,
    fprintf('pass #%d\n',p);
%     R2 = regressor(feature(:,ind_feature), target);
    fprintf('R2: %.3f (%.3f)\n', mean(R2), std(R2)/sqrt(length(R2)));
    fprintf('add...\n');
    ind_feature_out = 1:size(feature,2);
    ind_feature_out(ind_feature) = [];
    for i=ind_feature_out,
        R2_new = regressor(feature(:,[ind_feature; i]), target);
        if mean(R2_new)>alpha_add*mean(R2),
            ind_feature = [ind_feature; i];
            R2 = R2_new;
            fprintf('New R2: %.3f (%.3f)\n', mean(R2), std(R2)/sqrt(length(R2)));
            fprintf('% d', ind_feature);
            fprintf('\n');
        end
    end
    fprintf('remove...\n');
    for i=1:length(ind_feature),
        inds = ind_feature([1:i-1,i+1:end]);
        inds(isnan(inds)) = [];
        R2_new = regressor(feature(:,inds), target);
        if mean(R2_new)>alpha_remove*mean(R2),
            ind_feature(i) = nan;
            R2 = R2_new;
            fprintf('New R2: %.3f (%.3f)\n', mean(R2), std(R2)/sqrt(length(R2)));
            fprintf('% d', ind_feature(~isnan(ind_feature)));
            fprintf('\n');
        end
    end
    ind_feature(isnan(ind_feature)) = [];
end

end