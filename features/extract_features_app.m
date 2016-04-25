function [features, feature_labels] = extract_features_app(data)

feature_labels = {'apps n','apps email', 'apps facebook', 'apps weather', 'apps message'};

if isempty(data),
    features = ones(1,length(feature_labels))*NaN;
    return;
end

if isempty(data.Var1),
    features = ones(1,length(feature_labels))*NaN;
    return;
end

num_apps = length(unique(data.Var3));
app_email = sum(strcmp(data.Var3,'Email'));
app_facebook = sum(strcmp(data.Var3,'Facebook'));
app_weather = sum(strcmp(data.Var3,'Weather'));
app_message = sum(strcmp(data.Var3,'Messages'));

features = [num_apps app_email app_facebook app_weather app_message];


end