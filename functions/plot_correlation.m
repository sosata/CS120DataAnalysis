function plot_correlation(X, Y, correlation_type)

plot(X, Y, '.');%,'MarkerSize', 25); 
hold on;
[r, p] = corr(X, Y, 'type', correlation_type);
lm = fitlm(X, Y, 'linear');
rmse = lm.RMSE;
if p<=0.05,
    a = polyfit(X, Y, 1);
    x = [min(X), max(X)];
    plot(x, a(1)*x+a(2),'b');
    plot(x, a(1)*x+a(2)+rmse,'--b');
    plot(x, a(1)*x+a(2)-rmse,'--b');
end
p = round(1000*p)/1000;
star = char(['*'*(p<=0.05),'*'*(p<=0.01),'*'*(p<=0.001),'*'*(p<=0.0001)]);
% title(sprintf('r=%.2f; p<%.3f%s', r, p, star));
title(sprintf('r=%.2f; P=%.3f', r, p));
% title(sprintf('r=%.2f', r));
axis tight;
