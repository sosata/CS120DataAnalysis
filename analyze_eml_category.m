clear;
close all;

load('eml.mat');
addpath('functions');

normalize = true;

mobilyze_cats = {'Work', 'Another''s Home', 'Arts & Entertainment (Theater, Music Venue, Etc.)', ...
    'Food (Restaurant, Cafe)', 'Nightlife Spot (Bar, Club)', 'Outdoors & Recreation', 'Gym or Other Exercise', ...
    'Professional or Medical Office', 'Spiritual (Church, Temple, Etc.)', 'Shop or Store', ...
    'Travel or Transport (Airport, Bus Stop, Train Station, Etc.)', 'Vehicle', 'Other (Not Listed)'};

%% global
pleasure_all = [];
accomplishment_all = [];
cat_all = [];
name_all = [];
for i=1:length(subject_eml),
    pleasure_all = [pleasure_all; pleasure{i}];
    accomplishment_all = [accomplishment_all; accomplishment{i}];
    cat_all = [cat_all; category_mob{i}];
    name_all = [name_all; name_mob{i}];
end

% removing cetagories not in mobilyze_cats
to_be_removed = find(cellfun(@(x) sum(strcmp(mobilyze_cats, x))==0, cat_all));
name_all(to_be_removed) = [];
cat_all(to_be_removed) = [];
pleasure_all(to_be_removed) = [];
accomplishment_all(to_be_removed) = [];

subplot 211;
scatter_discrete(pleasure_all, cat_all, normalize);
xlabel('pleasure');
subplot 212;
scatter_discrete(accomplishment_all, cat_all, normalize);
xlabel('accomplishment');
colormap gray;

%% personal

pleasure_all = [];
accomplishment_all = [];
for i=1:length(subject_eml),
    pleasure_all = [pleasure_all; zscore(pleasure{i})];
    accomplishment_all = [accomplishment_all; zscore(accomplishment{i})];
end

% removing cetagories not in mobilyze_cats
pleasure_all(to_be_removed) = [];
accomplishment_all(to_be_removed) = [];

%% plotting the results
figure;
subplot 211;
pleasure_rng = min(pleasure_all):.2:(max(pleasure_all)+.1);
pleasure_all_disc = discretize(pleasure_all, pleasure_rng);
scatter_discrete(pleasure_all_disc, cat_all, normalize);
xlabel('pleasure');
set(gca, 'xtick', 1:30:length(pleasure_rng), 'xticklabel', ...
    num2str(round(pleasure_rng(1:30:end)'*10)/10));

subplot 212;
accomplishment_rng = min(accomplishment_all):.2:(max(accomplishment_all)+.1);
accomplishment_all_disc = discretize(accomplishment_all, accomplishment_rng);
scatter_discrete(accomplishment_all_disc, cat_all, normalize);
xlabel('accomplishment');
set(gca, 'xtick', 1:30:length(accomplishment_rng), 'xticklabel', ...
    num2str(round(accomplishment_rng(1:30:end)'*10)/10));
