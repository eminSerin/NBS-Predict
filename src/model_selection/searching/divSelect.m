function [bestParam,bestParamScore,bestParamIdx] = divSelect(objFun,data,paramGrid,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% divSelect performs "divide and select" search algorithm over parameters.
% It is specific to feature selection problems, and assumes feature space
% is ranked. It performs division and selection on percentiles, that is it
% picks n number of linearly increasing percentiles (e.g., 0.01th, 10th,
% 20th) and compares their performance. Following finding the percentile
% with best performance, it performs another run of percentile comparison
% using percentile space between best percentile and the closests lower
% percentile neighbour.
%
% Arguements:
%   fun = Optimization function (e.g., estimator).
%   paramGrid = Parameter grid.
%   selRound: Number of selection rounds (default = 3).
%   nDiv = Number of parts into which percentile space divided (default = 20).
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
% Reference:
%   Serin, E. & Kruschwitz, J.,(n.d.) NBS-Predict: The Prediction-based Extension of Network-based Statistic.
%
% Emin Serin - 01.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Input
% validate parameters and return default parameters if no provided. 
searchInputs = get_searchInputs('divSelect',varargin{:}); 
kFold = searchInputs.kFold; nDiv = searchInputs.nDiv;

%%
CVscore = zeros(kFold,nDiv); % Preallocation

% Total number of parameters.
[~,nComb] = get_paramGridShapeComb(paramGrid);

% Performs divide and select feature selection.
pU = nComb;
pL = 1;
k = 1;
while (k <= searchInputs.selRound) && (pU > 1)
    cParamSpace = round(linspace(pL,pU,nDiv));
    
    for iter = 1: nDiv
        % Run cv feature selection.
        featureSelParam = cParamSpace(iter);
        params = get_paramItem(paramGrid,featureSelParam);
        CVfun = @(data) objFun(data,params);
        % Run cv feature selection.
        CVscore(:,iter) = crossValidation(CVfun,data,...
            'ifParallel',searchInputs.ifParallel,...
            'kFold',kFold);
    end
    
    % Find best parameter
    [bestParam,bestParamScore,bestParamIdx] = get_bestParam(CVscore,cParamSpace,paramGrid,...
        'metric',searchInputs.bestParamMethod,...
        'sortDirection',searchInputs.sortDirection);
    pU = bestParamIdx;
    pL = round(pU - (cParamSpace(end)-pL)/(nDiv-1));
    k = k + 1;
end
end
