% This program matches the data from Purple Robot's comminucation events
% probe and Mobilyze App's self-report contact data and saves the results
% in "emc2.csv" in each subject's directory.

clear;
close all;

load('settings.mat');
addpath('functions');

match_dir = '..\..\..\Data\CS120Contacts\';


list = dir(match_dir);
list(2) = [];
list(1) = [];

data_contact = cell(length(subjects),1);

disp('Reading tables...');

for i = 1:length(list),
    
    fprintf('%d/%d\n', i, length(list));
    
    tab = readtable([match_dir, list(i).name], 'delimiter','\t','readvariablenames', true);

    id_uniq = unique(tab.device_id);
    
    for j = 1:length(id_uniq),
        ind_subj = find(strcmp(subjects, id_uniq(j)));
        
        if ~isempty(ind_subj),
            ind = find(strcmp(tab.device_id, id_uniq(j)));
            if isempty(data_contact{ind_subj}),
                data_contact{ind_subj} = tab(ind, 2:end-1);
            else
                data_contact{ind_subj} = join(data_contact{ind_subj}, tab(ind, 2:end-1));
                fprinttf('tables merged for subject %d\n',ind_subj);
            end
        end
        
    end
    
end

disp('Writing tables to subject directories...');

inds = find(cellfun(@(x) ~isempty(x), data_contact));

for i=1:length(inds),
    fprintf('%d/%d\n', i, length(inds));
    if exist([data_dir, subjects{inds(i)}], 'dir'),
        for j=1:length(data_contact{inds(i)}.date),
            dt = data_contact{inds(i)}.date{j};
            dt(dt=='T') = ' ';
            dt = (datenum(dt) - datenum(1970,1,1))*86400;
            data_contact{inds(i)}.date{j} = dt;
        end
        writetable(data_contact{inds(i)}, [data_dir, subjects{inds(i)}, '\emc2.csv'], 'delimiter', '\t', 'writerownames', false);
    else
        disp('Target directory does not exist. Skipping...');
    end
end

fprintf('%.f%% of contact data recorved.\n',100*length(inds)/length(subjects));

