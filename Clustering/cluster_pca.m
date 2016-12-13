clear;
close all;

addpath('../functions/');

% number of groups defined based on mean affect
nbins = 2;

load('../General/features_biweekly');

feature_all = [];
for i=1:length(feature),
    feature_all = [feature_all; feature{i}];
end

% removing EMA features
% affect_all = nanmean(feature_all(:,[45:48, 60]),2);
affect_all = feature_all(:,11);
feature_all = feature_all(:,1:44);
feature_label = feature_label(1:44);

% inverting the sign of variables whose correlation is mostly negative
feature_all(:,8) = -feature_all(:,8);

% removing rows containing missing values
ind_nan = find(any(isnan(feature_all),2)|isnan(affect_all));
feature_all(ind_nan,:) = [];
affect_all(ind_nan) = [];

ind{1} = find(affect_all<=prctile(affect_all, 100/nbins));
for i=2:nbins,
    ind{i} = find((affect_all>prctile(affect_all, 100/nbins*(i-1)))&(affect_all<=prctile(affect_all, 100/nbins*i)));
end

labs = zeros(size(feature_all,1),1);
for i=1:length(ind),
    labs(ind{i}) = i;
end

imagesc(cov(myzscore(feature_all)));
set(gca, 'ytick', 1:length(feature_label), 'yticklabel', feature_label);

% [~, pca_scores] = pca(myzscore(feature_all), 'algorithm', 'als');
[~, pca_scores] = pca(myzscore(feature_all));
features_low = pca_scores(:, 1:3);

% coefs = factoran(feature_all, 2);
% features_low = myzscore(feature_all)*coefs;

figure;
hold on;
colors = jet(nbins);
for i=1:nbins,
    plot(features_low(ind{i},1),features_low(ind{i},2), '.','markersize',12,'color',colors(i,:));
    %scatter3(features_low(ind{i},1),features_low(ind{i},2), features_low(ind{i},3), 12, ones(length(ind{i}),1)*colors(i,:));
    legs{i} = sprintf('%.0f-%.0f',100/nbins*(i-1),100/nbins*i);
end
legend(legs);
xlabel('var 1');
ylabel('var 2');

figure;
features_low = tsne(feature_all, labs, 3);