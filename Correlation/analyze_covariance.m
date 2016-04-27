clear;
close all;

addpath('../functions');

do_clustering = true;
do_permutation = false;
do_filter_demo = false;
do_switch_sign = false;

load('../FeatureExtraction/features_biweekly_all');
load('../Assessment/phq9.mat');
load('../Assessment/gad7.mat');
load('../Demographics/demo.mat');
load('../Assessment/tipi.mat');
load('../Assessment/spin.mat');
load('../Assessment/dast.mat');
load('../Assessment/psqi.mat');

%% inclusion based on demographics
if do_filter_demo,
    subjects_include = subject_demo(age<=27);
    ind_include = [];
    for i=1:length(subjects_include),
        ind = find(strcmp(subject_feature, subjects_include{i}));
        if ~isempty(ind),
            ind_include = [ind_include, find(strcmp(subject_feature, subjects_include{i}))];
        end
    end
    fprintf('%d/%d subject_feature included based on demographics criteria.\n', length(ind_include),length(subject_feature));
    subject_feature = subject_feature(ind_include);
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
    'age','female'}, tipi_label,'SPIN W0','SPIN W3','SPIN W6','DAST','AUDIT','PSQI W0','PSQI W3','PSQI W6'];

num_weeks = 1;%median(cellfun(@(x) size(x,1), feature));

r = cell(num_weeks,1);

for w = 1:num_weeks,
   
    ft = [];
    for s = 1:length(feature),
        if size(feature{s},1)>=w,
            
            % find PHQ9 score
            % mean is used to turn empty to NaN
            ind = find(strcmp(subject_phq.w0,subject_feature{s}));
            if isempty(ind),
                phqw0 = NaN;
            else
                phqw0 = mean(phq.w0(ind));
            end
            ind = find(strcmp(subject_phq.w3,subject_feature{s}));
            if isempty(ind),
                phqw3 = NaN;
            else
                phqw3 = mean(phq.w3(ind));
            end
            ind = find(strcmp(subject_phq.w6,subject_feature{s}));
            if isempty(ind),
                phqw6 = NaN;
            else
                phqw6 = mean(phq.w6(ind));
            end
            
            % find GAD7 score
            ind = find(strcmp(subject_gad.w0,subject_feature{s}));
            if isempty(ind),
                gadw0 = NaN;
            else
                gadw0 = mean(gad.w0(ind));
            end
            ind = find(strcmp(subject_gad.w3,subject_feature{s}));
            if isempty(ind),
                gadw3 = NaN;
            else
                gadw3 = mean(gad.w3(ind));
            end
            ind = find(strcmp(subject_gad.w6,subject_feature{s}));
            if isempty(ind),
                gadw6 = NaN;
            else
                gadw6 = mean(gad.w6(ind));
            end
            
            % find demo info
            ind = find(strcmp(subject_demo,subject_feature{s}));
            if isempty(ind),
                demoage = NaN;
                demofemale = NaN;
            else
                demoage = mean(age(ind));
                demofemale = mean(female(ind));
            end
            
            % find tipi scores
            ind = find(strcmp(subject_tipi,subject_feature{s}));
            if isempty(ind),
                tipiscore = NaN*ones(1,5);
            else
                tipiscore = tipi(ind,:);
            end
            
            % find spin scores
            ind = find(strcmp(subject_spin.w0,subject_feature{s}));
            if isempty(ind),
                spinscorew0 = NaN;
            else
                spinscorew0 = spin.w0(ind);
            end
            ind = find(strcmp(subject_spin.w3,subject_feature{s}));
            if isempty(ind),
                spinscorew3 = NaN;
            else
                spinscorew3 = spin.w3(ind);
            end
            ind = find(strcmp(subject_spin.w6,subject_feature{s}));
            if isempty(ind),
                spinscorew6 = NaN;
            else
                spinscorew6 = spin.w6(ind);
            end
            
            % find dast/audit data
            ind = find(strcmp(subject_dast,subject_feature{s}));
            if isempty(ind),
                dastscore = NaN;
                auditscore = NaN;
            else
                dastscore = dast(ind);
                auditscore = audit(ind);
            end
            
            % find psqi score
            ind = find(strcmp(subject_psqi.w0,subject_feature{s}));
            if isempty(ind),
                psqiscorew0 = NaN;
            else
                psqiscorew0 = psqi.w0(ind);
            end
            ind = find(strcmp(subject_psqi.w3,subject_feature{s}));
            if isempty(ind),
                psqiscorew3 = NaN;
            else
                psqiscorew3 = psqi.w3(ind);
            end
            ind = find(strcmp(subject_psqi.w6,subject_feature{s}));
            if isempty(ind),
                psqiscorew6 = NaN;
            else
                psqiscorew6 = psqi.w6(ind);
            end
            
            ft = [ft; [feature{s}(w,:), phqw0, phqw3, phqw6, phqw3-phqw0,phqw6-phqw3, ...
                gadw0, gadw3, gadw6, gadw3-gadw0,gadw6-gadw3, ...
                demoage, demofemale, tipiscore, spinscorew0, spinscorew3, spinscorew6, dastscore, auditscore, psqiscorew0, psqiscorew3, psqiscorew6]];
            
        else
            fprintf('Week %d: subject %s removed due to lack of data', w, subject_feature{s});
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