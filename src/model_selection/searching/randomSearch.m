function [bestParam,bestParamScore,bestParamIdx] = randomSearch(objFun,data,paramGrid,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% randomSearch performs pure random search over parameters provided.
% Each parameter or combination of parameters are selected from a uniform
% random distribution. Computation cost remains same regardless of
% parameter grid provided. However, one should bear in mind that it is a
% stochastic searching method, i.e., in each run it might provide different
% results. It is parameterized by number of iteration parameter, which is
% maximum number of iteration that random search performs.
%
% Arguements:
%   objFun = Objective function (e.g., estimator).
%   data = Data structure including X and y matrices. 
%   paramGrid = Parameter grid.
%   nIter: Number of iteration (default = 60).
%   bestParamMethod = Method to choose best parameter ('max','ose','median','min', default = "max").
%       Check help section of bestParamMetric for detailed information.     
%   sortDirection = Direction of sorting ('ascend' or 'descend', default= 'ascend'). 
%       Check help section of bestParamMetric for detailed information.
%   kFold = Number of CV folds (default = 10). 
%   ifParallel = Parallelize CV (1 or 0, default = 0). 
%
% Output:
%   bestParam = Parameter with best CV score. 
%   bestParamScore = Cross-validation score of best parameters found. 
%   bestParamIdx = Index of best parameter in a parameter space given.
%
% Emin Serin - 01.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Input
% validate parameters and return default parameters if no provided. 
searchInputs = get_searchInputs('randomSearch',varargin{:}); 
nIter = searchInputs.nIter; kFold = searchInputs.kFold;
%%
% Set the random seed based on current time.
rng('shuffle');

% Draw an uniform random sample from parameter space without replacement.
[~,nComb] = get_paramGridShapeComb(paramGrid);
randomParamSpace = randperm(nComb,nIter);

% Preallocation
CVscore = zeros(kFold,nIter);

for iter = 1 : nIter
    paramGridIdx = randomParamSpace(iter);
    params = get_paramItem(paramGrid,paramGridIdx);
    CVfun = @(data) objFun(data,params);
    % Run cv feature selection.
    CVscore(:,iter) = crossValidation(CVfun,data,...
        'ifParallel',searchInputs.ifParallel,...
        'kFold',kFold);
end

% Find best parameter
[bestParam,bestParamScore,bestParamIdx] = get_bestParam(CVscore,randomParamSpace,paramGrid...
    ,'metric',searchInputs.bestParamMethod,...
    'sortDirection',searchInputs.sortDirection);
end
