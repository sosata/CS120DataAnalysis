function [feature, feature_label] = extract_features_activity(data)

feature_label = {'still','active','car','biking','time still','time active','time car','time biking'};

if isempty(data),
    feature = NaN*ones(1,length(feature_label));
    return;
end

if isempty(data{1}),
    feature = NaN*ones(1,length(feature_label));
    return;
end

time = data{1};
ndays = (time(end)-time(1))/86400;
act = data{2};

classes_still = {'IN_VEHICLE','STILL','TILTING'};
classes_active = {'ON_BICYCLE','ON_FOOT','RUNNING','WALKING'};
classes_incar = {'IN_VEHICLE'};
classes_onbike = {'ON_BICYCLE'};

act_still = 0;
act_active = 0;
act_incar = 0;
act_onbike = 0;

time_still = 0;
time_active = 0;
time_incar = 0;
time_onbike = 0;

for i=1:length(act),
    
    act_still = act_still+sum(strcmp(classes_still, act{i}));
    act_active = act_active+sum(strcmp(classes_active, act{i}));
    act_incar = act_incar+sum(strcmp(classes_incar, act{i}));
    act_onbike = act_onbike+sum(strcmp(classes_onbike, act{i}));
    
    if i>1,
        if strcmp(act{i},act{i-1}),
            time_add = time(i)-time(i-1);
            if sum(strcmp(classes_still, act{i})),
                time_still = time_still + time_add;
            end
            if sum(strcmp(classes_active, act{i})),
                time_active = time_active + time_add;
            end
            if sum(strcmp(classes_incar, act{i})),
                time_incar = time_incar + time_add;
            end
            if sum(strcmp(classes_onbike, act{i})),
                time_onbike = time_onbike + time_add;
            end
        end
    end
    
end

feature = [act_still/length(act), act_active/length(act), act_incar/length(act), act_onbike/length(act), ...
    time_still/ndays, time_active/ndays, time_incar/ndays, time_onbike/ndays];

end