clear;
close all;

addpath('functions');

do_clustering = true;
do_permutation = false;
do_filter_demo = false;
do_switch_sign = false;

load('features_biweekly');
load('phq9.mat');
load('gad7.mat');
load('demo.mat');

%% inclusion based on demographics
if do_filter_demo,
    subjects_include = subject_demo(age<=27);
    ind_include = [];
    for i=1:length(subjects_include),
        ind = find(strcmp(subjects, subjects_include{i}));
        if ~isempty(ind),
            ind_include = [ind_include, find(strcmp(subjects, subjects_include{i}))];
        end
    end
    fprintf('%d/%d subjects included based on demographics criteria.\n', length(ind_include),length(subjects));
    subjects = subjects(ind_include);
    feature = feature(ind_include);
end

%% shuffling PHQ9 and GAD7 values (for permutation test)
if do_permutation,
    phq.w0 = randsample(phq.w0, length(phq.w0));
    phq.w3 = randsample(phq.w3, length(phq.w3));
    phq.w6 = randsample(phq.w6, length(phq.w6));
    gad.w0 = randsample(gad.w0, length(gad.w0));
    gad.w3 = randsample(gad.w3, length(gad.w3));
    gad.w6 = randsample(gad.w6, length(gad.w6));
end


if do_switch_sign,
    inds = [find(strcmp(feature_label,'sleep quality mean')), ...
        find(strcmp(feature_label,'mood mean')), ...
        find(strcmp(feature_label,'stress mean')), ...
        find(strcmp(feature_label,'focus mean')), ...
        find(strcmp(feature_label,'energy mean')), ...
        find(strcmp(feature_label,'home stay')), ...
        find(strcmp(feature_label,'cluster cm')), ...
        find(strcmp(feature_label,'call diff'))];
end


feature_label = [feature_label, {'PHQ9 W0','PHQ9 W3','PHQ9 W6','PHQ9 W3-0','PHQ9 W6-3',...
    'GAD7 W0','GAD7 W3','GAD7 W6','GAD7 W3-0','GAD7 W6-3',...
    'age','female'}];

num_weeks = 1;%median(cellfun(@(x) size(x,1), feature));

r = cell(num_weeks,1);

for w = 1:num_weeks,
   
    ft = [];
    for s = 1:length(feature),
        if size(feature{s},1)>=w,
            
            % find PHQ9 score
            % mean is used to turn empty to NaN
            ind = find(strcmp(subject_phq.w0,subjects{s}));
            if isempty(ind),
                phqw0 = NaN;
            else
                phqw0 = mean(phq.w0(ind));
            end
            ind = find(strcmp(subject_phq.w3,subjects{s}));
            if isempty(ind),
                phqw3 = NaN;
            else
                phqw3 = mean(phq.w3(ind));
            end
            ind = find(strcmp(subject_phq.w6,subjects{s}));
            if isempty(ind),
                phqw6 = NaN;
            else
                phqw6 = mean(phq.w6(ind));
            end
            
            % find GAD7 score
            ind = find(strcmp(subject_gad.w0,subjects{s}));
            if isempty(ind),
                gadw0 = NaN;
            else
                gadw0 = mean(gad.w0(ind));
            end
            ind = find(strcmp(subject_gad.w3,subjects{s}));
            if isempty(ind),
                gadw3 = NaN;
            else
                gadw3 = mean(gad.w3(ind));
            end
            ind = find(strcmp(subject_gad.w6,subjects{s}));
            if isempty(ind),
                gadw6 = NaN;
            else
                gadw6 = mean(gad.w6(ind));
            end
            
            % find demo info
            ind = find(strcmp(subject_demo,subjects{s}));
            if isempty(ind),
                demoage = NaN;
                demofemale = NaN;
            else
                demoage = mean(age(ind));
                demofemale = mean(female(ind));
            end
            
            ft = [ft; [feature{s}(w,:), phqw0, phqw3, phqw6, phqw3-phqw0,phqw6-phqw3, ...
                gadw0, gadw3, gadw6, gadw3-gadw0,gadw6-gadw3, ...
                demoage, demofemale]];
            
        else
            fprintf('Week %d: subject %s removed due to lack of data', w, subjects{s});
        end
    end
    
    if do_switch_sign,
        ft(:,inds) = -ft(:,inds);
    end
    
    %ft = zscore(ft);
    
    r{w} = zeros(size(ft,2),size(ft,2));
    for i=1:size(ft,2),
        for j=1:size(ft,2),
            r{w}(i,j) = mycorr(ft(:,i), ft(:,j));
        end
    end
    
    
    if do_clustering,
        %cluster = clusterdata(r{w},56);
        
        tree = linkage(r{w}, 'average', 'euclidean');
        %dendrogram(tree);
        clust = cluster(tree, 'maxclust', 5);
        
        [~,ind] = sort(clust);
        for i=1:size(ft,2),
            for j=1:size(ft,2),
                r_new(i,j) = r{w}(ind(i),ind(j));
            end
        end
        r{w} = r_new;
    else
        ind = 1:size(r{w},1);
    end
    
    h=figure;
    set(h,'position',[274   122   939   773]);
    imagesc(r{w});
    colormap jet;
    set(gca, 'ytick', 1:length(feature_label), 'yticklabel', feature_label(ind), 'fontsize',7);
    %my_xticklabels(1:length(feature_label), feature_label(ind), 'rotation', 45, 'horizontalalignment', 'left', 'fontsize',7);
    for i=1:length(feature_label),
        text(i-.2,0,feature_label{ind(i)},'rotation',90,'horizontalalignment', 'left', 'fontsize',7);
    end
    h = colorbar;
    ylabel(h,'correlation coefficient (r)');
    
end