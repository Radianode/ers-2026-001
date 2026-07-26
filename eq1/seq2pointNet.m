function lgraph = seq2pointNet(win)
%SEQ2POINTNET Seq2Point CNN for NILM (MATLAB R2025b)
%
% Input:
%   win - Window length (e.g. 599)
%
% Output:
%   lgraph - Layer graph for trainNetwork

layers = [

    sequenceInputLayer(1,...
        Name="input",...
        MinLength=win,...
        Normalization="none")

    convolution1dLayer(10,30,...
        Padding="same",...
        Name="conv1")
    reluLayer(Name="relu1")

    convolution1dLayer(8,30,...
        Padding="same",...
        Name="conv2")
    reluLayer(Name="relu2")

    convolution1dLayer(6,40,...
        Padding="same",...
        Name="conv3")
    reluLayer(Name="relu3")

    convolution1dLayer(5,50,...
        Padding="same",...
        Name="conv4")
    reluLayer(Name="relu4")

    convolution1dLayer(5,50,...
        Padding="same",...
        Name="conv5")
    reluLayer(Name="relu5")

    % Collapse temporal dimension
    globalAveragePooling1dLayer(Name="gap")

    fullyConnectedLayer(1024,...
        Name="fc1")
    reluLayer(Name="relu6")

    dropoutLayer(0.2,...
        Name="dropout")

    fullyConnectedLayer(1,...
        Name="fc2")

    regressionLayer(Name="output")
    ];

lgraph = layerGraph(layers);

end