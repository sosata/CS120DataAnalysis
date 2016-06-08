function aln_times = align_sleep_trials(trial_times, template_times, varargin)

% Parse Arguments
p = inputParser;
addRequired(p, 'trial_times', @ismatrix);
addRequired(p, 'template_times', @ismatrix);
addOptional(p, 'method', 'close_start', @isstr);
parse(p, trial_times, template_times, varargin{:})

aln_times = zeros(size(trial_times,1), 2);

for i = 1:size(trial_times, 1)
    if strcmp(p.Results.method, 'close_start')
        [~, idx] = min(abs(template_times(:,1) - trial_times(i,1)));
        aln_times(i,:) = template_times(idx,:);
    end
end