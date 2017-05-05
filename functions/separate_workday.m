% data must be in table format
% day_type must be in categorical format

function [data_normal, data_off] =separate_workday(data, day_type)

if isempty(data),
    data_normal = [];
    data_off = [];
    return;
end

day_type_day = floor(day_type.time/86400);
sensor_day = floor(data.Var1/86400);

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

% for i=1:length(data),
%     data_normal{i} = data{i}(ismember(sensor_day,day_normal));
%     data_off{i} = data{i}(ismember(sensor_day,day_off));
% end
data_normal = data(ismember(sensor_day,day_normal),:);
data_off = data(ismember(sensor_day,day_off),:);


if length(data_normal.Var1)+length(data_off.Var1)<length(data.Var1),
    fprintf('%.0f%% sensor data removed because there was no normal/off day label.\n', 100-(length(data_normal.Var1)+length(data_off.Var1))/length(data.Var1)*100);
end

if length(data_normal.Var1)+length(data_off.Var1)>length(data.Var1),
    length(data_normal{1})
    length(data_off{1})
    length(data{1})
    error('Something is terribly wrong.');
end

end