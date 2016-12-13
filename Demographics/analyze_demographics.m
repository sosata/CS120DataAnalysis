clear;
close all;

load('demo_basic');

% tab = readtable('C:\Users\Sohrob\Dropbox\Data\CS120Clinical\CS120GroupLabels_BasicDemos.xlsx');
% tab = readtable('C:\Users\cbits\Dropbox\Data\CS120Clinical\CS120GroupLabels_BasicDemos.xlsx');

% age = (now-datenum(tab.DOB))/365;
% gender = tab.GENDER;


% hist(age);
% xlabel('age');
% title(sprintf('mean: %.1f\nSD: %.1f', mean(age), std(age)));

fprintf('age mean (std): %.f (%.1f)\n', mean(age), std(age));
fprintf('gender: %d male, %d female\n', sum(~female), sum(female));

white = cell2mat(cellfun(@(x) ~isempty(strfind(x,'White')),race,'uniformoutput', false));
black = cell2mat(cellfun(@(x) ~isempty(strfind(x,'African')),race,'uniformoutput', false));
asian = cell2mat(cellfun(@(x) ~isempty(strfind(x,'Asian')),race,'uniformoutput', false));
american = cell2mat(cellfun(@(x) ~isempty(strfind(x,'American Indian')),race,'uniformoutput', false));
prefer_not_to_say = cell2mat(cellfun(@(x) ~isempty(strfind(x,'Prefer not')),race,'uniformoutput', false));

hispanic = cell2mat(cellfun(@(x) ~isempty(strfind(x,'Cuban')),ethnicity,'uniformoutput', false));
nonhispanic = cell2mat(cellfun(@(x) ~isempty(strfind(x,'Not Hispanic')),ethnicity,'uniformoutput', false));
