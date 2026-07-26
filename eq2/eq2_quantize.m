%% ==============================================================
% EQ2 - INT8 Quantization Workflow
% MATLAB R2025b
% ==============================================================

clear
clc

%% Load trained EQ1 model
load("../eq1/eq1_seq2point_sampled.mat","net");

%% Load representative calibration windows
load("calibrationData.mat","calibrationData");

%% Create quantizer
dq = dlquantizer(net,"ExecutionEnvironment","MATLAB");

%% Prepare network
prepareNetwork(dq);

%% Stack calibration windows
N = numel(calibrationData);

X = zeros(599,1,N,'single');

for k = 1:N
    X(:,:,k) = calibrationData{k}';
end

fprintf("Calibration tensor size:\n");
disp(size(X));

%% Calibrate
disp("Starting calibration...");

calibrate(dq,X);

disp("Calibration complete.");

%% ==============================================================
% Quantize Network
% ==============================================================

disp("Starting INT8 quantization...");

qNet = quantize(dq);

disp("INT8 quantization complete.");

save("eq2_quantized_network.mat","qNet","dq","-v7.3");