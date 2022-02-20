function varargout = compute_mRCVscore(truePredLabels, metric)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute_mRCVscore computes mean repeated CV scores using given
% true and predicted labels.  
%
% Arguments:
%   truePredLabels = Cell containing true and predicted labels obtained
%       from each outer folds from each repetitions of CV structure.
%   metric = Performance metric.
%
% Output:
%   meanCVscore = Mean CV score.
%   stdCVscore = Standard Deviation of CV scores. 
%   CI = Confidence interval values, [lower bound, upper bound]
%
% Emin Serin - 18.02.2022
%
% See also: compute_modelMetrics, compute_CI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
varargout = cell(3,1);

dims = size(truePredLabels);
repCViter = dims(1);
nFold = dims(2);
scores = zeros(repCViter,nFold);
for r = 1:repCViter
    for n = 1: nFold
        scores(r,n) = compute_modelMetrics(truePredLabels{r,n,1}, ...
            truePredLabels{r,n,2}, metric);
    end
end
repCVScores = mean(scores,2);
varargout{1} = mean(repCVScores);
varargout{2} = std(repCVScores);
varargout{3} = compute_CI(repCVScores);
end
