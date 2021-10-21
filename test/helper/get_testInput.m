function [testInputs] = get_testInput(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_testInput validates and returns inputs required for a test functions.
% It also returns default inputs if no input are provided. 
%   
% Arguments: 
%   Check test_NBSPredict and sim_testNBSPredict functions for arguements. 
%
% Output:
%   searchInputs = Structure including all inputs required for searching
%       algorithm. 
%
% Emin Serin - 08.01.2020
%
% See also, test_NBSPredict, sim_testNBSPredict, sim_testNBSPredictABIDE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input parser.
% Default parameters for NBSPredict.
defaultVals.kFold = 10; defaultVals.ifParallel = 0;
defaultVals.selMethod = 'gridSearch'; defaultVals.pVal = 0.01; 
defaultVals.repCViter = 10; defaultVals.algorithm = 'NBSPredict';
defaultVals.verbose = 1; defaultVals.ifHyperOpt = 0; 
defaultVals.hyperOptSteps = 5; defaultVals.nIter = 10;
defaultVals.ifModelOpt = 0; defaultVals.ifSave = 0;
defaultVals.ifRegression = 0; defaultVals.bayesAcqFunc = 'expected-improvement';
defaultVals.randomState = 42; defaultVals.simPreAllocate = 0; 
selMethodOptions = {'gridSearch','randomSearch','bayesOpt'};
bayesAcqFuncOptions = {'lower-confidence-bound','probability-of-improvement',...
    'expected-improvement'};
algorithmOptions = {'NBSPredict','CPM','ElasticNet','Lasso','pVal','Top5'};


% Default parameters for synthetic data generation. 
defaultVals.nNodes = 100; defaultVals.nEdges= 50; 
defaultVals.network = 'scalefree'; defaultVals.formNetwork = 1;
defaultVals.m = 10; defaultVals.m0 = 21;
defaultVals.k = 49; defaultVals.beta = .05;
networkOptions = {'scalefree','smallworld','random'};

% Validation
validationSelMethod = @(x) any(validatestring(x,selMethodOptions));
validationNumeric = @(x) isnumeric(x);
validationNetwork = @(x) any(validatestring(x,networkOptions));
validationBayes = @(x) any(validatestring(x,bayesAcqFuncOptions));
validationAlgorithm = @(x) any(validatestring(x,algorithmOptions));

p = inputParser();
p.KeepUnmatched = true;
p.PartialMatching = 0; % deactivate partial matching.

% Add NBSPredict parameters. 
addParameter(p,'algorithm',defaultVals.algorithm,validationAlgorithm);
addParameter(p,'kFold',defaultVals.kFold,validationNumeric);
addParameter(p,'ifParallel',defaultVals.ifParallel,validationNumeric);
addParameter(p,'metric',[]);
addParameter(p,'MLmodels',[]);
addParameter(p,'selMethod',defaultVals.selMethod,validationSelMethod);
addParameter(p,'acquisitionFun',defaultVals.bayesAcqFunc,validationBayes);
addParameter(p,'pVal',defaultVals.pVal,validationNumeric);
addParameter(p,'bestParamMethod',[]);
addParameter(p,'repCViter',defaultVals.repCViter,validationNumeric);
addParameter(p,'verbose',defaultVals.verbose,validationNumeric);
addParameter(p,'ifHyperOpt',defaultVals.ifHyperOpt,validationNumeric);
addParameter(p,'hyperOptSteps',defaultVals.hyperOptSteps,validationNumeric);
addParameter(p,'nIter',defaultVals.nIter,validationNumeric);
addParameter(p,'ifModelOpt',defaultVals.ifModelOpt,validationNumeric);
addParameter(p,'ifSave',defaultVals.ifSave,validationNumeric);
addParameter(p,'simPreAllocate',defaultVals.simPreAllocate,validationNumeric);

% Add Synthetic data generation parameters. 
addParameter(p,'network',defaultVals.network,validationNetwork);
addParameter(p,'nNodes',defaultVals.nNodes,validationNumeric);
addParameter(p,'cnr',[]);
addParameter(p,'m',defaultVals.m,validationNumeric);
addParameter(p,'m0',defaultVals.m0,validationNumeric);
addParameter(p,'k',defaultVals.k,validationNumeric);
addParameter(p,'beta',defaultVals.beta,validationNumeric);
addParameter(p,'nEdges',defaultVals.nEdges,validationNumeric);
addParameter(p,'formNetwork',defaultVals.formNetwork);
addParameter(p,'n',[],validationNumeric);
addParameter(p,'noise',[]);
addParameter(p,'ifRegression',defaultVals.ifRegression,validationNumeric);
addParameter(p,'randomState',defaultVals.randomState);

% Parse inputs. 
parse(p,varargin{:});

if p.Results.ifRegression
    if isempty(p.Results.n)
        defaultParameters.n = 125;
    end
    defaultParameters.noise = 0.1;
    defaultParameters.MLmodels = 'LinReg';
    defaultParameters.metric = 'correlation';
    defaultParameters.bestParamMethod = 'best';
    defaultParameters.cnr = [];
else
   if isempty(p.Results.n)
        defaultParameters.n = 50;
    end
    defaultParameters.cnr = 0.5;
    defaultParameters.MLmodels = 'LogReg';
    defaultParameters.metric = 'accuracy';
    defaultParameters.bestParamMethod = 'best';
    defaultParameters.noise = [];
end


% Merge input and default parameters.
paramNames = fieldnames(p.Results);
testInputs = p.Results;
for i = 1 : numel(paramNames)
    param = paramNames{i};
    if isempty(p.Results.(param))
        testInputs.(param) = defaultParameters.(param);
    end
end

% Algorithm handle.
switch p.Results.algorithm
    case 'CPM'
        func = 'test_CPM';
    case 'NBSPredict'
        func = 'run_NBSPredict';
    otherwise
        func = sprintf('run_NBSPredict_%s',p.Results.algorithm);
end
testInputs.algorithmHandle = @(NBSPredict) feval(func,NBSPredict);


end

