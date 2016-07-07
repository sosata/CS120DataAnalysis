clear
close all

load('../settings.mat')

for i=1:length(subjects)
    
    fprintf('%s\n',subjects{i});
    
    filename = [data_dir, subjects{i}, '/ems.csv'];
    if exist(filename, 'file')
        tab = readtable(filename, 'delimiter','\t','readvariablenames',false);
        
        if sum(tab.Var2>2000000000000 | tab.Var3>2000000000000 | tab.Var4>2000000000000 | tab.Var5>2000000000000),
            error('timestamps too big');
        end
        
        if sum(tab.Var2<=0),
            error('negative bed time');
        end
        if sum(tab.Var3<=0),
            error('negative sleep time');
        end
        if sum(tab.Var4<=0),
            error('negative wake time');
        end
        if sum(tab.Var5<=0),
            error('negative up time');
        end
        
    else
        fprintf('no file \n')
    end
end