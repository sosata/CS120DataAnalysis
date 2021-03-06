clear;
close all;

addpath('../functions');

labs = readtable('../../../../Data/CS120Clinical/CS120GroupLabels_BasicDemos.xlsx');
load('../FeatureExtraction/features_biweekly_all');

subject_labels = zeros(length(subject_feature),1);
for i=1:length(subject_feature),
    
    ind = find(strcmp(labs.STUDYID, subject_feature{i}));
    
    if ~isempty(ind),
        if labs.CONTROL(ind)==1,
            subject_labels(i) = 1;
        elseif labs.DEPRESSED(ind)==1,
            subject_labels(i) = 2;
        elseif labs.ANXIOUS(ind)==1,
            subject_labels(i) = 1;
        elseif labs.DEPRESSEDampANXIOUS(ind)==1,
            subject_labels(i) = 2;
        else
            subject_labels(i) = 0;
            warning('subject''s score was not found');
        end
    end
    
end

ind = find(subject_labels==0);
subject_labels(ind) = [];
feature(ind) = [];

num_weeks = 5;%median(cellfun(@(x) size(x,1), feature));

groups = unique(subject_labels);
% colors = lines(length(groups));
colors = [0 .6 0; 1 0 0];

for w = 1,%:num_weeks,
    
    ft = [];
    for s = 1:length(feature),
        if size(feature{s},1)>=w,
            ft = [ft; feature{s}(w,:)];
        end
    end
    
    ft = myzscore(ft);
    
    h=figure;
    %set(h,'position',[274   122   939   773]);
    hold on;
    for i=1:length(groups),
        plot([0 .01],[0 0],'color', colors(i,:),'linewidth',2);
    end
    legend('depression','anxiety');
    set(gca,'xtick',[]);
    h_max = -Inf*ones(size(ft,2),1);
    for i=1:length(groups),
        for j=1:size(ft,2),
            X = ft(subject_labels==groups(i),j);
            bar(j+i/4, nanmean(X), 'facecolor', colors(i,:), 'edgecolor', 'k', 'barwidth', 1/4);
            %he = errorbar(j+i/8, nanmean(X), nanstd(X)/sqrt(length(X)), 'linewidth',1,'color', 'k');
            plot([j+i/4 j+i/4], [nanmean(X)-nanstd(X)/sqrt(length(X))/2 nanmean(X)+nanstd(X)/sqrt(length(X))/2], '-k');
            %errorbar_tick(he, tick_size, 'units');
            %plot((j+i/8)*ones(length(X1),1), X1, '.', 'color', colors(i,:));
            if h_max(j)<(nanmean(X)+nanstd(X)/sqrt(length(X))/2)*1.05,
                h_max(j) = (nanmean(X)+nanstd(X)/sqrt(length(X))/2)*1.05;
            end
        end
    end
    for j=1:size(ft,2),
        %p = anova1(ft(:,j), subject_labels, 'off');
        [~,p] = ttest2(ft(subject_labels==1,j),ft(subject_labels==2,j));
        if p<.05
            text(j+1/4,h_max(j),[feature_label{j},'(p<.05)'],'rotation',90,'horizontalalignment','left','fontweight','bold');
        else
            text(j+1/4,h_max(j),feature_label{j},'rotation',90,'horizontalalignment','left');
        end
    end
    %my_xticklabels(1:length(feature_label), feature_label, 'rotation', 45, 'HorizontalAlignment','right');
    xlim([0 length(feature_label)+1]);
    box off;
    
end