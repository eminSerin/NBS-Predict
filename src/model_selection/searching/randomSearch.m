function [bestParam,bestParamScore,bestParamIdx] = randomSearch(objFun,...
    data,paramGrid,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% randomSearch performs pure random search over parameters provided.
% Each parameter or combination of parameters are selected from a uniform
% random distribution. Computation cost remains same regardless of
% parameter grid provided. However, one should bear in mind that it is a
% stochastic searching method, i.e., in each run it might provide different
% results. It is parameterized by number of iteration parameter, which is
% maximum number of iteration that random search performs.
%
% Arguments:
%   objFun = Objective function (e.g., estimator).
%   data = Data structure including X and y matrices. 
%   paramGrid = Parameter grid.
%   nIter: Number of iteration (default = 20).
%   bestParamMethod = Method to choose best parameter ('best','median', default = "best").
%       Check help section of bestParamMetric for detailed information. 
%   metric = Performance metric used to evaluate model performance. 
%   kFold = Number of CV folds (default = 10). 
%   numCores = Number of CPU cores to use (default = 1).
%   randomState: Controls the randomness. Pass an integer value for
%       reproducible results (default = 'shuffle').  
%
% Output:
%   bestParam = Parameter with best CV score. 
%   bestParamScore = Cross-validation score of best parameters found. 
%   bestParamIdx = Index of best parameter in a parameter space given.
%
% Emin Serin - 05.07.2020
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% Input
% validate parameters and return default parameters if no provided. 
searchInputs = get_searchInputs('randomSearch',varargin{:}); 
nIter = searchInputs.nIter; kFold = searchInputs.kFold;

% Draw an uniform random sample from parameter space without replacement.
[~,nComb] = get_paramGridShapeComb(paramGrid);
if nIter > nComb
    nIter = nComb; 
end
randomParamSpace = randperm(nComb,nIter);

% Preallocation
CVscore = zeros(kFold,nIter);
for iter = 1 : nIter
    paramGridIdx = randomParamSpace(iter);
    params = get_paramItem(paramGrid,paramGridIdx);
    CVfun = @(data) objFun(data,params);
    cvResults = crossValidation(CVfun,data,...
        'numCores',searchInputs.numCores,...
        'kFold',kFold);
    % Run cv feature selection.
    CVscore(:,iter) = [cvResults.score];
end

% Find best parameter
[bestParam,bestParamScore,bestParamIdx] = get_bestParam(CVscore,...
    randomParamSpace,paramGrid,searchInputs.bestParamMethod);
end
