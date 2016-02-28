function plot_rectangle(x1, x2, offset, color, width)

if length(x1)~=length(x2),
    error('Vectors must have the same length.');
end
if sum((x2-x1)<0)>0,
    error('Times are inconsistent.');
end

if width~=0,
    for i=1:length(x1);
        rectangle('position', [x1(i), offset-.3, x2(i)-x1(i), .6], 'facecolor',color,'edgecolor', color); 
        hold on;
    end
else
    for i=1:length(x1);
        plot([x1(i) x2(i)], [offset offset], color); 
        hold on;
    end
end

end