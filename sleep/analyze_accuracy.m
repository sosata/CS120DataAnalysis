clear;
close all;

addpath('../functions/');
load('results_personal_rfhmm');

h = figure;
set(h,'position',[680   406   677   692]);

% age
subplot 221;
hold on;
colors = lines(size(out,2));
for i=1:size(out,2),
    plot(demoage, out(:,i), '.','color',colors(i,:));
end
legend('accuracy','precision','recall','location','southeast');
for i=1:size(out,2),
    [r,p] = mycorr(demoage',out(:,i),'pearson');
    if p<.05,
        r
        mdl = fitlm(demoage, out(:,i));
        x1 = min(demoage);
        x2 = max(demoage);
        y1 = predict(mdl, x1);
        y2 = predict(mdl, x2);
        plot([x1 x2],[y1 y2],'color',colors(i,:));
    end
end
xlabel('age');
ylabel('performance');

% gender
subplot 222;
hold on;
ind_female = find(demofemale==1);
ind_male = find(demofemale==0);
for i=1:3,
   plot(.9+(i-1)/10, out(ind_female,i), '.','color',colors(i,:));
   plot(1.9+(i-1)/10, out(ind_male,i), '.','color',colors(i,:));
   ranksum(out(ind_female,i),out(ind_male,i))
end
set(gca,'xtick',1:2,'xticklabel',{'female','male'});
xlabel('gender');
ylabel('performance');

% share bedroom?
subplot 223;
hold on;
ind_share = find(demosleepalone==1);
ind_alone = find(demosleepalone==2);
for i=1:3,
   plot(.9+(i-1)/10, out(ind_share,i), '.','color',colors(i,:));
   plot(1.9+(i-1)/10, out(ind_alone,i), '.','color',colors(i,:));
   ranksum(out(ind_share,i),out(ind_alone,i))
end
set(gca,'xtick',1:2,'xticklabel',{'yes','no'});
xlabel('share bedroom?');
ylabel('performance');

% live alone?
subplot 224;
hold on;
ind_alone = find(demoalone==1);
ind_notalone = find(demoalone==2);
for i=1:3,
   plot(.9+(i-1)/10, out(ind_alone,i), '.','color',colors(i,:));
   plot(1.9+(i-1)/10, out(ind_notalone,i), '.','color',colors(i,:));
   ranksum(out(ind_alone,i),out(ind_notalone,i))
end
set(gca,'xtick',1:2,'xticklabel',{'yes','no'});
xlabel('live alone?');
ylabel('performance');

% phone location
h = figure;
set(h,'position',[680   743   677   355]);
subplot 121;
hold on;
ind_bedroom = find(demophonelocation==1);
ind_other = find(demophonelocation==2);
for i=1:3,
   plot(.9+(i-1)/10, out(ind_bedroom,i), '.','color',colors(i,:));
   plot(1.9+(i-1)/10, out(ind_other,i), '.','color',colors(i,:));
   ranksum(out(ind_bedroom,i),out(ind_other,i))
end
set(gca,'xtick',1:2,'xticklabel',{'bedroom','other'});
xlabel('phone location when asleep');
ylabel('performance');

% employment
subplot 122;
hold on;
ind_employed = find(demoemployed==1);
ind_unemployed = find(demoemployed==2);
ind_disabled = find(demoemployed==3);
ind_retired = find(demoemployed==4);
ind_other = find(demoemployed==5);
for i=1:3,
   plot(.9+(i-1)/10, out(ind_employed,i), '.','color',colors(i,:));plot(.9+(i-1)/10, nanmedian(out(ind_employed,i)), '.','color',colors(i,:),'markersize',24);
   plot(1.9+(i-1)/10, out(ind_unemployed,i), '.','color',colors(i,:));plot(1.9+(i-1)/10, nanmedian(out(ind_unemployed,i)), '.','color',colors(i,:),'markersize',24);
   plot(2.9+(i-1)/10, out(ind_disabled,i), '.','color',colors(i,:));plot(2.9+(i-1)/10, nanmedian(out(ind_disabled,i)), '.','color',colors(i,:),'markersize',24);
   plot(3.9+(i-1)/10, out(ind_retired,i), '.','color',colors(i,:));plot(3.9+(i-1)/10, nanmedian(out(ind_retired,i)), '.','color',colors(i,:),'markersize',24);
   plot(4.9+(i-1)/10, out(ind_other,i), '.','color',colors(i,:));plot(4.9+(i-1)/10, nanmedian(out(ind_other,i)), '.','color',colors(i,:),'markersize',24);
   p_unemployed = ranksum(out(ind_employed,i),out(ind_unemployed,i))
   p_disabled = ranksum(out(ind_employed,i),out(ind_disabled,i))
   p_retired = ranksum(out(ind_employed,i),out(ind_retired,i))
end
my_xticklabels(gca,1:5,{'employed','unemployed','disabled','retired','other'},'rotation',45);
ylabel('performance');
