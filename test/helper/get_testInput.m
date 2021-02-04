function [testInputs] = get_testInput(varargin)
% get_testInput validates and returns inputs required for a test functions.
% It also returns default inputs if no input are provided. 
%   
% Arguements: 
%   Check test_NBSPredict and sim_testNBSPredict functions for arguements. 
%
% Output:
%   searchInputs = Structure including all inputs required for searching
%       algorithm. 
%
% Emin Serin - 24.04.2020
%
% See also, test_NBSPredict, sim_testNBSPredict, sim_testNBSPredictABIDE
%
%% Input parser.
% Default parameters for NBSPredict.
defaultVals.kFold = 10; defaultVals.ifParallel = 0;
defaultVals.selMethod = 'randomSearch'; defaultVals.pVal = 0.01; 
defaultVals.maxPercent = 10; defaultVals.repCViter = 10; 
defaultVals.verbose = 1; defaultVals.ifHyperOpt = 0; 
defaultVals.hyperOptSteps = 5; defaultVals.T = 5;
defaultVals.alpha = 0.95; defaultVals.nIter = 20;
defaultVals.nRound = 3; defaultVals.nDiv = 20;
defaultVals.ifModelOpt = 0; defaultVals.ifSave = 0;
defaultVals.ABIDE = 0; defaultVals.ifRegression = 0;
defaultVals.randomState = 'shuffle'; defaultVals.simPreAllocate = 0; 
selMethodOptions = {'divSelect','divSelectWide','randomSearch',...
    'simulatedAnnealing'};

% Default parameters for synthetic data generation. 
defaultVals.nNodes = 100; defaultVals.nEdges= 50; 
defaultVals.network = 'scalefree'; defaultVals.n = 50;
defaultVals.m = 10; defaultVals.m0 = 21;
defaultVals.k = 50; defaultVals.beta = .05;
networkOptions = {'scalefree','smallworld','random'};

% Validation
validationSelMethod = @(x) any(validatestring(x,selMethodOptions));
validationNumeric = @(x) isnumeric(x);
validationNetwork = @(x) any(validatestring(x,networkOptions));

% Add NBSPredict parameters. 
p = inputParser();
p.PartialMatching = 0; % deactivate partial matching.
addParameter(p,'kFold',defaultVals.kFold,validationNumeric);
addParameter(p,'ifParallel',defaultVals.ifParallel,validationNumeric);
addParameter(p,'metric',[]);
addParameter(p,'MLmodels',[]);
addParameter(p,'selMethod',defaultVals.selMethod,validationSelMethod);
addParameter(p,'pVal',defaultVals.pVal,validationNumeric);
addParameter(p,'bestParamMethod',[]);
addParameter(p,'maxPercent',defaultVals.maxPercent,validationNumeric);
addParameter(p,'repCViter',defaultVals.repCViter,validationNumeric);
addParameter(p,'verbose',defaultVals.verbose,validationNumeric);
addParameter(p,'ifHyperOpt',defaultVals.ifHyperOpt,validationNumeric);
addParameter(p,'hyperOptSteps',defaultVals.hyperOptSteps,validationNumeric);
addParameter(p,'T',defaultVals.T,validationNumeric);
addParameter(p,'nIter',defaultVals.nIter,validationNumeric);
addParameter(p,'alpha',defaultVals.alpha,validationNumeric);
addParameter(p,'nRound',defaultVals.nRound,validationNumeric);
addParameter(p,'nDiv',defaultVals.nDiv,validationNumeric);
addParameter(p,'ifModelOpt',defaultVals.ifModelOpt,validationNumeric);
addParameter(p,'ifSave',defaultVals.ifSave,validationNumeric);
addParameter(p,'ABIDE',defaultVals.ABIDE,validationNumeric);
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
addParameter(p,'n',defaultVals.n,validationNumeric);
addParameter(p,'noise',[]);
addParameter(p,'ifRegression',defaultVals.ifRegression,validationNumeric);
addParameter(p,'randomState',defaultVals.randomState);

% Parse inputs. 
parse(p,varargin{:});

if p.Results.ifRegression
    defaultParameters.noise = 0.0;
    defaultParameters.MLmodels = 'LinReg';
    defaultParameters.metric = 'correlation';
    defaultParameters.bestParamMethod = 'max';
    defaultParameters.cnr = [];
else
    defaultParameters.cnr = 0.5;
    defaultParameters.MLmodels = 'LogReg';
    defaultParameters.metric = 'accuracy';
    defaultParameters.bestParamMethod = 'max';
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


end

