function [NBSPredict] = test_NBSPredict(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test_NBSPredict performs NBSPredict on synthetic network. It can be also
% used as a test function. test_NBSPredict delivers parameters and runs
% NBSPredict using them. If no parameters are provided, it will run
% NBSPredict with default parameters. 
% 
% Arguments: 
%     repCViter = Number of nested-CV repetition (default = 10). 
%     kFold = Number of CV folds (default = 10).
%     ifParallel = Performs repeated nested CV parallel 
%         (1 or 0, default = 0). 
%     metrics = Performance metrics (please see compute_ModelMetrics for
%         performance metrics 
%         default = 'accuracy' (classification), 'correlation' (regression).
%     ifModelOpt = If performs model optimization
%         (i.e., runs repeated nested CV with different estimators,
%         default = 1).
%     MLmodels = Estimators: 
%         For Classification (default = LogReg):
%             svmC = Support Vector Machine Classifier
%             decisionTreeC = Decision Tree Classifier
%             LogReg = Logistic Regression
%             lda = Linear Discriminant Analysis
%         For Regression (default = LinReg):
%             svmR = Support Vector Machine Regressor
%             decisionTreeR = Decision Tree Regressor
%             LinReg = Linear Regression
%     algorithm = Algorithms used to simulate (default = NBSPredict):
%         NBSPredict = NBS-Predict. 
%         CPM = Connectome-based predictive modeling (Shen et al., 2017)
%         ElasticNet = Elastic Net.
%         Lasso = Lasso.
%         pVal = Selects suprathreshold features below a given p-value
%             threshold.
%         Top5 = Selects top 5% of features based on their test
%             statistics.
%     bestParamMethod = Method to choose best parameter during feature
%         selection (best,median default = best).
%     pVal = p-value used for pre-filtering (default = 0.05).
%     verbose = Whether display current nested CV score on command
%         window (default = 1).
%     ifHyperOpt = Whether perform hyperparameter optimization (default = 1). 
%     hyperOptSteps = Steps from low to high limit of hyperparameter
%         space (e.g., paramGrid.C = logspace(-3,2,hyperOptSteps) default = 5).
%     selMethod = Selection method for hyperparameter optimization (default = gridSearch).
%         Different algorithms have different parameters: 
%             randomSearch = Random Search Algorithm: 
%                 nIter = Number of iteration (default = 10).
%              bayesOpt = Bayesian Optimization:
%                 nIter = Number of iteration (default = 10).
%                 acquisitionFun = Acquisition function name (default: expected-improvement):
%                     probability-of-improvement
%                     expected-improvement
%                     lower-confidence-bound
%             gridSearch = Grid Search Algorithm. 
%     ifSave = If saves NBSPredict structure with results after nalysis 
%         done (default = false).
%  
% The following arguements are specific to the synthetic data generation:
%     ifRegression = Generates data for regression problems (default = 0).
%     noise = Noise in target data. Only available in regression problems.
%         (default = 0.1)
%     nNodes = Number of nodes in synthetic network (default = 100).
%     nEdges = Number of edges with ground truth or contarst of interest (default = 50).
%     formNetwork = Whether the edges with ground truth form network
%         (default = True).
%     cnr = Contrast-to-noise ratio. Only available in classification 
%         problems (default = 0.50).
%     nn = The number of control-contrast network couples generated.
%         (default = 50, i.e. sample size of 100 observations). 
%     network = Type of network (default = 'scalefree')
%         scalefree = Scale-free network:
%             m: Number of edges through which a new node connects to
%                existing nodes (default = 10).
%             m0: Initial number of nodes in the network. (default = 21)
%          smallworld = Small-world network:
%             k: k-nearest neightbors each node is connected (default = 49). 
%             beta: rewiring probability. (default = .05)
%          random = Random network. 
%     randomState = Controls the randomness. Pass an integer value for
%         reproducible results or 'shuffle' to randomize (default = 42).  
%       
% Output:
%     NBSPredict: NBSPredict structure with results. 
% 
% Example: 
%     test_NBSPredict();
%     test_NBSPredict('kFold',5,'ifParallel',1,'model','svmC','network','scalefree');
% 
% Last edited by Emin Serin, 08.04.2021.
%   
% See also, run_NBSPredict, gen_synthData, get_NBSPredictInput, compute_modelMetrics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Organize user inputs.
[testInputs] = get_testInput(varargin{:});
NBSPredict.parameter.repCVIter = testInputs.repCViter;
NBSPredict.parameter.randomState = testInputs.randomState;
NBSPredict.parameter.kFold = testInputs.kFold;
NBSPredict.parameter.ifParallel = testInputs.ifParallel; 
NBSPredict.parameter.metric = testInputs.metric;
NBSPredict.parameter.selMethod = testInputs.selMethod;
NBSPredict.parameter.pVal = testInputs.pVal;
NBSPredict.parameter.verbose = testInputs.verbose;
NBSPredict.parameter.ifModelOpt = testInputs.ifModelOpt;
NBSPredict.parameter.ifHyperOpt = testInputs.ifHyperOpt;
NBSPredict.parameter.ifSave = testInputs.ifSave;
NBSPredict.parameter.ifTest = 1; % This is the tag for testing. DO NOT CHANGE!

if testInputs.ifRegression
    NBSPredict.parameter.test = 'f-test';
    NBSPredict.parameter.contrast = [0,1];
else
    NBSPredict.parameter.contrast = [1,-1];
    NBSPredict.parameter.test = 't-test';
end

if ~NBSPredict.parameter.ifModelOpt
    NBSPredict.parameter.MLmodels = {testInputs.MLmodels};
end

switch NBSPredict.parameter.selMethod
    case {'randomSearch','bayesOpt'}
        NBSPredict.parameter.nIter = testInputs.nIter;
        if strcmpi(NBSPredict.parameter.selMethod,'bayesOpt')
            NBSPredict.parameter.acquisitionFun = testInputs.acquisitionFun;
        end     
end

netParameters = {'nEdges',testInputs.nEdges,'n',testInputs.n,...
    'randomState',testInputs.randomState,...
    'formNetwork',testInputs.formNetwork,...
    'randomState',testInputs.randomState};

if testInputs.ifRegression
    netParameters = {netParameters{:},'noise',testInputs.noise,...
        'ifRegression',1};
else
    netParameters = {netParameters{:},'cnr',testInputs.cnr,...
        'ifRegression',0};
end

netParameters = {netParameters{:},'nNodes',testInputs.nNodes};
switch testInputs.network
    case 'smallworld'
        netParameters = {netParameters{:},'k',testInputs.k,...
            'beta',testInputs.beta,'network','smallworld'};
    case 'scalefree'
        netParameters = {netParameters{:},'m',testInputs.m,...
            'm0',testInputs.m0,'network','scalefree'};
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
if ~ testInputs.simPreAllocate
    if testInputs.verbose
        fprintf('Algorithm: %s',testInputs.algorithm);
    end
    NBSPredict = testInputs.algorithmHandle(NBSPredict);
end

end

