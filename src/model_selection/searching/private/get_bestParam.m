function [bestParam,bestParamScore,bestParamIdx] = get_bestParam(CVscore,candParamsIdx,paramGrid,metric)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_bestParam returns best parameter in parameter space according to
% given their CV scores.
%
% Arguements:
%   CVscore: Matrix in which prediction scores of parameters across
%       cross-validation folds locate.
%   candParamsIdx: Indices of parameters in parameter space selected by
%       searching algorithm.
%   paramGrid: Structure including parameters.
%   metric = Method to choose best parameter (default = "max").
%       max: Parameter with maximum mean CV score. If kBest parameter is
%           in the parameter grid, it returns most sparse parameter with
%           maximum CV score.
%       min: Parameter with minimum mean CV error. It can be used with
%           regression metrics such as RMSE and MAD (not correlation!).
%       median: Parameter with median of mean CV score.
%
% Output:
%   bestParam = Parameter with best CV score.
%   bestParamScore = Cross-validation score of best parameters found.
%   bestParamIdx = Index of best parameter in a parameter space given.
%
% Warning! If you only perform hyperparameter optimization, please make
% sure that there is no parameter for feature selection (i.e., kBest
% parameter) in your paramGrid structure. If you provide kBest parameter in
% your paramGrid, this function sorts your parameter space according to
% kBest parameter to provide the most sparse parameter with performance of
% interest.
%
% Reference:
%   Hastie, T., Tibshirani, R., Friedman, J. (2009). The elements of
%       statistical learning: data mining, inference and prediction.
%       Springer. (Chapter 7)
%
% Emin Serin - 06.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set default inputs.
% Default parameters.
metricOptions = {'max','median','min'};
if nargin < 4
    metric = 'max';
else
    assert(ismember(metric,metricOptions),'Please enter correct metrics.')
end

% Check if colum vector.
if iscolumn(candParamsIdx)
    candParamsIdx = candParamsIdx';
end

% Compute mean CV score.
meanCVscore = nanmean(CVscore,1);

% Find best param. 
[bestParamScore,bestParamIdx] = feval(['get_',metric,'Param'],meanCVscore);
bestParamIdx = candParamsIdx(bestParamIdx);
bestParam = get_paramItem(paramGrid,bestParamIdx);
end

function [medianParamScore,medianParamIdx] = get_medianParam(meanCVscore)
% getMedianParam returns parameters with median of mean CV score.
nParams = numel(meanCVscore);
[~,oldIdx] = sort(meanCVscore);
medianParamIdx = oldIdx(round(nParams/2));
medianParamScore = meanCVscore(medianParamIdx);
end

function [maxParamScore,maxParamIdx] = get_maxParam(meanCVscore)
% getMaxParam returns parameters with maximum mean CV score.
[maxParamScore,maxParamIdx] = max(meanCVscore); % maximum score (i.e., minimum error).
end

function [minParamScore,minParamIdx] = get_minParam(meanCVscore) %#ok<*DEFNU>
% getMaxParam returns parameters with minimum mean CV error.
[minParamScore,minParamIdx] = max(meanCVscore); % minimum error.
end