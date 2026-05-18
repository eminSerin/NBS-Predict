function results = compare_modelScores(modelAScores, modelBScores, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compare_modelScores compares two ML algorithms using paired CV scores.
%
% Usage:
%   results = compare_modelScores(modelAScores, modelBScores)
%   results = compare_modelScores(modelAScores, modelBScores, ...
%       nullModelAScores, nullModelBScores)
%
% Arguments:
%   modelAScores = Model A scores as nRepeats x kFold.
%   modelBScores = Model B scores as nRepeats x kFold.
%   nullModelAScores = Model A null scores as nPermutations x nRepeats x kFold.
%   nullModelBScores = Model B null scores as nPermutations x nRepeats x kFold.
%
% Output:
%   results.optionA = Nadeau-Bengio corrected repeated-k-fold t-test.
%   results.optionB = Paired permutation test, returned only when null
%       scores are provided.
%
% Both tests are one-tailed and test whether model A performs better than
% model B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

results.optionA = corrected_repeatedKFoldTtest(modelAScores, modelBScores);

if nargin == 4
    results.optionB = paired_permutationScoreTest(modelAScores, modelBScores, ...
        varargin{1}, varargin{2});
elseif nargin ~= 2
    error(['Use compare_modelScores(modelAScores, modelBScores) or ', ...
        'compare_modelScores(modelAScores, modelBScores, nullModelAScores, nullModelBScores).']);
end
end

function results = corrected_repeatedKFoldTtest(modelAScores, modelBScores)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% corrected_repeatedKFoldTtest compares paired repeated-CV scores.
%
% Arguments:
%   modelAScores = Model A scores as nRepeats x kFold.
%   modelBScores = Model B scores as nRepeats x kFold.
%
% Output:
%   results = Structure with the observed statistic and one-tailed p-value
%       for A > B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

check_scoreMatrix(modelAScores, modelBScores);

scoreDiff = double(modelAScores(:) - modelBScores(:));
nPairs = numel(scoreDiff);
kFold = size(modelAScores, 2);

meanDiff = mean(scoreDiff);
varDiff = var(scoreDiff, 0);
correctedSE = sqrt((1 / nPairs + 1 / (kFold - 1)) * varDiff);
df = nPairs - 1;

if correctedSE == 0
    if meanDiff > 0
        tStatistic = inf;
        pValue = 0;
    else
        tStatistic = 0;
        pValue = 1;
    end
else
    tStatistic = meanDiff / correctedSE;
    pValue = 1 - tcdf(tStatistic, df);
end

results = struct;
results.statistic = tStatistic;
results.pValue = pValue;
results.meanDifference = meanDiff;
results.meanScoreA = mean(modelAScores(:));
results.meanScoreB = mean(modelBScores(:));
results.correctedSE = correctedSE;
results.df = df;
end

function results = paired_permutationScoreTest(modelAScores, modelBScores, ...
    nullModelAScores, nullModelBScores)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% paired_permutationScoreTest compares observed and null score differences.
%
% Arguments:
%   modelAScores = Model A scores as nRepeats x kFold.
%   modelBScores = Model B scores as nRepeats x kFold.
%   nullModelAScores = Model A null scores as nPermutations x nRepeats x kFold.
%   nullModelBScores = Model B null scores as nPermutations x nRepeats x kFold.
%
% Output:
%   results = Structure with the observed statistic and one-tailed
%       permutation p-value for A > B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

check_scoreMatrix(modelAScores, modelBScores);
assert(isequal(size(nullModelAScores), size(nullModelBScores)), ...
    'Null score arrays must have the same size.');
assert(ndims(nullModelAScores) == 3, ...
    'Null score arrays must be nPermutations x nRepeats x kFold.');
assert(size(nullModelAScores, 2) == size(modelAScores, 1) && ...
    size(nullModelAScores, 3) == size(modelAScores, 2), ...
    'Null score arrays must match modelAScores and modelBScores in repeats and folds.');

observedStatistic = mean(modelAScores(:) - modelBScores(:));
nullDifferences = nullModelAScores - nullModelBScores;
nullStatistics = squeeze(mean(mean(nullDifferences, 3), 2));

nPermutations = numel(nullStatistics);
pValue = (sum(nullStatistics >= observedStatistic) + 1) / (nPermutations + 1);

results = struct;
results.statistic = observedStatistic;
results.pValue = pValue;
results.nullStatistics = nullStatistics;
results.meanScoreA = mean(modelAScores(:));
results.meanScoreB = mean(modelBScores(:));
end

function check_scoreMatrix(modelAScores, modelBScores)
assert(ismatrix(modelAScores) && isnumeric(modelAScores), ...
    'modelAScores must be a numeric nRepeats x kFold matrix.');
assert(ismatrix(modelBScores) && isnumeric(modelBScores), ...
    'modelBScores must be a numeric nRepeats x kFold matrix.');
assert(isequal(size(modelAScores), size(modelBScores)), ...
    'modelAScores and modelBScores must have the same size.');
assert(size(modelAScores, 1) >= 1 && size(modelAScores, 2) > 1, ...
    'Scores must be supplied as nRepeats x kFold, with kFold > 1.');
assert(all(isfinite(modelAScores(:))) && all(isfinite(modelBScores(:))), ...
    'Scores must not contain NaN or Inf.');
end
