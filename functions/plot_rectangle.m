function plot_rectangle(x1, x2, offset, color)

if length(x1)~=length(x2),
    error('Vectors must have the same length.');
end
if sum((x2-x1)<0)>0,
    error('Times are inconsistent.');
end

for i=1:length(x1);
   rectangle('position', [x1(i), offset-.3, x2(i)-x1(i), .6], 'facecolor',color,'edgecolor', color); 
   hold on;
end

end