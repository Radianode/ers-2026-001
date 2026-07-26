%% EQ1 - Seq2Point Training (MATLAB R2025b)

clear
clc

%% Configuration

matFile = "C:\Projects\NILM_Stage5\eq1\pairs_1_6Hz_v73.mat";

win = 599;

splitCfg.train = 0.70;
splitCfg.val   = 0.15;
splitCfg.test  = 0.15;

%% Create datastores

[dsTrain,dsVal,dsTest] = makeWindows(matFile,win,splitCfg);

%% Build network

lgraph = seq2pointNet(win);

%% Training options

options = trainingOptions("adam", ...
    MaxEpochs=5, ...
    MiniBatchSize=512, ...
    InitialLearnRate=1e-3, ...
    Shuffle="every-epoch", ...
    ValidationData=dsVal, ...
    ValidationFrequency=1000, ...
    Verbose=true, ...
    Plots="training-progress");

%% Train

net = trainNetwork(dsTrain,lgraph,options);

%% Save model

save("eq1_trained_network.mat","net","-v7.3");

disp("Training completed successfully.");