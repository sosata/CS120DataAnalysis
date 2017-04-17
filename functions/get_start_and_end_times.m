function [sleep_times, full_sleep_times] = get_start_and_end_times(x)
%
% Returns an n-by-2 matrix: first column is the index of a sleep cycle start,
% and second column is the last index of that sleep cycle. The first output
% is this matrix, where all the sleep cycles that are started or ended by
% NaN's have those indices indicated by NaNs. full_sleep_times will replace
% NaN's with the first or last index of that sleep cycle.
%

deltas = diff(x);

sleep_starts = find(deltas == 1) + 1; % First index of sleep
sleep_ends = find(deltas == -1); % Last index of sleep

% Find nan-region starts and ends

nan_starts = find(diff(isnan(x)) > 0) + 1; % First NaN index of a gap
nan_ends = find(diff(isnan(x)) < 0); % Last NaN index of a gap

sleep_nan_starts = nan_ends(x(nan_ends + 1) == 1) + 1;
sleep_nan_ends = nan_starts(x(nan_starts - 1) == 1) - 1;

% In case signal starts immediately (won't show up on diff(isnan()))
if x(1) == 1
    sleep_nan_starts = [1; sleep_nan_starts];
end

% In case there aren't any nan's, the end won't show up on diff.
if x(end) == 1
    sleep_nan_ends = [sleep_nan_ends; length(x)];
end

% Interleave these things

full_start = sort([sleep_nan_starts; sleep_starts]);
full_end = sort([sleep_nan_ends; sleep_ends]);

full_sleep_times = [full_start, full_end];

% Re-NaN the NaN times for the primary output

sleep_times = full_sleep_times;
sleep_times(ismember(sleep_times(:,1), sleep_nan_starts),1) = NaN;
sleep_times(ismember(sleep_times(:,2), sleep_nan_ends),2) = NaN;