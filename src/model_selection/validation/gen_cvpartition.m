function [idx] = gen_cvpartition(y,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gen_cvpartition generates k-fold cross-validation partitions. It returns
%     a structure which consists of test and train indices for each
%     iteration. Stratified folds can be generated for classification
%     problems.
%
% Arguments:
%     y: labels.
%     kFold: number of cv folds (default: 10).
%     ifRand: retained for backward compatibility; cvpartition generates
%         randomized folds controlled by the active random stream.
%     ifStratified: if class labels should be balanced across folds
%         (default: 0).
%
% Output:
%     idx = Structure of test and train indices.
%
% Emin Serin - Berlin School of Mind and Brain, HU Berlin
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Length of y vector.
leny = length(y);

% Input parser.
numvarargs = length(varargin);
if numvarargs > 3
    % maximum number of optional inputs.
    error('too many inputs.')
end
optargs = {10,1,0}; % default inputs.
optargs(1:numvarargs) = varargin; %overwrite given inputs to defaults.
[kFold,~,ifStratified] = optargs{:};

if kFold == -1
    % If loocv, the number of folds is equal to number of observation.
    kFold = leny;
end

% Preallocate
idx = struct('testIdx', cell(1, kFold), 'trainIdx', cell(1, kFold));


if ifStratified
    yClass = get_classLabels(y);
    cvp = cvpartition(yClass,'KFold',kFold);
else
    cvp = cvpartition(leny,'KFold',kFold);
end

for cFold = 1: kFold
    % Find train and test index for each iteration and store in a structure
    idx(cFold).testIdx = test(cvp,cFold); % test index
    idx(cFold).trainIdx = training(cvp,cFold); % train index.
end

end

function [yClass] = get_classLabels(y)
if isvector(y) || size(y, 2) == 1
    yClass = y(:);
else
    yClass = y(:,2);
end
end
