function [CVresults] = crossValidation(fun,data,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% crossValidation performs k-fold or leave-one-out cross validation on data
% provided to compute performance of given model.  
%
% Arguements:
%   fun = Objective function (e.g., estimator).
%   data = Data structure were current features and labels are stored.
%   kFold = Number of CV folds. 
%   ifParallel = Parallelize CV (1 or 0, default = 0).
%   ifRand = if randomized (default = 1)
%   randomState: Controls the randomness. Pass an integer value for
%       reproducible results (default = 'shuffle').  
%
% Output:
%   CVscore = Cross-validation score. 
%
% Reference:
%   https://en.wikipedia.org/wiki/Cross-validation_(statistics)
%
% Emin Serin - 01.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input
% Set default inputs.
% Default parameters.
defaultVals.kFold = 10; defaultVals.ifParallel = 0; 
defaultVals.ifRand = 1; defaultVals.randomState = 'shuffle';

% Input Parser
validationNumeric = @(x) isnumeric(x);
p = inputParser(); p.PartialMatching = 0; % deactivate partial matching.
addParameter(p,'kFold',defaultVals.kFold,validationNumeric);
addParameter(p,'ifParallel',defaultVals.ifParallel,validationNumeric);
addParameter(p,'ifRand',defaultVals.ifRand,validationNumeric);
addParameter(p,'randomState',defaultVals.randomState);

% Parse input
parse(p,varargin{:});

% Input 
kFold = p.Results.kFold;
ifParallel = p.Results.ifParallel;
ifRand =  p.Results.ifRand;

% Set random state. 
rng(p.Results.randomState);

%%
% Generate CV indices.
cvFoldIdx = gen_cvpartition(data.y,kFold,ifRand);

% Preallocate.
trainTestData = prepare_trainTestData(data,cvFoldIdx(1));
CVresults = fun(trainTestData);

if ~ifParallel
    for fold = 2:kFold
        trainTestData = prepare_trainTestData(data,cvFoldIdx(fold));
        CVresults(fold,1) = fun(trainTestData);
    end
else
    parfor fold = 2:kFold
        trainTestData = prepare_trainTestData(data,cvFoldIdx(fold));
        CVresults(fold,1) = fun(trainTestData);
    end
end

end


function [trainTestData] = prepare_trainTestData(data,foldIdx)
dataNames = fieldnames(data);
for dn = 1: numel(dataNames)
    % Train-test split.
    cDataName = dataNames{dn};
    trainTestData.([cDataName,'_train']) = data.(cDataName)(foldIdx.trainIdx,:);
    trainTestData.([cDataName,'_test']) = data.(cDataName)(foldIdx.testIdx,:);
end
end