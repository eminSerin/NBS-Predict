function [NBSPredict] = test_NBSPredict(varargin)
% test_NBSPredict performs NBSPredict on synthetic network. It can be also
% used as a test function. test_NBSPredict delivers parameters and runs
% NBSPredict using them. If no parameters are provided, it will run
% NBSPredict with default parameters. 
% 
%   Arguements: 
%       repCViter = Number of nested-CV repetition (default = 10). 
%       kFold = Number of CV folds (default = 10).
%       ifParallel = Performs repeated nested CV parallel 
%           (1 or 0, default = 0). 
%       metrics = Performance metrics (accuracy,f1,auc,precision,
%           matthews_cc,cohens_kappa, default = f1).
%       ifModelOpt = If performs model optimization
%           (i.e., runs repeated nested CV with different estimators,
%           default = 1).
%       MLmodels = Estimator (svmC or decisionTreeC, default = svmC).
%       bestParamMethod = Method to choose best parameter during feature
%           selection (max,median,ose, default = max).
%       maxPercent = The maximum percentile which feature selection 
%            algorithm can pick (default = 10).
%       verbose = Whether display current nested CV score on command
%           window (default = 1).
%       ifHyperOpt = Whether perform hyperparameter optimization (default = 1). 
%       hyperOptSteps = Steps from low to high limit of hyperparameter
%           space (e.g., paramGrid.C = logspace(-3,2,hyperOptSteps) default = 5).
%       selMethod = Feature selection method used in the inner fold.
%           Different algorithms have different parameters: 
%               divSelect, divSelectWide: 
%                   nDiv = Number of division (i.e, in how many pieces
%                       algorithm divides the parameter space, default = 20). 
%                   nRound = Selection rounds (default = 3). 
%               randomSearch: 
%                   nIter = Number of iteration (also in simulatedAnnealing,
%                       default = 60).
%               simulatedAnnealing: 
%                   T = Initial temperature (default = 5).
%                   alpha = Boltzmann constant (default = 0.95).
%       ifSave = If saves NBSPredict structure with results after nalysis 
%           done (default = false).
%   
%   The following parameters are specific to the synthetic data generation.
%       nNodes = Number of nodes in synthetic network (default = 100).
%       cnr = Contrast-to-noise ratio (default = 0.75).
%       nn = The number of control-contrast network couples generated.
%           (default = 20, i.e. sample size of 40 observations). 
%       network = Type of network (default = 'smallworld')
%           Scale-free network:
%               m: Number of edges through which a new node connects to
%                  existing nodes (default = 2).
%               m0: Initial number of nodes in the network. (default = 40)
%           Small-world network:
%               k: k-nearest neightbors each node is connected (default = 10). 
%               beta: rewiring probability. (default = .05)
%           Random network. 
%   
%   Output:
%       NBSPredict: NBSPredict structure with results. 
%   
%   Example: 
%       test_NBSPredict();
%       test_NBSPredict('kFold',5,'ifParallel',1,'model','svmC','network','scalefree');
%   
%   Last edited by Emin Serin, 03.09.2019.
%   
% See also, run_NBSPredict, gen_synthData, get_NBSPredictInput, get_searchInputs

%% Input parser.
% Default parameters for NBSPredict.
defaultVals.kFold = 10; defaultVals.ifParallel = false;
defaultVals.metrics = 'accuracy'; defaultVals.MLmodels = 'svmC'; 
defaultVals.selMethod = 'randomSearch'; defaultVals.bestParamMethod = 'max'; 
defaultVals.maxPercent = 10; defaultVals.repCViter = 10; 
defaultVals.verbose = 1; defaultVals.ifHyperOpt = 1; 
defaultVals.hyperOptSteps = 5; defaultVals.T = 5;
defaultVals.alpha = 0.95; defaultVals.nIter = 60;
defaultVals.nRound = 3; defaultVals.nDiv = 20;
defaultVals.ifModelOpt = 1; defaultVals.ifSave = 0;
metricsOptions = {'accuracy','f1','auc','precision','matthews_cc','cohens_kappa'};
MLmodelsOptions = {'svmC','decisionTree'};
selMethodOptions = {'divSelect','divSelectWide','randomSearch',...
    'simulatedAnnealing'};
bestParamMethodOptions = {'max','ose','median'}; 

% Default parameters for synthetic data generation. 
defaultVals.nNodes = 100; defaultVals.nEdges= 50; 
defaultVals.cnr = 0.5; defaultVals.network = 'smallworld';
defaultVals.m = 2; defaultVals.m0 = 40;
defaultVals.k = 10; defaultVals.beta = .05;
defaultVals.n = 25;
networkOptions = {'scalefree','smallworld','random'};

