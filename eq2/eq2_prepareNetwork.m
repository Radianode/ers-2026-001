%% ===============================================================
% ERS Stage 5 - EQ2
%
% Prepare Network for INT8 Quantization
%
% Converts the trained DAGNetwork produced in EQ1 into a
% dlnetwork compatible with the MATLAB Quantization Library.
%
% Input
%   ../eq1/eq1_seq2point_sampled.mat
%
% Output
%   eq2_dlnetwork.mat
%
%% ===============================================================

clear
clc
close all

fprintf('\n');
fprintf('==============================================\n');
fprintf('EQ2 Network Preparation\n');
fprintf('==============================================\n\n');

%% ---------------------------------------------------------------
% Locate EQ1 model
%% ---------------------------------------------------------------

candidateFiles = { ...
    fullfile("..","eq1","eq1_seq2point_sampled.mat"), ...
    "eq1_seq2point_sampled.mat"};

modelFile = "";

for k = 1:numel(candidateFiles)

    if isfile(candidateFiles{k})

        modelFile = candidateFiles{k};
        break

    end

end

if modelFile == ""

    error("Cannot locate eq1_seq2point_sampled.mat.");

end

fprintf("Model Found:\n%s\n\n",modelFile);

%% ---------------------------------------------------------------
% Load model
%% ---------------------------------------------------------------

S = load(modelFile);

if ~isfield(S,"net")

    error("Variable 'net' not found.");

end

net = S.net;

fprintf("Original Network Class : %s\n\n",class(net));

%% ---------------------------------------------------------------
% Convert to dlnetwork if required
%% ---------------------------------------------------------------

if isa(net,"dlnetwork")

    dlnet = net;

    fprintf("Network already uses dlnetwork.\n");

elseif isa(net,"DAGNetwork")

    fprintf("Converting DAGNetwork...\n");

    lgraph = layerGraph(net);

    dlnet = dlnetwork(lgraph);

    fprintf("Conversion completed.\n");

elseif isa(net,"SeriesNetwork")

    fprintf("Converting SeriesNetwork...\n");

    lgraph = layerGraph(net);

    dlnet = dlnetwork(lgraph);

    fprintf("Conversion completed.\n");

else

    error("Unsupported network type: %s",class(net));

end

%% ---------------------------------------------------------------
% Summary
%% ---------------------------------------------------------------

fprintf("\n");
fprintf("==============================================\n");
fprintf("Converted Network Summary\n");
fprintf("==============================================\n\n");

disp(dlnet)

fprintf("\n");

fprintf("Input Names :\n");
disp(dlnet.InputNames)

fprintf("Output Names :\n");
disp(dlnet.OutputNames)

%% ---------------------------------------------------------------
% Save
%% ---------------------------------------------------------------

save("eq2_dlnetwork.mat","dlnet","-v7.3");

fprintf("\n");

fprintf("Saved : eq2_dlnetwork.mat\n");

fprintf("\n");

fprintf("EQ2 Network Preparation Complete.\n");