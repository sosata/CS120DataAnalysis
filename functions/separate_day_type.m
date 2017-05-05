function [data_weekday, data_weekend, data_weekendplus] = separate_day_type(data)

if ~istable(data),
    error('Data must be in table format.');
end

ind_weekday = [];
ind_weekend = [];
ind_weekendplus = [];

for i=2:size(data,1),
%     wd = weekday(str2double(data.Var1(i))/86400 + datenum(1970,1,1));
    wd = weekday(data.Var1(i)/86400 + datenum(1970,1,1));
    if (wd==1)||(wd==7),
        ind_weekend = [ind_weekend, i];
    else
        ind_weekday = [ind_weekday, i];
    end
    if (wd==1)||(wd==6)||(wd==7),
        ind_weekendplus = [ind_weekendplus, i];
    end
end

data_weekday = data(ind_weekday, :);
data_weekend = data(ind_weekend, :);
data_weekendplus = data(ind_weekendplus, :);
    
end