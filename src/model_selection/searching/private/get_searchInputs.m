function [searchInputs] = get_searchInputs(searchMethod, y, varargin)
% GET_SEARCHINPUTS validates and returns inputs required for a specific
% searching algorithm. It also returns default inputs if no input are
% provided. Please check help section in the searching algorithms for
% required parameters in detail. 
%   
% Arguements: 
%   searchMethod = Following searching methods can be used:
%       randomSearch: Randomized search. 
%       gridSearch: Grid search
%       bayesOpt: Bayesian optimization
%   y = Target variable.
%   varargin = varargin cell array that you obtained in searching
%       algorithms.
%
% Output:
%   searchInputs = Structure including all inputs required for searching
%       algorithm. 
%
% Emin Serin - 19.08.2019
%
%% Input
% Set default inputs.
% Default parameters.
defaultVals.nIter = 20; defaultVals.bestParamMethod = 'best'; 
defaultVals.kFold = 10; defaultVals.numCores = 1; 
defaultVals.acquisitionFun = 'expected-improvement';
bestParamMethodOptions = {'best','median'}; 
acquisitionFunOptions = {'probability-of-improvement',...
    'expected-improvement','lower-confidence-bound'};
defaultVals.randomState = false;


% Input Parser
validationNumeric = @(x) isnumeric(x);
validationBestParamMethod = @(x) any(validatestring(x,bestParamMethodOptions));
validationAcquisitionFun= @(x) any(validatestring(x,acquisitionFunOptions));
p = inputParser(); p.PartialMatching = 0; % deactivate partial matching.
addParameter(p,'nIter',defaultVals.nIter,validationNumeric);
addParameter(p,'kFold',defaultVals.kFold,validationNumeric);
addParameter(p,'numCores',defaultVals.numCores,validationNumeric);
addParameter(p,'bestParamMethod',defaultVals.bestParamMethod,validationBestParamMethod);
addParameter(p,'acquisitionFun',defaultVals.acquisitionFun,validationAcquisitionFun);
addParameter(p,'metric',[]);
addParameter(p,'randomState',defaultVals.randomState);

% Parse input
parse(p,varargin{:});

% available search methods you can use this function with.
availSearchMethods = {'gridSearch','randomSearch','bayesOpt'};  

% Retun error if incorrect searching method given. 
assert(any(strcmpi(searchMethod,availSearchMethods)),['Incorrect searching method provided!',...
    ' Please check help section for available searching methods.']);

%% Return required inputs for a given searching algorithm.

% Base parameters which found in all searching algorithms.
searchInputs.numCores = p.Results.numCores;
bestParamMethod = p.Results.bestParamMethod;

% Set parameters for grid search.
nSample = size(y, 1);
if p.Results.kFold > nSample
    searchInputs.kFold = nSample;
else
    searchInputs.kFold = p.Results.kFold;
end

switch lower(searchMethod)
    case {'randomsearch','bayesopt'}
        searchInputs.nIter = p.Results.nIter;
        if strcmpi(searchMethod,'bayesOpt')
            searchInputs.acquisitionFun = p.Results.acquisitionFun;
            bestParamMethod = 'best'; % No median option for bayes. 
        end
end

minMetrics = {'mse','rmse','mad'};
if strcmpi(bestParamMethod,'best') 
    if ismember(p.Results.metric,minMetrics)
        searchInputs.bestParamMethod = 'min';
    else
        searchInputs.bestParamMethod = 'max';
    end
end

% Set random state. 
if p.Results.randomState
    set_seed(p.Results.randomState);
end

end

