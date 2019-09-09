function [bestParam,bestParamScore,bestParamIdx] = gridSearch(objFun,data,paramGrid,varargin)
% gridSearch performs grid search over hyperparameter space provided and
% returns best hyperparameter combination.
%   
% Arguements
%   objFun = Objective function (e.g., estimator).
%   data = Data structure including X and y matrices. 
%   paramGrid = Parameter grid.
%   kFold = Number of CV folds (default = 10). 
%   ifParallel = Parallelize CV (1 or 0, default = 0). 
%   bestParamMethod = Method to choose best parameter ('max','ose','median','min', default = "max").
%       Check help section of bestParamMetric for detailed information.     
%   sortDirection = Direction of sorting ('ascend' or 'descend', default= 'ascend'). 
%       Check help section of bestParamMetric for detailed information.
%
% Output:
%   bestParams = Best hyperparameter combination choosen. 
%   bestParamScore = Score of best hyperparameters choosen. 
%
% Emin Serin - 10.08.2019
%
%% Input
% validate parameters and return default parameters if no provided. 
searchInputs = get_searchInputs('gridSearch',varargin{:}); 
kFold = searchInputs.kFold; 
%% Main loop
[~,nComb] = get_paramGridShapeComb(paramGrid); % get total number of combinations. 
paramSpaceIdx = linspace(1,nComb,nComb); 

CVscore = zeros(kFold,nComb);
for iter = 1:nComb
    params = get_paramItem(paramGrid,iter);
    CVfun = @(data) objFun(data,params);
    % Run cv feature selection.
    CVscore(:,iter) = crossValidation(CVfun,data,...
        'ifParallel',searchInputs.ifParallel,...
        'kFold',kFold);
end

% Return best parameters. 
[bestParam,bestParamScore,bestParamIdx] = get_bestParam(CVscore,paramSpaceIdx,paramGrid...
    ,'metric',searchInputs.bestParamMethod,...
    'sortDirection',searchInputs.sortDirection);
end

