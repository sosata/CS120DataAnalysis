% This function only works on sensors that have been extracted daily

function [sensor_normal, sensor_off] =separate_workday_dailysensor(sensor, day_type)

day_type_day = floor(day_type.time/86400);
sensor_day = floor(sensor{1}/86400);

% finding and removing duplicates in day_type
inds = find(diff(day_type_day)==0);
if ~isempty(inds),
    fprintf('%.0f%% duplicates removed from self-reported day type.\n',length(inds)/length(day_type_day)*100);
    day_type.time(inds+1) = [];
    day_type.type(inds+1) = [];
    day_type_day(inds) = [];
end

ind_normal = ((day_type.type=='normal')|(day_type.type=='partial'));
ind_off = (day_type.type=='off');

if sum(ind_normal)+sum(ind_off)~=length(day_type.type),
    error('Something is wrong.');
end

day_normal = day_type_day(ind_normal);
day_off = day_type_day(ind_off);

for i=1:length(sensor),
    sensor_normal{i} = sensor{i}(ismember(sensor_day,day_normal));
    sensor_off{i} = sensor{i}(ismember(sensor_day,day_off));
end

if length(sensor_normal{1})+length(sensor_off{1})<length(sensor{1}),
    fprintf('%.0f%% sensor data removed because there was no normal/off day label.\n', (length(sensor_normal{1})+length(sensor_off{1}))/length(sensor{1})*100);
end

if length(sensor_normal{1})+length(sensor_off{1})>length(sensor{1}),
    length(sensor_normal{1})
    length(sensor_off{1})
    length(sensor{1})
    error('Something is wrong.');
end

end