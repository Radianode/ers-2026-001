function data = windowReader(idx,m,win)
%WINDOWREADER Read one Seq2Point training sample from a MAT-file.
%
% Inputs:
%   idx - Starting index of the input window
%   m   - MAT-file object
%   win - Window length
%
% Output:
%   data = {X,Y}
%
%       X : 1×win single row vector (aggregate power)
%       Y : scalar single (appliance power at window centre)
%

    % Datastore passes indices inside a cell
    if iscell(idx)
        idx = idx{1};
    end

    % Ensure numeric index
    idx = double(idx);

    % Centre sample of the window
    centre = idx + floor(win/2);

    % Read aggregate window from MAT-file
    % (MAT-file objects require row and column indices)
    X = single(m.agg(idx:idx+win-1, 1)).';

    % Read centre appliance value
    Y = single(m.app(centre, 1));

    % Return predictor/response pair
    data = {X, Y};

end