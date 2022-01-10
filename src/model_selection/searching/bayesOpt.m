function [bestParam,bestParamScore,bestParamIdx] = bayesOpt(objFun,...
    data,paramGrid,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bayesOpt performs bayesian optimization over parameters provided.
%
% Arguments:
%   objFun = Objective function (e.g., estimator).
%   data = Data structure including X and y matrices. 
%   paramGrid = Parameter grid.
%   nIter: Number of iteration (default = 60).
%   kFold = Number of CV folds (default = 10). 
%   metric = Performance metric used to evaluate model performance. 
%   numCores = Number of CPU cores to use (default = 1).
%   acquisitionFun = Acquisition function name (default: expected-improvement):
%       probability-of-improvement
%       expected-improvement
%       lower-confidence-bound
%   randomState: Controls the randomness. Pass an integer value for
%       reproducible results (default = 'shuffle'). 
%
% Output:
%   bestParam = Parameter with best CV score. 
%   bestParamScore = Cross-validation score of best parameters found. 
%   bestParamIdx = Index of best parameter in a parameter space given.
%
% Reference:
%   https://au.mathworks.com/help/stats/bayesopt.html
%
% Emin Serin - 05.07.2020
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input
% validate parameters and return default parameters if no provided. 
searchInputs = get_searchInputs('bayesOpt',varargin{:}); 
nIter = searchInputs.nIter; kFold = searchInputs.kFold;
numCores = searchInputs.numCores; bestParamMethod = searchInputs.bestParamMethod;
%%
% Draw an uniform random sample from parameter space without replacement.
[~,nComb] = get_paramGridShapeComb(paramGrid);
if nIter > nComb
    nIter = nComb; 
end

nFeatureSpace = optimizableVariable('hyperParameters',[1,nComb],'Type','integer');
fun = @(paramIdx) cvFun(objFun,data,paramIdx,paramGrid,numCores,kFold,bestParamMethod);
results = bayesopt(fun,nFeatureSpace,...
    'MaxObjectiveEvaluations',nIter,...
    'Verbose',0,'PlotFcn',[],...
    'AcquisitionFunctionName',searchInputs.acquisitionFun); 

    function [CVerror] = cvFun(objFun,data,paramIdx,paramGrid,numCores,kFold,bestParamMethod)
        paramIdx = table2array(paramIdx);
        params = get_paramItem(paramGrid,paramIdx);
        CVfun = @(data) objFun(data,params);
        % Run cv feature selection.
        cvResults = crossValidation(CVfun,data,...
            'numCores',numCores,'kFold',kFold);
        CVerror = mean([cvResults.score]); 
        if strcmpi(bestParamMethod,'max')
            % reverse CV score as bayesian optimization minimizes.
             CVerror = 1 - CVerror; 
        end
    end
bestParamIdx = table2array(results.bestPoint);
if strcmpi(bestParamMethod,'max')
    bestParamScore = 1-results.MinEstimatedObjective;
else
    bestParamScore = results.MinEstimatedObjective;
end
bestParam = get_paramItem(paramGrid,bestParamIdx);
 end
