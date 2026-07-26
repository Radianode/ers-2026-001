function [dsTrain,dsVal,dsTest] = makeWindows(matFile,win,splitCfg)
%MAKEWINDOWS Create streaming datastores for Seq2Point NILM training.
%
% Inputs
%   matFile   - MAT-file containing variables:
%                 agg : aggregate power signal
%                 app : appliance power signal
%   win       - Window length (e.g. 599)
%   splitCfg  - Struct with fields:
%                 train
%                 val
%                 test
%
% Outputs
%   dsTrain, dsVal, dsTest
%       Datastores returning {predictor,response}
%

arguments
    matFile (1,:) char
    win (1,1) double {mustBePositive,mustBeInteger}
    splitCfg struct
end

%% Open MAT-file without loading into memory

m = matfile(matFile);

nSamples = size(m,"agg",1);

nWindows = nSamples - win + 1;

if nWindows <= 0
    error("Window length exceeds signal length.");
end

%% Split indices

idx = (1:nWindows)';

nTrain = floor(splitCfg.train*nWindows);
nVal   = floor(splitCfg.val*nWindows);

idxTrain = idx(1:nTrain);

idxVal = idx(nTrain+1 : nTrain+nVal);

idxTest = idx(nTrain+nVal+1 : end);

%% Create datastores

dsTrain = arrayDatastore(idxTrain,...
    IterationDimension=1);

dsVal = arrayDatastore(idxVal,...
    IterationDimension=1);

dsTest = arrayDatastore(idxTest,...
    IterationDimension=1);

%% Transform into Seq2Point observations

dsTrain = transform(dsTrain,...
    @(idx) windowReader(idx,m,win));

dsVal = transform(dsVal,...
    @(idx) windowReader(idx,m,win));

dsTest = transform(dsTest,...
    @(idx) windowReader(idx,m,win));

%% Display summary

fprintf("\n");

fprintf("=========================================\n");
fprintf(" Window Dataset Summary\n");
fprintf("=========================================\n");

fprintf("MAT File           : %s\n",matFile);

fprintf("Total Samples      : %d\n",nSamples);

fprintf("Window Length      : %d\n",win);

fprintf("Valid Windows      : %d\n",nWindows);

fprintf("-----------------------------------------\n");

fprintf("Training Windows   : %d\n",numel(idxTrain));

fprintf("Validation Windows : %d\n",numel(idxVal));

fprintf("Testing Windows    : %d\n",numel(idxTest));

fprintf("=========================================\n\n");

end