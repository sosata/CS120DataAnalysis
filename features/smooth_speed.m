function signal_out = smooth_speed(signal)

sigma = 5;
sz = 50;
gauss = exp(-(linspace(-sz/2,sz/2,sz)).^2/(2*sigma^2));
gauss = gauss/sum(gauss);

signal_out = conv(signal, gauss, 'same');


end