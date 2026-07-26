function [mu,sigma,matFileOut] = normalizeTraining(matFile,splitCfg)
%NORMALIZETRAINING Compute normalization constants using a v7.3 MAT-file.
%
% If the supplied MAT-file is not v7.3, it is automatically converted
% once to "<original>_v73.mat". Subsequent runs use the v7.3 file.

arguments
    matFile (1,:) char
    splitCfg struct
end

%% ------------------------------------------------------------------------
% Create v7.3 copy if required
%% ------------------------------------------------------------------------

[pathstr,name,ext] = fileparts(matFile);

matFileOut = fullfile(pathstr,[name '_v73' ext]);

if ~isfile(matFileOut)

    fprintf('Creating v7.3 MAT-file...\n');

    S = load(matFile);

    if ~isfield(S,'agg') || ~isfield(S,'app')
        error('MAT file must contain variables "agg" and "app".');
    end

    agg = S.agg;
    app = S.app;

    save(matFileOut,'agg','app','-v7.3');

    clear S agg app

    fprintf('Saved:\n%s\n\n',matFileOut);

end

%% ------------------------------------------------------------------------
% Open v7.3 file
%% ------------------------------------------------------------------------

m = matfile(matFileOut);

info = whos(m,'agg');

N = info.size(1);

trainEnd = floor(splitCfg.train*N);

%% ------------------------------------------------------------------------
% Read only training aggregate
%% ------------------------------------------------------------------------

aggTrain = double(m.agg(1:trainEnd,1));

mu = mean(aggTrain,'omitnan');
sigma = std(aggTrain,0,'omitnan');

if sigma < eps
    sigma = 1;
end

save(fullfile(pathstr,'normalization.mat'),'mu','sigma');

%% ------------------------------------------------------------------------
% Report
%% ------------------------------------------------------------------------

fprintf('\n');
fprintf('============================================\n');
fprintf(' Training Normalization\n');
fprintf('============================================\n');
fprintf('MAT File          : %s\n',matFileOut);
fprintf('Total Samples     : %d\n',N);
fprintf('Training Samples  : %d\n',trainEnd);
fprintf('Mean (mu)         : %.6f\n',mu);
fprintf('Std (sigma)       : %.6f\n',sigma);
fprintf('Saved             : normalization.mat\n');
fprintf('============================================\n\n');

end