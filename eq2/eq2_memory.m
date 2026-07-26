%% ===============================================================
% ERS Stage 5 - EQ2
% Memory Accounting for Frozen Seq2Point Network
%
% Engineering Question (EQ2)
% Can the validated Seq2Point NILM model be deployed within
% realistic embedded memory constraints?
%
% Inputs:
%   models/eq1_seq2point_sampled.mat
%
% Outputs:
%   results/memory_summary.csv
%   results/fit_table.csv
%   figures/model_memory_breakdown.png
%
% Radianode Engineering Readiness Assessment (ERA)
%% ===============================================================

clear
clc
close all

%% Create Output Folders

if ~exist("results","dir")
    mkdir("results");
end

if ~exist("figures","dir")
    mkdir("figures");
end

%% Load Frozen EQ1 Model

load(fullfile("models","eq1_seq2point_sampled.mat"), ...
    "net","trainingTime","win");

fprintf("\n");
fprintf("==============================================\n");
fprintf("EQ2 MEMORY ACCOUNTING\n");
fprintf("==============================================\n\n");

%% Network Information

fprintf("Network Class      : %s\n", class(net));
fprintf("Training Time      : %.2f s\n", trainingTime);
fprintf("Input Window       : %d samples\n\n", win);

%% ===============================================================
% Count Trainable Parameters
%% ===============================================================

numParams = 0;

layers = net.Layers;

fprintf("Scanning network layers...\n\n");

for i = 1:numel(layers)

    L = layers(i);

    layerParams = 0;

    % Weights
    if isprop(L,'Weights') && ~isempty(L.Weights)
        layerParams = layerParams + numel(L.Weights);
    end

    % Bias
    if isprop(L,'Bias') && ~isempty(L.Bias)
        layerParams = layerParams + numel(L.Bias);
    end

    % Batch Normalization Scale
    if isprop(L,'Scale') && ~isempty(L.Scale)
        layerParams = layerParams + numel(L.Scale);
    end

    % Batch Normalization Offset
    if isprop(L,'Offset') && ~isempty(L.Offset)
        layerParams = layerParams + numel(L.Offset);
    end

    numParams = numParams + layerParams;

    fprintf("%2d. %-35s %10d parameters\n", ...
        i, class(L), layerParams);

end

fprintf("\n");

%% ===============================================================
% Memory Footprint
%% ===============================================================

bytesFP32 = numParams * 4;
bytesINT8 = numParams;

kbFP32 = bytesFP32 / 1024;
kbINT8 = bytesINT8 / 1024;

compressionRatio = bytesFP32 / bytesINT8;

memoryReduction = ...
    (1 - bytesINT8/bytesFP32) * 100;

%% Engineering Memory Budgets

budgetKB = [256 442 512];

fits = kbINT8 <= budgetKB;

%% Display Summary

fprintf("==============================================\n");
fprintf("Memory Summary\n");
fprintf("==============================================\n\n");

fprintf("Trainable Parameters : %d\n", numParams);

fprintf("FP32 Model Size      : %.2f KB\n", kbFP32);

fprintf("INT8 Model Size      : %.2f KB\n", kbINT8);

fprintf("Compression Ratio    : %.1f : 1\n", compressionRatio);

fprintf("Memory Reduction     : %.1f %%\n\n", memoryReduction);

fprintf("Engineering Budgets\n");

for k = 1:length(budgetKB)

    if fits(k)
        status = "PASS";
    else
        status = "FAIL";
    end

    fprintf("%4d KB : %s\n", budgetKB(k), status);

end

%% ===============================================================
% Export Memory Summary
%% ===============================================================

Summary = table( ...
    numParams,...
    kbFP32,...
    kbINT8,...
    compressionRatio,...
    memoryReduction,...
    'VariableNames',{ ...
    'Parameters',...
    'FP32_KB',...
    'INT8_KB',...
    'CompressionRatio',...
    'MemoryReductionPercent'});

writetable( ...
    Summary,...
    fullfile("results","memory_summary.csv"));

%% ===============================================================
% Export Engineering Fit Table
%% ===============================================================

BudgetKB = budgetKB';

Status = strings(length(budgetKB),1);

for i = 1:length(budgetKB)

    if fits(i)
        Status(i) = "PASS";
    else
        Status(i) = "FAIL";
    end

end

FitTable = table( ...
    BudgetKB,...
    Status,...
    'VariableNames',{ ...
    'MemoryBudgetKB',...
    'Result'});

writetable( ...
    FitTable,...
    fullfile("results","fit_table.csv"));

%% ===============================================================
% Figure 6.1
% Model Memory Breakdown
%% ===============================================================

figure( ...
    'Color','w',...
    'Position',[100 100 700 500])

bar([kbFP32 kbINT8])

grid on

ylabel('Memory Footprint (KB)')

title('Seq2Point Model Memory Footprint')

set(gca,...
    'FontSize',12,...
    'LineWidth',1,...
    'XTickLabel',{'FP32','INT8'});

text(1,...
    kbFP32,...
    sprintf('%.2f KB',kbFP32),...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'FontSize',11);

text(2,...
    kbINT8,...
    sprintf('%.2f KB',kbINT8),...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'FontSize',11);

exportgraphics( ...
    gcf,...
    fullfile("figures","model_memory_breakdown.png"),...
    'Resolution',600);

%% ===============================================================
% Completion
%% ===============================================================

fprintf("\n");
fprintf("==============================================\n");
fprintf("EQ2 Memory Accounting Complete\n");
fprintf("==============================================\n");

fprintf("Results saved to : results/\n");
fprintf("Figures saved to : figures/\n\n");