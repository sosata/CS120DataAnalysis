% This function combines data from individual subjects into a single
% matrix

function y = combine_subjects(x)

if ~iscell(x),
    error('Input must be a cell array');
end

y = [];
for i=1:length(x),
    y = [y; x{i}];
end

end