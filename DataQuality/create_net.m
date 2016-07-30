clear
close all;

layer(1) = dropoutLayer(.5);
layer(2) = dropoutLayer(.5);

XTrain = randn(1000,1);
YTrain = categorical(round(randn(1000,1)));

opts = trainingOptions('sgdm');
net = trainNetwork(XTrain',YTrain',layer,opts);