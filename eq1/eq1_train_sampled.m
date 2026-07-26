%% EQ1 - Seq2Point Training (Sampled UK-DALE)
% MATLAB R2025b
% Stage 5 - Engineering Question 1

clear;
clc;
close all;

%% Configuration

matFile = "C:\Projects\NILM_Stage5\eq1\pairs_1_6Hz_v73.mat";
win = 599;

%% Create Sampled Datastores

[dsTrain, dsVal, dsTest] = makeWindowsSampled(matFile, win);

%% Build Network

lgraph = seq2pointNet(win);

%% Training Options

options = trainingOptions("adam", ...
    MaxEpochs=3, ...
    MiniBatchSize=256, ...
    InitialLearnRate=1e-3, ...
    Shuffle="every-epoch", ...
    ValidationData=dsVal, ...
    ValidationFrequency=50, ...
    Verbose=true, ...
    VerboseFrequency=10, ...
    ExecutionEnvironment="auto", ...
    Plots="training-progress");

%% Begin Training

disp("=====================================================");
disp(" EQ1 - SEQ2POINT TRAINING");
disp("=====================================================");
disp("Dataset              : UK-DALE");
disp("Training Windows     : 25000");
disp("Validation Windows   : 5000");
disp("Testing Windows      : 5000");
disp("Epochs               : 3");
disp("MiniBatch Size       : 256");
disp("=====================================================");

tic;

net = trainNetwork(dsTrain,lgraph,options);

trainingTime = toc;

%% Save Network

save("eq1_seq2point_sampled.mat", ...
    "net", ...
    "trainingTime", ...
    "win", ...
    "-v7.3");

%% Save Experiment Metadata

experiment = struct();

experiment.date = datetime;

experiment.dataset = "UK-DALE";

experiment.windowLength = win;

experiment.trainingWindows = 25000;
experiment.validationWindows = 5000;
experiment.testingWindows = 5000;

experiment.network = "Seq2Point CNN";

experiment.optimizer = "Adam";

experiment.maxEpochs = 3;

experiment.batchSize = 256;

experiment.learningRate = 1e-3;

experiment.validationFrequency = 50;

experiment.executionEnvironment = "CPU";

experiment.trainingTimeSeconds = trainingTime;

save("eq1_experiment.mat","experiment");

%% Summary

disp(" ");

disp("=====================================================");
disp(" TRAINING COMPLETE");
disp("=====================================================");

fprintf("Training Time : %.2f minutes\n",trainingTime/60);

disp(" ");

disp("Generated Files");

disp("  eq1_seq2point_sampled.mat");

disp("  eq1_experiment.mat");

disp(" ");

disp("Next:");

disp("Run evaluateEQ1.m");

disp("=====================================================");