% Validation
validationMetric = @(x) any(validatestring(x,metricsOptions));
validationModel = @(x) any(validatestring(x,MLmodelsOptions));
validationSelMethod = @(x) any(validatestring(x,selMethodOptions));
validationBestParamMethod = @(x) any(validatestring(x,bestParamMethodOptions));
validationNumeric = @(x) isnumeric(x);
validationNetwork = @(x) any(validatestring(x,networkOptions));

% Add NBSPredict parameters. 
p = inputParser();
p.PartialMatching = 0; % deactivate partial matching.
addParameter(p,'kFold',defaultVals.kFold,validationNumeric);
addParameter(p,'ifParallel',defaultVals.ifParallel,validationNumeric);
addParameter(p,'metrics',defaultVals.metrics,validationMetric);
addParameter(p,'MLmodels',defaultVals.MLmodels,validationModel);
addParameter(p,'selMethod',defaultVals.selMethod,validationSelMethod);
addParameter(p,'bestParamMethod',defaultVals.bestParamMethod,validationBestParamMethod);
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


% Add Synthetic data generation parameters. 
addParameter(p,'network',defaultVals.network,validationNetwork);
addParameter(p,'nNodes',defaultVals.nNodes,validationNumeric);
addParameter(p,'cnr',defaultVals.cnr,validationNumeric);
addParameter(p,'m',defaultVals.m,validationNumeric);
addParameter(p,'m0',defaultVals.m0,validationNumeric);
addParameter(p,'k',defaultVals.k,validationNumeric);
addParameter(p,'beta',defaultVals.beta,validationNumeric);
addParameter(p,'nEdges',defaultVals.nEdges,validationNumeric);
addParameter(p,'n',defaultVals.n,validationNumeric);

% Parse inputs. 
parse(p,varargin{:});

%% Organize user inputs.
NBSPredict.parameter.contrast = [1,-1];
NBSPredict.parameter.test = 't-test';
NBSPredict.parameter.kFold = p.Results.kFold;
NBSPredict.parameter.ifParallel = p.Results.ifParallel; 
NBSPredict.parameter.metrics = p.Results.metrics;
NBSPredict.parameter.selMethod = p.Results.selMethod;
NBSPredict.parameter.maxPercent = p.Results.maxPercent;
NBSPredict.parameter.verbose = p.Results.verbose;
NBSPredict.parameter.ifModelOpt = p.Results.ifModelOpt;
NBSPredict.parameter.ifSave = p.Results.ifSave;
NBSPredict.parameter.ifTest = 1; % This is a tag for testing. DO NOT CHANGE!
if ~NBSPredict.parameter.ifModelOpt
    NBSPredict.parameter.MLmodels = {p.Results.MLmodels};
end
switch NBSPredict.parameter.selMethod
    case {'divSelect','divSelectWide'}
        NBSPredict.parameter.nDiv = p.Results.nDiv;
        NBSPredict.parameter.nRound = p.Results.nRound;
    case {'randomSearch','simulatedAnnealing'}
        NBSPredict.parameter.nIter = p.Results.nIter;
        if strcmpi(NBSPredict.parameter.selMethod,'simulatedAnnealing')
            NBSPredict.parameter.T = p.Results.T;
            NBSPredict.parameter.alpha = p.Results.alpha;
        end
end

netParameters = {'nNodes',p.Results.nNodes,'nEdges',defaultVals.nEdges,...
    'n',p.Results.n,'network',p.Results.network,'cnr',p.Results.cnr};
switch p.Results.network
    case 'smallworld'
        netParameters = {netParameters{:},'k',p.Results.k,...
            'beta',p.Results.beta};
    case 'scalefree'
        netParameters = {netParameters{:},'m',p.Results.m,...
            'm0',p.Results.m0};
end

%% Run analysis. 

% Generate data.
NBSPredict.data = gen_synthData(netParameters{:});
[NBSPredict.data.X,NBSPredict.data.nodes,...
    NBSPredict.data.edgeIdx] = shrinkMat(NBSPredict.data.subData);

% Reshape NBSPredict structure
NBSPredict.data.y = NBSPredict.data.designMat;
NBSPredict.data = rmfield(NBSPredict.data,'designMat');
NBSPredict.data = rmfield(NBSPredict.data,'subData');

% Get edge vector showing edges with true contrast of interest.
nFeatures = numel(NBSPredict.data.edgeIdx);
[~,trueFeatureIdx] = ismember(NBSPredict.data.contrastEdgeIdx,NBSPredict.data.edgeIdx);
contrastedEdges = zeros(nFeatures,1);
contrastedEdges(trueFeatureIdx) = 1;
NBSPredict.data.contrastedEdges = contrastedEdges;

% Run 
NBSPredict = run_NBSPredict(NBSPredict);

end

