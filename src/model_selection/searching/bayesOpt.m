function [bestParam,bestParamScore,bestParamIdx] = bayesOpt(objFun,data,paramGrid,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bayesOpt performs bayesian optimization over parameters provided.
%
% Arguements:
%   objFun = Objective function (e.g., estimator).
%   data = Data structure including X and y matrices. 
%   paramGrid = Parameter grid.
%   nIter: Number of iteration (default = 60).
%   kFold = Number of CV folds (default = 10). 
%   ifParallel = Parallelize CV (1 or 0, default = 0). 
%   acquisitionFun = Acquisition function name (default: expected-improvement):
%       probability-of-improvement
%       expected-improvement
%       lower-confidence-bound
%
% Output:
%   bestParam = Parameter with best CV score. 
%   bestParamScore = Cross-validation score of best parameters found. 
%   bestParamIdx = Index of best parameter in a parameter space given.
%
% Reference:
%   https://au.mathworks.com/help/stats/bayesopt.html
%
% Emin Serin - 10.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input
% validate parameters and return default parameters if no provided. 
searchInputs = get_searchInputs('bayesOpt',varargin{:}); 
nIter = searchInputs.nIter; kFold = searchInputs.kFold;
ifParallel = searchInputs.ifParallel;
%%
% Draw an uniform random sample from parameter space without replacement.
[~,nComb] = get_paramGridShapeComb(paramGrid);

% nFeatureSpace = linspace(1,nTotalFeatures,nTotalFeatures);
nFeatureSpace = optimizableVariable('nFirstFeatures',[1,nComb],'Type','integer');
fun = @(paramIdx) cvFun(objFun,data,paramIdx,paramGrid,ifParallel,kFold);
results = bayesopt(fun,nFeatureSpace,...
    'MaxObjectiveEvaluations',nIter,...
    'Verbose',0,'PlotFcn',[],...
    'AcquisitionFunctionName',searchInputs.acquisitionFun); % 

    function [CVerror] = cvFun(objFun,data,paramIdx,paramGrid,ifParallel,kFold)
        paramIdx = table2array(paramIdx);
        params = get_paramItem(paramGrid,paramIdx);
        CVfun = @(data) objFun(data,params);
        % Run cv feature selection.
        CVscores = crossValidation(CVfun,data,...
            'ifParallel',ifParallel,'kFold',kFold);
        CVerror = 1-mean(CVscores,1); % reverse CV score as bayesian optimization minimizes. 
    end
bestParamIdx = table2array(results.bestPoint);
bestParamScore = 1-results.MinEstimatedObjective;
bestParam = get_paramItem(paramGrid,bestParamIdx);
 end
