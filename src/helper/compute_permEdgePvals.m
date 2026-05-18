function [pVals, observedEdgeValues, permEdgeValues] = compute_permEdgePvals(observedEdgeValues, permEdgeValues)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute_permEdgePvals computes edge-wise permutation p-values.
%
% Arguments:
%   observedEdgeValues = Observed edge values as nEdges x nFold, or nEdges x 1.
%       If nEdges x nFold is provided, values are averaged across folds.
%   permEdgeValues = Permutation edge values as nPerm x nEdges. A legacy
%       nPerm x nEdges x nFold input is also accepted and averaged across
%       folds before p-value computation.
%
% Output:
%   pVals = Edge-wise p-values as nEdges x 1. The observed edge value is
%       included in the permutation distribution:
%       (sum(permutation >= observed) + 1) / (nPerm + 1).
%   observedEdgeValues = Fold-averaged observed edge values as nEdges x 1.
%   permEdgeValues = Fold-averaged permutation edge values as nPerm x nEdges.
%
% See also: run_NBSPredict
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

assert(isnumeric(observedEdgeValues) || islogical(observedEdgeValues), ...
    'Observed edge values must be numeric or logical.');
assert(isnumeric(permEdgeValues) || islogical(permEdgeValues), ...
    'Permutation edge values must be numeric or logical.');

if isvector(observedEdgeValues)
    observedEdgeValues = observedEdgeValues(:);
else
    observedEdgeValues = mean(single(observedEdgeValues), 2);
end

if ndims(permEdgeValues) == 3
    permEdgeValues = mean(single(permEdgeValues), 3);
else
    permEdgeValues = single(permEdgeValues);
end

nPerm = size(permEdgeValues, 1);
nEdges = numel(observedEdgeValues);
assert(size(permEdgeValues, 2) == nEdges, ...
    'Observed and permutation edge values have incompatible edge counts.');

pVals = (sum(bsxfun(@ge, permEdgeValues, observedEdgeValues'), 1)' + 1) ./ (nPerm + 1);
end
