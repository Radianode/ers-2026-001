%% ===============================================================
% ERS Stage 5 - EQ2
% Prepare Calibration Dataset for Post-Training Quantization (PTQ)
%
% Engineering Question (EQ2)
% Prepare representative calibration data for INT8
% post-training quantization using dlquantizer.
%
% Inputs:
%   ../pairs_1_6Hz_v73.mat
%
% Outputs:
%   calibrationData.mat
%
% Radianode Engineering Readiness Assessment (ERA)
%% ===============================================================

clear
clc
close all

rng(42,"twister")

%% ---------------------------------------------------------------
% Configuration
%% ---------------------------------------------------------------

win = 599;

numRegions = 5;

samplesPerRegion = 200;      % 5 × 200 = 1000 windows

%% ---------------------------------------------------------------
% Locate Dataset
%% ---------------------------------------------------------------

candidateFiles = { ...
    "pairs_1_6Hz_v73.mat", ...
    fullfile("..","pairs_1_6Hz_v73.mat")};

datasetFile = "";

for k = 1:numel(candidateFiles)

    if isfile(candidateFiles{k})

        datasetFile = candidateFiles{k};
        break

    end

end

if datasetFile == ""

    error("Cannot locate pairs_1_6Hz_v73.mat.");

end

fprintf("\n");
fprintf("==============================================\n");
fprintf("EQ2 Calibration Dataset Preparation\n");
fprintf("==============================================\n\n");

fprintf("Dataset Found:\n%s\n\n",datasetFile);

%% ---------------------------------------------------------------
% Open MAT-file
%% ---------------------------------------------------------------

m = matfile(datasetFile);

N = size(m,"agg",1);

numWindows = N - win + 1;

fprintf("Total Samples : %d\n",N);
fprintf("Total Windows : %d\n\n",numWindows);

%% ---------------------------------------------------------------
% Representative Sampling
%% ---------------------------------------------------------------

fprintf("Selecting representative windows...\n\n");

edges = round(linspace(1,numWindows+1,numRegions+1));

indices = [];

for r = 1:numRegions

    startIdx = edges(r);

    endIdx = edges(r+1)-1;

    available = startIdx:endIdx;

    idx = available(randperm(length(available),samplesPerRegion));

    idx = sort(idx);

    indices = [indices idx];

    fprintf("Region %d : %d windows\n", ...
        r, length(idx));

end

indices = sort(indices);

fprintf("\n");

fprintf("Total Calibration Windows : %d\n\n", ...
    length(indices));

%% ---------------------------------------------------------------
% Build Calibration Dataset
%% ---------------------------------------------------------------

fprintf("Preparing calibration dataset...\n");

calibrationData = cell(length(indices),1);

for k = 1:length(indices)

    idx = indices(k);

    X = single(m.agg(idx:idx+win-1,1)).';

    calibrationData{k} = X;

end

fprintf("Done.\n\n");

%% ---------------------------------------------------------------
% Calibration Summary
%% ---------------------------------------------------------------

Summary = table( ...
    length(calibrationData), ...
    win, ...
    numRegions, ...
    samplesPerRegion, ...
    'VariableNames',{ ...
    'CalibrationWindows', ...
    'WindowLength', ...
    'Regions', ...
    'SamplesPerRegion'});

%% ---------------------------------------------------------------
% Save
%% ---------------------------------------------------------------

save( ...
    "calibrationData.mat", ...
    "calibrationData", ...
    "indices", ...
    "Summary", ...
    "win", ...
    "-v7.3");

%% ---------------------------------------------------------------
% Console Summary
%% ---------------------------------------------------------------

fprintf("==============================================\n");
fprintf("Calibration Dataset Successfully Created\n");
fprintf("==============================================\n\n");

disp(Summary)

fprintf("Saved File : calibrationData.mat\n");

fprintf("\nReady for EQ2 Quantization.\n");