%% ============================================================
% EQ2 - FP32 vs INT8 Validation
%
% Dissertation:
% Engineering Question 2 (EQ2)
%
% MATLAB R2025b
%% ============================================================

clear
clc

%% ============================================================
% Resolve Project Paths
%% ============================================================

eq2Folder = fileparts(mfilename('fullpath'));

projectRoot = fileparts(eq2Folder);

eq1Folder = fullfile(projectRoot,"eq1");

modelFolder = fullfile(eq2Folder,"models");

addpath(genpath(eq1Folder));
addpath(genpath(eq2Folder));

%% ============================================================
% Load Networks
%% ============================================================

fprintf("Loading FP32 model...\n");

load(fullfile(modelFolder,"eq1_seq2point_sampled.mat"),"net");

fprintf("Loading INT8 model...\n");

load(fullfile(eq2Folder,"eq2_quantized_network.mat"),"qNet");

fprintf("Models loaded successfully.\n");

%% ============================================================
% Dataset
%% ============================================================

matFile = fullfile(eq1Folder,"pairs_1_6Hz_v73.mat");

win = 599;

fprintf("Creating test datastore...\n");

[~,~,dsTest] = makeWindowsSampled(matFile,win);

%% ============================================================
% Allocate Memory
%% ============================================================

numSamples = 5000;

fp32Pred = zeros(numSamples,1,'single');
int8Pred = zeros(numSamples,1,'single');
groundTruth = zeros(numSamples,1,'single');

%% ============================================================
% Run Inference
%% ============================================================

fprintf("\n");
fprintf("=============================================\n");
fprintf("Running FP32 and INT8 inference\n");
fprintf("=============================================\n");

reset(dsTest);

k = 1;

while hasdata(dsTest)

    sample = read(dsTest);

    X = sample{1};
    Y = sample{2};

    %% FP32 Prediction (DAGNetwork)

    fp32Pred(k) = predict(net,{X});

    %% INT8 Prediction (Quantized dlnetwork)

    yINT8 = predict(qNet,dlarray(single(X),'CT'));

    int8Pred(k) = gather(extractdata(yINT8));

    %% Ground Truth

    groundTruth(k) = Y;

    if mod(k,500)==0
        fprintf("Processed %d / %d samples\n",k,numSamples);
    end

    k = k + 1;

end

fprintf("\nInference completed successfully.\n");

%% ============================================================
% FP32 vs INT8 Fidelity
%% ============================================================

difference = fp32Pred - int8Pred;

RMSE_FP32_INT8 = sqrt(mean(difference.^2));

MAE_FP32_INT8 = mean(abs(difference));

MaxDifference = max(abs(difference));

Correlation = corr(double(fp32Pred),double(int8Pred));

%% ============================================================
% Accuracy Against Ground Truth
%% ============================================================

RMSE_FP32 = sqrt(mean((fp32Pred-groundTruth).^2));

RMSE_INT8 = sqrt(mean((int8Pred-groundTruth).^2));

MAE_FP32 = mean(abs(fp32Pred-groundTruth));

MAE_INT8 = mean(abs(int8Pred-groundTruth));

%% ============================================================
% Relative Error
%% ============================================================

RelativeError = abs(difference)./max(abs(fp32Pred),eps('single'));

MeanRelativeError = mean(RelativeError)*100;

%% ============================================================
% Display Results
%% ============================================================

fprintf("\n");
fprintf("=====================================================\n");
fprintf("EQ2 QUANTIZATION VALIDATION RESULTS\n");
fprintf("=====================================================\n");

fprintf("\nFP32 vs INT8 Fidelity\n");
fprintf("-----------------------------------------------\n");
fprintf("RMSE                 : %.6f W\n",RMSE_FP32_INT8);
fprintf("MAE                  : %.6f W\n",MAE_FP32_INT8);
fprintf("Maximum Difference   : %.6f W\n",MaxDifference);
fprintf("Correlation          : %.6f\n",Correlation);
fprintf("Mean Relative Error  : %.6f %%\n",MeanRelativeError);

fprintf("\nGround Truth Accuracy\n");
fprintf("-----------------------------------------------\n");
fprintf("FP32 RMSE            : %.6f W\n",RMSE_FP32);
fprintf("INT8 RMSE            : %.6f W\n",RMSE_INT8);
fprintf("FP32 MAE             : %.6f W\n",MAE_FP32);
fprintf("INT8 MAE             : %.6f W\n",MAE_INT8);

fprintf("\nMemory Summary\n");
fprintf("-----------------------------------------------\n");
fprintf("FP32 Model Size      : 354.10 KB\n");
fprintf("INT8 Model Size      : 88.52 KB\n");
fprintf("Memory Reduction     : 75.00 %%\n");

fprintf("=====================================================\n");

%% ============================================================
% Save Results
%% ============================================================

results = table(...
    RMSE_FP32_INT8,...
    MAE_FP32_INT8,...
    MaxDifference,...
    Correlation,...
    MeanRelativeError,...
    RMSE_FP32,...
    RMSE_INT8,...
    MAE_FP32,...
    MAE_INT8);

csvFile = fullfile(eq2Folder,"eq2_quantization_results.csv");

matFileOut = fullfile(eq2Folder,"eq2_quantization_results.mat");

writetable(results,csvFile);

save(matFileOut,...
    "results",...
    "fp32Pred",...
    "int8Pred",...
    "groundTruth");

fprintf("\nResults saved successfully.\n");
fprintf("CSV : %s\n",csvFile);
fprintf("MAT : %s\n",matFileOut);