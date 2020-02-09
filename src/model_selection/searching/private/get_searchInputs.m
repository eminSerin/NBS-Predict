function [searchInputs] = get_searchInputs(searchMethod,varargin)
% GET_SEARCHINPUTS validates and returns inputs required for a specific
% searching algorithm. It also returns default inputs if no input are
% provided. Please check help section in the searching algorithms for
% required parameters in detail. 
%   
% Arguements: 
%   searchMethod = Following searching methods can be used:
%       divSelect and divSelectWide: Division and selection searching.
%       randomSearch: Randomized search. 
%       gridSearch: Grid search
%       simulatedAnnealing: Simulated annealing
%       bayesOpt: Bayesian optimization
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
defaultVals.nIter = 10; defaultVals.nDiv = 20; defaultVals.selRound = 3;
defaultVals.kFold = 10; defaultVals.bestParamMethod = 'max';
defaultVals.sortDirection = 'ascend';  defaultVals.kFold = 10; 
defaultVals.ifParallel = 0; defaultVals.alpha = .90; defaultVals.T = 5;
defaultVals.acquisitionFun = 'expected-improvement';
bestParamMethodOptions = {'max','ose','median','min'}; 
sortDirectionOptions = {'ascend','descend'};
acquisitionFunOptions = {'probability-of-improvement',...
    'expected-improvement','lower-confidence-bound'};

% Input Parser
validationNumeric = @(x) isnumeric(x);
validationBestParamMethod = @(x) any(validatestring(x,bestParamMethodOptions));
validationSortDirection= @(x) any(validatestring(x,sortDirectionOptions));
validationAcquisitionFun= @(x) any(validatestring(x,acquisitionFunOptions));
p = inputParser(); p.PartialMatching = 0; % deactivate partial matching.
addParameter(p,'selRound',defaultVals.selRound,validationNumeric);
addParameter(p,'nDiv',defaultVals.nDiv,validationNumeric);
addParameter(p,'nIter',defaultVals.nIter,validationNumeric);
addParameter(p,'T',defaultVals.T,validationNumeric);
addParameter(p,'alpha',defaultVals.alpha,validationNumeric);
addParameter(p,'kFold',defaultVals.kFold,validationNumeric);
addParameter(p,'ifParallel',defaultVals.ifParallel,validationNumeric);
addParameter(p,'bestParamMethod',defaultVals.bestParamMethod,validationBestParamMethod);
addParameter(p,'sortDirection',defaultVals.sortDirection,validationSortDirection);
addParameter(p,'acquisitionFun',defaultVals.acquisitionFun,validationAcquisitionFun);

% Parse input
parse(p,varargin{:});

availSearchMethods = {'divSelect','divSelectWide','gridSearch','randomSearch',...
    'simulatedAnnealing','bayesOpt'}; % available search methods you can use this function with. 

% Retun error if incorrect searching method given. 
assert(any(strcmpi(searchMethod,availSearchMethods)),['Incorrect searching method provided!',...
    ' Please check help section for available searching methods.']);

%% Return required inputs for a given searching algorithm.

% Base parameters which found in all searching algorithms.
searchInputs.ifParallel = p.Results.ifParallel;
searchInputs.kFold = p.Results.kFold;
searchInputs.bestParamMethod = p.Results.bestParamMethod;
searchInputs.sortDirection = p.Results.sortDirection; 

switch lower(searchMethod)
    case {'divselect','divselectwide'}
        searchInputs.selRound = p.Results.selRound;
        searchInputs.nDiv = p.Results.nDiv;
    case {'randomsearch','simulatedannealing','bayesopt'}
        searchInputs.nIter = p.Results.nIter;
        if strcmpi(searchMethod,'simulatedAnnealing')
            searchInputs.T = p.Results.T;
            searchInputs.alpha = p.Results.alpha;
        elseif strcmpi(searchMethod,'bayesOpt')
            searchInputs.acquisitionFun = p.Results.acquisitionFun;
        end
end

end

