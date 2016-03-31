clear;
close all;

tab = readtable('../../../Data/CS120Clinical/CS120Assessment.xlsx');

ind_start = find(cellfun(@(x) ~isempty(x), tab.id),1,'first');

prique = [];
sub = {'a','b','c'};
labels = {};
for i=1:7,
    for j=1:length(sub),
        prique_col = cell2mat(cellfun(@(x) str2num(x), tab.(sprintf('priques0%d%s',i,sub{j}))(ind_start:end), ...
            'UniformOutput', false));
        prique_col(prique_col==999) = mean(prique_col(prique_col~=999));
        prique = [prique, prique_col];
        labels = [labels, sprintf('%d%s',i,sub{j})];
    end
end

bar(mean(prique));
hold on;
errorbar(mean(prique), std(prique),'.');
xlim([0 22]);
set(gca, 'xtick', 1:21, 'xticklabel', labels);
xlabel('question');
ylabel('answer');