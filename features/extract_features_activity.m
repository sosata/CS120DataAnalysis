function [feature, feature_label] = extract_features_activity(data)

feature_label = {'still','active','car','biking'};

if isempty(data),
    feature = NaN*ones(1,length(feature_label));
    return;
end

if isempty(data{1}),
    feature = NaN*ones(1,length(feature_label));
    return;
end

time = data{1};
act = data{2};

classes_still = {'IN_VEHICLE','STILL','TILTING'};
classes_active = {'ON_BICYCLE','ON_FOOT','RUNNING','WALKING'};
classes_incar = {'IN_VEHICLE'};
classes_onbike = {'ON_BICYCLE'};

act_still = 0;
act_active = 0;
act_incar = 0;
act_onbike = 0;

for i=1:length(act),
    
    act_still = act_still+sum(strcmp(classes_still, act{i}));
    act_active = act_active+sum(strcmp(classes_active, act{i}));
    act_incar = act_incar+sum(strcmp(classes_incar, act{i}));
    act_onbike = act_onbike+sum(strcmp(classes_onbike, act{i}));
    
end

feature = [act_still/length(data), act_active/length(data), act_incar/length(data), act_onbike/length(data)];

end