function [bestParam,bestParamScore,bestParamIdx] = get_bestParam(CVscore,candParamsIdx,paramGrid,varargin)
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
%       ose: One-standard-error rule. Choose most sparse parameter whose
%           CV performance is in one-standard-error of parameter with
%           maximum mean CV score.
%       median: Parameter with median of mean CV score.
%   sortDirection = Direction of sorting (ascend or descend). If you do
%       feature selection, you need rank parameters in a way that you get
%       the most sparse parameter in the first position (default = "ascend").
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
%   Hastie, T., Tibshirani, R., Friedman, J. (2009). The elements of statistical learning: data mining, inference and prediction. Springer. (Chapter 7)
%
% Emin Serin - 06.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set default inputs.
% Default parameters.
defaultVals.sortDirection = 'ascend';  defaultVals.metric = 'max';
metricOptions = {'max','median','ose','min'};
sortDirectionOptions = {'ascend','descend'};

% Input Parser
validationMetric = @(x) any(validatestring(x,metricOptions));
validationSortDirection = @(x) any(validatestring(x,sortDirectionOptions));
p = inputParser(); p.PartialMatching = 0; % deactivate partial matching.
addParameter(p,'metric',defaultVals.metric,validationMetric);
addParameter(p,'sortDirection',defaultVals.sortDirection,validationSortDirection);

% Parse input
parse(p,varargin{:});
sortDirection = p.Results.sortDirection;
metric = p.Results.metric;

% Check if feature selection performed.
paramNames = fieldnames(paramGrid);
ifFeatureSel = any(strcmpi('kBest',paramNames));

% Check if colum vector.
if iscolumn(candParamsIdx)
    candParamsIdx = candParamsIdx';
end

% Compute mean CV score.
meanCVscore = mean(CVscore,1);

switch metric
    case 'max'
        if ifFeatureSel
            [bestParamScore,bestParamIdx,~,~,~,~] = getMaxParamSorted(meanCVscore,candParamsIdx,sortDirection);
        else
            [bestParamScore,bestParamIdx] = getMaxParam(meanCVscore);
        end
    case 'min'
        if ifFeatureSel
            [bestParamScore,bestParamIdx,~,~,~,~] = getMinParamSorted(meanCVscore,candParamsIdx,sortDirection);
        else
            [bestParamScore,bestParamIdx] = getMinParam(meanCVscore);
        end
    case 'ose'
        [bestParamScore,bestParamIdx] = getOSEparam(CVscore,meanCVscore,candParamsIdx,sortDirection);
    case 'median'
        [bestParamScore,bestParamIdx] = getMedianParam(meanCVscore,candParamsIdx);
end
bestParam = get_paramItem(paramGrid,bestParamIdx);

    function [medianParamScore,medianParamIdx] = getMedianParam(meanCVscore,candParamsIdx)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getMedianParam returns parameters with median of mean CV score.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        nParams = numel(meanCVscore);
        [~,oldIdx] = sort(meanCVscore);
        medianParamIdx = candParamsIdx(oldIdx(round(nParams/2)));
        medianParamScore = meanCVscore(bestParamsIdx);
    end

    function [maxParamScore,maxParamIdx] = getMaxParam(meanCVscore)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getMaxParam returns parameters with maximum mean CV score.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        [maxParamScore,maxParamIdx] = max(meanCVscore); % maximum score (i.e., minimum error).
    end

    function [maxParamScore,maxParamIdx,meanCVscoreSorted,maxParamSortedIdx,candSpaceSorted,sortIdx] = ...
            getMaxParamSorted(meanCVscore,candParamsIdx,sortDirection)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getMaxParamSorted returns the most sparse parameter with the
        % maximum mean CV score. It should be used in optimization
        % for feature selection parameters.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % First sort candidates and their scores in ascending order.
        [candSpaceSorted,sortIdx] = sort(candParamsIdx,sortDirection);
        meanCVscoreSorted = meanCVscore(sortIdx);
        
        % Max score
        [maxParamScore,maxParamSortedIdx] = getMaxParam(meanCVscoreSorted);
        maxParamIdx = candSpaceSorted(maxParamSortedIdx);
    end

    function [minParamScore,minParamIdx] = getMinParam(meanCVscore)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getMaxParam returns parameters with minimum mean CV error.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [minParamScore,minParamIdx] = max(meanCVscore); % minimum error.
    end

    function [minParamScore,minParamIdx,meanCVscoreSorted,minParamSortedIdx,candSpaceSorted,sortIdx] = ...
            getMinParamSorted(meanCVscore,candParamsIdx,sortDirection)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getMaxParamSorted returns the most sparse parameter with the
        % maximum mean CV score. It should be used in optimization
        % for feature selection parameters.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % First sort candidates and their scores in ascending order.
        [candSpaceSorted,sortIdx] = sort(candParamsIdx,sortDirection);
        meanCVscoreSorted = meanCVscore(sortIdx);
        
        % Max score
        [minParamScore,minParamSortedIdx] = max(meanCVscoreSorted); % minimum error.
        minParamIdx = candSpaceSorted(minParamSortedIdx);
    end

    function [OSEparamScore,OSEparamIdx] = getOSEparam(CVscore,meanCVscore,candParamsIdx,sortDirection)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Applies one-standard-rule to find optimum parameter. It finds the
        % most parsimonious model whose error is within one standard error
        % of the minimal error. In that way, it adds some bias to model to
        % decrease variance.
        % Reference:
        % Hastie and Tibshirani, 2009, http://www.stat.cmu.edu/~ryantibs/datamining/lectures/19-val2.pdf
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Compute max score.
        [maxParamScore,~,meanCVscoreSorted,maxParamSortedIdx,candSpaceSorted,sortIdx] = ...
            getMaxParamSorted(meanCVscore,candParamsIdx,sortDirection);
        
        CVscoreSorted = CVscore(:,sortIdx); % Sort CV score
        SEmax = std(CVscoreSorted(:,maxParamSortedIdx))/sqrt(size(CVscoreSorted,1)); % Standard error of max param.
        oneStandardError = maxParamScore-SEmax;
        OSEparamSortedIdx = find((candSpaceSorted <= candSpaceSorted(maxParamSortedIdx)) &...
            (meanCVscoreSorted >= oneStandardError),1); % Index of best param in sorted cand vector.
        OSEparamIdx = sortIdx(OSEparamSortedIdx); % Index of best param in original cand space.
        OSEparamScore = meanCVscoreSorted(OSEparamSortedIdx);
    end
end
