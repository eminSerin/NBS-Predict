function [idx] = gen_cvpartition(y,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   gen_cvpartition generates k-fold cross-validation random or sequential
%       partition for data of specified size. It returns a structure which
%       consists of test and train indices for each iteration.
%   Input:
%       y: labels.
%       kFold: number of cv folds (default: 10).
%       ifRand: if randomized (default: 1)
%   Output:
%       idx = Structure of test and train indices.
%
%   Emin Serin - Berlin School of Mind and Brain, HU Berlin
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Length of y vector.
leny = length(y);

% Input parser.
numvarargs = length(varargin);
if numvarargs > 3
    % maximum number of optional inputs.
    error('too many inputs.')
end
optargs = {10,1}; % default inputs.
optargs(1:numvarargs) = varargin; %overwrite given inputs to defaults.
[kFold,ifRand] = optargs{:};

if kFold == -1
    % If loocv, the number of folds is equal to number of observation.
    kFold = leny;
end

% Preallocate
idx = struct('testIdx', cell(1, kFold), 'trainIdx', cell(1, kFold));


CVFolds = mod(1:leny, kFold) + 1; % Create sequence of cv folds.

if ifRand
    % Shuffle cv indices if random.
    CVFolds = CVFolds(randperm(length(CVFolds)));
else
    % Sequential cv.
    CVFolds = sort(CVFolds);
end

for cFold = 1: kFold
    % Find train and test index for each iteration and store in a structure
    idx(cFold).testIdx = CVFolds == cFold; % test index
    idx(cFold).trainIdx = ~idx(cFold).testIdx; % train index.
end

end

