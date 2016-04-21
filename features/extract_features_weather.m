function [feature, feature_labels] = extract_features_weather(data)

feature_labels = {'temp mean','temp max','temp min','temp var','hum mean', 'hum var', 'press mean', ...
    'press var', 'weather badness'};

if isempty(data),
    feature = ones(1,length(feature_labels))*NaN;
    return;
end

% conditions = {'Drizzle','Rain','Snow','Snow Grains','Ice Crystals','Ice Pellets','Hail','Mist','Fog',...
%     'Fog Patches','Smoke','Volcanic Ash','Widespread Dust','Sand','Haze','Spray','Dust Whirls','Sandstorm',...
%     'Low Drifting Snow','Low Drifting Widespread Dust','Low Drifting Sand','Blowing Snow',...
%     'Blowing Widespread Dust','Blowing Sand','Rain Mist','Rain Showers','Snow Showers','Snow Blowing Snow Mist',...
%     'Ice Pellet Showers','Hail Showers','Small Hail Showers','Thunderstorm','Thunderstorms and Rain',...
%     'Thunderstorms and Snow','Thunderstorms and Ice Pellets','Thunderstorms with Hail','Thunderstorms with Small Hail',...
%     'Freezing Drizzle','Freezing Rain','Freezing Fog','Patches of Fog','Shallow Fog','Partial Fog','Overcast',...
%     'Clear','Partly Cloudy','Mostly Cloudy','Scattered Clouds','Small Hail','Squalls','Funnel Cloud',...
%     'Unknown Precipitation','Unknown'};

conditions_bright = {'Clear','Partly Cloudy','Scattered Clouds'};
conditions_medium = {'Snow','Snow Grains','Volcanic Ash','Widespread Dust','Sand','Haze','Spray','Dust Whirls',...
    'Low Drifting Snow','Low Drifting Widespread Dust','Low Drifting Sand','Blowing Snow',...
    'Blowing Widespread Dust','Blowing Sand','Snow Showers','Snow Blowing Snow Mist','Thunderstorms and Snow',...
    'Unknown Precipitation','Unknown'};
conditions_dark = {'Drizzle','Rain','Ice Crystals','Ice Pellets','Hail','Mist','Fog','Fog Patches','Smoke',...
    'Sandstorm','Rain Mist','Rain Showers','Ice Pellet Showers','Hail Showers','Small Hail Showers','Thunderstorm',...
    'Thunderstorms and Rain','Thunderstorms and Ice Pellets','Thunderstorms with Hail','Thunderstorms with Small Hail',...
    'Freezing Drizzle','Freezing Rain','Freezing Fog','Patches of Fog','Shallow Fog','Partial Fog','Overcast',...
    'Mostly Cloudy','Small Hail','Squalls','Funnel Cloud'};

timestamp = data{1};
tempm = data{2};
hum = data{3};
dewptm = data{4};
wspdm = data{5};
vism = data{6};
pressurem = data{7};
windchillm = data{8};
% precipm = data{9};
conds = data{10};
fog = data{11};
rain = data{12};
snow = data{13};
hail = data{14};
thunder = data{15};
tornado = data{16};

clear data;

if isempty(timestamp),
    feature = ones(1,length(feature_labels))*NaN;
    return;
end

% temperature
temp_mean = mean(tempm);
temp_max = max(tempm);
temp_min = min(tempm);
temp_var = var(tempm);

% humidity
hum_mean = mean(hum);
hum_var = var(hum);

% pressure
press_mean = mean(pressurem);
press_var = var(pressurem);

% precipitation
% prec_mean = mean(precipm);
% prec_var = var(precipm);

% encoding conditions
cond_code = zeros(length(conds),1);
for i=1:length(conds),
    if length(conds{i})>=7,
        if strcmp(conds{i}(1:5),'Light')||strcmp(conds{i}(1:5),'Heavy'),
            conds{i} = conds{i}(7:end);
        end
    end
    if isempty(conds{i}),
        cond_code(i) = NaN;
    else
        ind = find(strcmp(conditions_bright, conds{i}));
        if ~isempty(ind),
            cond_code(i) = 1;
        else
            ind = find(strcmp(conditions_medium, conds{i}));
            if ~isempty(ind),
                cond_code(i) = 2;
            else
                ind = find(strcmp(conditions_dark, conds{i}));
                if ~isempty(ind),
                    cond_code(i) = 3;
                else
                    error('condition %s not found in the list',conds{i});
                end
            end
        end
    end
end

cond_most = mean(cond_code);

% if cond_most==NaN,
%     warning('WU condition was mostly empty');
% end

feature = [temp_mean, temp_max, temp_min, temp_var, hum_mean, hum_var, press_mean, press_var, cond_most];

end