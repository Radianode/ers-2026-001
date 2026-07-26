%% ============================================================
% EQ2 - Dissertation Figures
%
% Generates all figures for Engineering Question 2
%
% MATLAB R2025b
%% ============================================================

clear
clc
close all

%% ============================================================
% Paths
%% ============================================================

eq2Folder = fileparts(mfilename('fullpath'));

figFolder = fullfile(eq2Folder,"figures");

if ~exist(figFolder,"dir")
    mkdir(figFolder);
end

%% ============================================================
% Load Results
%% ============================================================

load(fullfile(eq2Folder,"eq2_quantization_results.mat"))

%% ============================================================
% Recalculate Metrics
%% ============================================================

difference = fp32Pred - int8Pred;

RMSE_FP32 = sqrt(mean((fp32Pred-groundTruth).^2));
RMSE_INT8 = sqrt(mean((int8Pred-groundTruth).^2));

MAE_FP32 = mean(abs(fp32Pred-groundTruth));
MAE_INT8 = mean(abs(int8Pred-groundTruth));

Correlation = corr(double(fp32Pred),double(int8Pred));

%% ============================================================
% Figure 1
% FP32 vs INT8 Scatter Plot
%% ============================================================

figure('Color','w')

scatter(fp32Pred,...
        int8Pred,...
        10,...
        'filled')

hold on

mn = min([fp32Pred; int8Pred]);
mx = max([fp32Pred; int8Pred]);

plot([mn mx],[mn mx],...
    'r--',...
    'LineWidth',2)

grid on
axis equal

xlabel('FP32 Prediction (W)')
ylabel('INT8 Prediction (W)')

title('FP32 vs INT8 Prediction Fidelity')

saveas(gcf,...
    fullfile(figFolder,...
    'Figure_EQ2_Scatter.png'))

%% ============================================================
% Figure 2
% Error Histogram
%% ============================================================

figure('Color','w')

histogram(difference,40)

grid on

xlabel('Prediction Error (FP32 - INT8) (W)')
ylabel('Frequency')

title('Distribution of Quantization Error')

saveas(gcf,...
    fullfile(figFolder,...
    'Figure_EQ2_ErrorHistogram.png'))

%% ============================================================
% Figure 3
% Accuracy Comparison
%% ============================================================

figure('Color','w')

metrics = [RMSE_FP32 RMSE_INT8;
           MAE_FP32 MAE_INT8];

bar(metrics)

grid on

xticklabels({'RMSE','MAE'})

ylabel('Watts')

legend('FP32',...
       'INT8',...
       'Location','northwest')

title('Prediction Accuracy Against Ground Truth')

saveas(gcf,...
    fullfile(figFolder,...
    'Figure_EQ2_AccuracyComparison.png'))

%% ============================================================
% Figure 4
% Memory Footprint
%% ============================================================

figure('Color','w')

memory = [354.10 88.52];

bar(memory)

grid on

xticklabels({'FP32','INT8'})

ylabel('Model Size (KB)')

title('Model Memory Footprint')

text(2,...
     memory(2)+10,...
     '75% Reduction',...
     'HorizontalAlignment','center',...
     'FontWeight','bold')

saveas(gcf,...
    fullfile(figFolder,...
    'Figure_EQ2_MemoryReduction.png'))

%% ============================================================
% Figure 5
% Prediction Overlay
%% ============================================================

figure('Color','w')

N = 500;

plot(fp32Pred(1:N),...
    'LineWidth',1.5)

hold on

plot(int8Pred(1:N),...
    '--',...
    'LineWidth',1.5)

grid on

xlabel('Sample')

ylabel('Predicted Power (W)')

legend('FP32',...
       'INT8',...
       'Location','best')

title('Prediction Overlay (First 500 Samples)')

saveas(gcf,...
    fullfile(figFolder,...
    'Figure_EQ2_PredictionOverlay.png'))

%% ============================================================
% Figure 6
% Absolute Error
%% ============================================================

figure('Color','w')

plot(abs(difference),...
    'LineWidth',1)

grid on

xlabel('Sample')

ylabel('Absolute Error (W)')

title('Absolute Prediction Difference Between FP32 and INT8')

saveas(gcf,...
    fullfile(figFolder,...
    'Figure_EQ2_AbsoluteError.png'))

%% ============================================================
% Summary
%% ============================================================

fprintf('\n');
fprintf('==============================================\n');
fprintf('EQ2 FIGURES GENERATED SUCCESSFULLY\n');
fprintf('==============================================\n');

disp(figFolder)

fprintf('\nGenerated Figures:\n');

fprintf('1. Figure_EQ2_Scatter.png\n');
fprintf('2. Figure_EQ2_ErrorHistogram.png\n');
fprintf('3. Figure_EQ2_AccuracyComparison.png\n');
fprintf('4. Figure_EQ2_MemoryReduction.png\n');
fprintf('5. Figure_EQ2_PredictionOverlay.png\n');
fprintf('6. Figure_EQ2_AbsoluteError.png\n');

fprintf('==============================================\n');