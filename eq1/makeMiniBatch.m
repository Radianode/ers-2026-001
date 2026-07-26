function [X,Y] = makeMiniBatch(data)
%MAKEMINIBATCH Convert one datastore observation into trainnet format.
%
% Input
% -----
% data : 1x2 cell
%        {599x1 single, scalar single}
%
% Output
% ------
% X : 599x1x1x1 single
% Y : 1x1 single

arguments
    data cell
end

% Validate input
if numel(data) ~= 2
    error('Expected a 1x2 cell array {window,target}.');
end

% Aggregate window
X = single(data{1});

% Ensure column vector
X = reshape(X,[],1);

% Convert to H×W×C×N format
X = reshape(X,size(X,1),1,1,1);

% Target
Y = single(data{2});

% Ensure scalar
Y = reshape(Y,1,1);

end