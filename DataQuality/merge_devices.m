clear;
close all;

data_dir = 'C:\Data\CS120_premerge\';
data_out = 'C:\Users\cbits\Dropbox\Data\CS120\';

% note: currently the 4 problematic subjects have been removed from this
% file -- waiting for Chris to answer
file_maps = 'C:\Users\cbits\Dropbox\Code\Python\PG2CSV_CS120\subject_info_cs120_extended2_clean.csv';

map = readtable(file_maps, 'delimiter', '\t', 'readvariablenames', false);

id_uniq = unique(map.Var1);

for i=1:length(id_uniq),
    
    fprintf('subject %s: ', id_uniq{i});
    inds = find(strcmp(map.Var1, id_uniq{i}));
    num_id(i) = length(inds);
    
    if length(inds)==1,
        
        fprintf('\n');
        continue;
%         system(sprintf('md %s', [data_out, map.Var1{inds}]));
%         system(sprintf('copy %s\\* %s\\* >NUL', [data_dir, map.Var2{inds}], [data_out, map.Var1{inds}]));
%         fprintf('1 device\n');
    
    else
        
        list = [];
        
        for j=1:length(inds),
            
            list{j} = dir([data_dir, map.Var2{inds(j)}]);
            list{j}(1:2) = [];
            if ~isempty(list{j})
                list{j} = {list{j}.name};
            else
                list{j} = [];
            end
            
            
        end
        
        ind_empty = find(cellfun(@isempty, list));
        list(ind_empty) = [];
        inds(ind_empty) = [];
        
        if isempty(list),
            fprintf('no data\n');
        else
            
            if length(list)==1,
                
                fprintf('\n');
                continue;
%                 ind_notempty = find(~cellfun(@isempty, list));
%                 system(sprintf('md %s', [data_out, map.Var1{inds(ind_notempty)}]));
%                 system(sprintf('copy %s\\* %s\\* >NUL', [data_dir, map.Var2{inds(ind_notempty)}], [data_out, map.Var1{inds(ind_notempty)}]));
%                 fprintf('%d devices; only 1 has data\n', length(inds));
            else
                
                fprintf('%d devices; %d with data - merging TODO\n', num_id(i), length(inds));
%                 system(sprintf('md %s', [data_out, map.Var1{inds(1)}]));
                
                l = length(list{1});
                for j=2:length(list),
                    if l~=length(list{j}),
                        disp('FILE MISMATCH');
                    end
                end
                
            end
            
        end
        
    end
    
end