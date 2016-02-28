function scatter_discrete(x, y, normalize)

if (size(x,2)>1)||(size(y,2)>1),
    error('scatter_discrete: input should be 1D vectors!');
end
if length(x)~=length(y),
    error('scatter_discrete: vectors should have the same length!');
end

if ~iscell(x),
    x_u = min(x):min(diff(unique(x))):max(x);
else
    x_u = unique(x);
end
if ~iscell(y),
    y_u = min(y):min(diff(unique(y))):max(y);
else
    y_u = unique(y);
end

img = zeros(length(x_u),length(y_u));

%% extracting indices
x_new = zeros(length(x),1);
if ~iscell(x),
    for i=1:length(x),
        x_new(i) = find(x_u==x(i));
    end
else
    for i=1:length(x),
        x_new(i) = find(strcmp(x_u,x(i)));
    end
end
x = x_new;
y_new = zeros(length(y),1);
if ~iscell(y),
    for i=1:length(y),
        y_new(i) = find(y_u==y(i));
    end
else
    for i=1:length(y),
        y_new(i) = find(strcmp(y_u,y(i)));
    end
end
y = y_new;

for i=1:length(x),
    img(x(i)-min(x)+1, y(i)-min(y)+1) = img(x(i)-min(x)+1, y(i)-min(y)+1)+1;
end

if normalize,
    img = zscore(img);
end

imagesc(img');
set(gca, 'ydir','normal');
set(gca, 'xtick', 1:length(x_u), 'xticklabel', x_u);
set(gca, 'ytick', 1:length(y_u), 'yticklabel', y_u);