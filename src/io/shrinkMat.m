function [edgeMat, nodes, edgeIdx] = shrinkMat(data, preEdgeIdx)
% SHRINKMAT Extracts upper-triangular edge values from correlation matrices.
%
%   [edgeMat, nodes, edgeIdx] = shrinkMat(data)
%   [edgeMat, nodes, edgeIdx] = shrinkMat(data, preEdgeIdx)
%
% Arguments:
%   data       - 2D (nodes x nodes) or 3D (nodes x nodes x subjects) matrix.
%   preEdgeIdx - Pre-existing linear indices for edge extraction (optional).
%                When provided, SMR filtering is skipped.
%
% Output:
%   edgeMat  - 2D matrix (subjects x edges).
%   nodes    - Number of nodes.
%   edgeIdx  - Linear indices of extracted edges.
%
% Last edited by Emin Serin, 14.05.2026.

%% Validate input dimensions.
dataShape = size(data);
dataDim = ndims(data);          % more robust than length(size(data))
assert(ismember(dataDim, [2, 3]), ...
    'Data provided is not a 2D or 3D matrix!')
assert(dataShape(1) == dataShape(2), ...
    'First two dimensions must be equal (nodes x nodes). See help!')
nodes = dataShape(1);

if dataDim == 2
    subjects = 1;
else
    subjects = dataShape(3);
end

%% Determine edge indices.
if nargin < 2 || isempty(preEdgeIdx)
    edgeIdx = find(triu(true(nodes), 1));   % double indices (safe for large N)
    preEdgeIdx = [];
else
    edgeIdx = preEdgeIdx;
end

%% Extract edges.
edgeMat = zeros(subjects, numel(edgeIdx));

if dataDim == 2
    edgeMat(1, :) = data(edgeIdx);
else
    for i = 1:subjects
        cMat = data(:, :, i);
        if ~is_symmetric(cMat)
            warning('Given matrix is not symmetric! Data index: %d', i)
        end
        edgeMat(i, :) = cMat(edgeIdx);
    end
end

%% SMR filtering (skip for adjacency matrices and when preEdgeIdx is given).
ifAdjMat = (numel(unique(edgeMat)) == 2) && all(ismember(edgeMat(:), [0, 1]));

if ~ifAdjMat && isempty(preEdgeIdx)
    SMR = 0.1;  % At least 10% nonzero values required.
    SMRmask = mean(edgeMat ~= 0 & ~isnan(edgeMat), 1) > SMR;
    edgeMat = edgeMat(:, SMRmask);
    edgeIdx = edgeIdx(SMRmask);
end
end
