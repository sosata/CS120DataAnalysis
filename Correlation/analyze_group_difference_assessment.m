clear;
close all;

addpath('../functions');

load('../Assessment/phq9.mat');
load('../FeatureExtraction/features_biweekly_all');

assessment = phq.w0;
subject_assessment = subject_phq.w0;

prc_low = prctile(assessment, 27);
prc_high = prctile(assessment, 73);

cnt = 1;
for i=1:length(subject_feature),
    
    ind = find(strcmp(subject_assessment, subject_feature{i}));
    
    if ~isempty(ind),
        if assessment(ind)>=prc_high,
            subject_labels(cnt) = 2;
            
        elseif assessment(ind)<=prc_low,
            subject_labels(cnt) = 1;
        else
            continue;
        end
        feature_in{cnt} = feature{i};
        cnt = cnt+1;
    end
    
end

feature = feature_in;
clear feature_in;

num_weeks = 5;

groups = unique(subject_labels);
colors = [0 .6 0; 1 0 0];

for w = 2,%:num_weeks,
    
    ft = [];
    for s = 1:length(feature),
        if size(feature{s},1)>=w,
            ft = [ft; feature{s}(w,:)];
        end
    end
    
    ft = myzscore(ft);
    
    h=figure;
    set(h,'position',[4         130        1672         818]);
    hold on;
    for i=1:length(groups),
        plot([0 .01],[0 0],'color', colors(i,:),'linewidth',2);
    end
    legend('bottom 27%','top 27%','location','southeast');
    set(gca,'xtick',[]);
    h_max = -Inf*ones(size(ft,2),1);
    for i=1:length(groups),
        for j=1:size(ft,2),
            X = ft(subject_labels==groups(i),j);
            bar(j+i/4, nanmean(X), 'facecolor', colors(i,:), 'edgecolor', 'k', 'barwidth', 1/4);
            plot([j+i/4 j+i/4], [nanmean(X)-nanstd(X)/sqrt(length(X))/2 nanmean(X)+nanstd(X)/sqrt(length(X))/2], '-k');
            if h_max(j)<(nanmean(X)+nanstd(X)/sqrt(length(X))/2)*1.05,
                h_max(j) = (nanmean(X)+nanstd(X)/sqrt(length(X))/2)*1.05;
            end
        end
    end
    for j=1:size(ft,2),
        %p = anova1(ft(:,j), subject_labels, 'off');
        %[~,p] = ttest2(ft(subject_labels==1,j),ft(subject_labels==2,j));
        [p,~] = ranksum(ft(subject_labels==1,j),ft(subject_labels==2,j));
        if p<.05
            text(j+1/4,h_max(j),[feature_label{j},'(p<.05)'],'rotation',90,'horizontalalignment','left','fontweight','bold');
        else
            text(j+1/4,h_max(j),feature_label{j},'rotation',90,'horizontalalignment','left');
        end
    end
    xlim([0 length(feature_label)+1]);
    box off;
    
end