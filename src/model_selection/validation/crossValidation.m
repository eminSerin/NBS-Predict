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

% Input Parser
validationNumeric = @(x) isnumeric(x);
p = inputParser(); p.PartialMatching = 0; % deactivate partial matching.
addParameter(p,'kFold',defaultVals.kFold,validationNumeric);
addParameter(p,'ifParallel',defaultVals.ifParallel,validationNumeric);

% Parse input
parse(p,varargin{:});

% Input 
kFold = p.Results.kFold;
ifParallel = p.Results.ifParallel;

%%
% Generate CV indices.
cvFoldIdx = gen_cvpartition(data.y,kFold);

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
% Train-test split.
trainTestData.X_train = data.X(foldIdx.trainIdx,:);
trainTestData.X_test = data.X(foldIdx.testIdx,:);
trainTestData.y_train = data.y(foldIdx.trainIdx,:);
trainTestData.y_test = data.y(foldIdx.testIdx,:);
end