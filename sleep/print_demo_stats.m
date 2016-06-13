clear all
close all

%% Load Data

d = load('demo_baseline');
s = load('features_sleepdetection');

subjects = s.subjects_sleep;

%%

subj_idx = ismember(d.subject_baseline, subjects);

% DANGER: size(subj_idx) is 207. Is this the right number?

%% Let's get the demographics as they stand.

names = fieldnames(d);
fprintf('sleep survey proportions:\n')
for i = 1:length(names)
    if ~strcmp(names{i}, 'subject_baseline')
        field = getfield(d, names{i});
        total = length(field(subj_idx));
        fprintf('%s:\n', names{i})
        uniques = unique(field);
        for j = 1:length(uniques)
            if isnan(uniques(j))
                fprintf('\t%s: %f (%i/%i)\n', num2str(uniques(j)), ...
                    length(find(isnan(field(subj_idx)))) / total, ...
                    length(find(isnan(field(subj_idx)))), total)
            else
                fprintf('\t%s: %f (%i/%i)\n', num2str(uniques(j)), ...
                    length(find(field(subj_idx) == j)) / total, ...
                    length(find(field(subj_idx) == j)), total)
            end
        end
    end
end