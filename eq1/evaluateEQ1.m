%% ===============================================================
%  evaluateEQ1.m
%
%  ERS Stage 5
%  Engineering Readiness Assessment
%  Radianode Systems
%
%  EQ1
%  Edge AI Load Disaggregation Validation
%
%  Dataset:
%       UK-DALE
%
%  Target Appliance:
%       Water Heater (Boiler)
%
%  Reference Model:
%       Seq2Point CNN
%
%  Outputs
%  -------
%  eq1_metrics.csv
%  eq1_results.mat
%  eq1_predictions.csv
%  prediction_vs_groundtruth.png
%  residual_plot.png
%  error_histogram.png
%
%% ===============================================================

clear
clc
close all

%% ===============================================================
% Configuration
%% ===============================================================

matFile = "pairs_1_6Hz_v73.mat";
modelFile = "eq1_seq2point_sampled.mat";

threshold = 20;      % Water heater ON threshold (W)

%% ===============================================================
% Load trained model
%% ===============================================================

disp("===============================================");
disp("Loading trained Seq2Point model...");
disp("===============================================");

S = load(modelFile);

net = S.net;
windowLength = S.win;
trainingTime = S.trainingTime;

%% ===============================================================
% Create identical sampled dataset
%% ===============================================================

disp("Recreating representative sampled dataset...");

[~,~,dsTest,~,~,idxTest] = makeWindowsSampled(matFile,windowLength);

%% ===============================================================
% Run prediction
%% ===============================================================

disp("Running inference on test dataset...");

YPred = predict(net,dsTest);

YPred = single(YPred(:));

%% ===============================================================
% Load Ground Truth
%% ===============================================================

disp("Collecting ground truth...");

m = matfile(matFile);

centreOffset = floor(windowLength/2);

YTrue = zeros(numel(idxTest),1,"single");

for k = 1:numel(idxTest)

    centre = idxTest(k) + centreOffset;

    YTrue(k) = single(m.app(centre,1));

end

%% ===============================================================
% Regression Metrics
%% ===============================================================

disp("Computing regression metrics...");

RMSE = sqrt(mean((YPred - YTrue).^2));

MAE = mean(abs(YPred - YTrue));

MSE = mean((YPred - YTrue).^2);

MAPE = mean(abs((YTrue - YPred)./(YTrue+eps)))*100;

%% ===============================================================
% Classification Metrics
%% ===============================================================

disp("Computing classification metrics...");

TrueON = YTrue >= threshold;

PredON = YPred >= threshold;

TP = sum(TrueON & PredON);

FP = sum(~TrueON & PredON);

FN = sum(TrueON & ~PredON);

TN = sum(~TrueON & ~PredON);

Precision = TP/(TP+FP+eps);

Recall = TP/(TP+FN+eps);

F1 = 2*(Precision*Recall)/(Precision+Recall+eps);

Accuracy = (TP+TN)/numel(YTrue);

%% ===============================================================
% Engineering Summary
%% ===============================================================

disp(" ");

disp("===============================================================");
disp("          EQ1 ENGINEERING VALIDATION SUMMARY");
disp("===============================================================");

fprintf("Dataset               : UK-DALE\n");
fprintf("Target Appliance      : Water Heater (Boiler)\n");
fprintf("Model                 : Seq2Point CNN\n");
fprintf("Window Length         : %d samples\n",windowLength);

fprintf("Training Time         : %.2f minutes\n",...
    trainingTime/60);

fprintf("Training Windows      : 25000\n");
fprintf("Validation Windows    : 5000\n");
fprintf("Testing Windows       : 5000\n");

disp(" ");

disp("---------------- Regression ----------------");

fprintf("RMSE                  : %.4f W\n",RMSE);
fprintf("MAE                   : %.4f W\n",MAE);
fprintf("MSE                   : %.4f\n",MSE);
fprintf("MAPE                  : %.2f %%\n",MAPE);

disp(" ");

disp("---------------- Classification ----------------");

fprintf("Threshold             : %.1f W\n",threshold);

fprintf("Precision             : %.4f\n",Precision);
fprintf("Recall                : %.4f\n",Recall);
fprintf("F1 Score              : %.4f\n",F1);
fprintf("Accuracy              : %.4f\n",Accuracy);

disp(" ");

disp("---------------- Confusion Matrix ----------------");

fprintf("TP                    : %d\n",TP);
fprintf("FP                    : %d\n",FP);
fprintf("FN                    : %d\n",FN);
fprintf("TN                    : %d\n",TN);

disp("===============================================================");

%% ===============================================================
% Export Metrics
%% ===============================================================

metrics = table(...
    RMSE,...
    MAE,...
    MSE,...
    MAPE,...
    Precision,...
    Recall,...
    F1,...
    Accuracy,...
    TP,...
    FP,...
    FN,...
    TN);

writetable(metrics,"eq1_metrics.csv");

%% ===============================================================
% Save Prediction Table
%% ===============================================================

predictionTable = table(...
    YTrue,...
    YPred,...
    abs(YPred-YTrue),...
    'VariableNames',...
    {'GroundTruth','Prediction','AbsoluteError'});

writetable(predictionTable,"eq1_predictions.csv");

%% ===============================================================
% Engineering Results Structure
%% ===============================================================

Results.Dataset = "UK-DALE";
Results.Appliance = "Water Heater";

Results.Model = "Seq2Point CNN";

Results.WindowLength = windowLength;

Results.TrainingWindows = 25000;
Results.ValidationWindows = 5000;
Results.TestWindows = 5000;

Results.TrainingTimeSeconds = trainingTime;

Results.Threshold = threshold;

Results.RMSE = RMSE;
Results.MAE = MAE;
Results.MSE = MSE;
Results.MAPE = MAPE;

Results.Precision = Precision;
Results.Recall = Recall;
Results.F1 = F1;
Results.Accuracy = Accuracy;

Results.TP = TP;
Results.FP = FP;
Results.FN = FN;
Results.TN = TN;

save("eq1_results.mat","Results");

%% ===============================================================
% Plot
%% ===============================================================

figure;

plot(YTrue,...
    "LineWidth",1);

hold on

plot(YPred,...
    "LineWidth",1);

grid on

xlabel("Test Window");

ylabel("Power (W)");

title("Ground Truth vs Seq2Point Prediction");

legend("Ground Truth","Prediction");

saveas(gcf,"prediction_vs_groundtruth.png");

%% ===============================================================
% Residual Plot
%% ===============================================================

Residual = YPred - YTrue;

figure

plot(Residual)

grid on

xlabel("Test Window")

ylabel("Residual (W)")

title("Prediction Residual")

saveas(gcf,"residual_plot.png");

%% ===============================================================
% Error Histogram
%% ===============================================================

figure

histogram(Residual,50)

grid on

xlabel("Residual Error (W)")

ylabel("Frequency")

title("Prediction Error Distribution")

saveas(gcf,"error_histogram.png");

%% ===============================================================
% Finished
%% ===============================================================

disp(" ");
disp("===============================================================");
disp("EQ1 Evaluation Complete");
disp("===============================================================");
disp("Generated Files:");
disp("   eq1_metrics.csv");
disp("   eq1_predictions.csv");
disp("   eq1_results.mat");
disp("   prediction_vs_groundtruth.png");
disp("   residual_plot.png");
disp("   error_histogram.png");
disp("===============================================================");