function [simResults] = sim_testNBSPredict(varargin)
% sim_testNBSPredict performs simulation using simulated network data. 
% It is used to test prediction performance of the NBS-Predict and
% alternative algorithms (elastic net, lasso, p-value thresholding, top 5%,
% and connectome based predictive modeling (Shen et al., 2017)) on the  
% the simulated network data (small world, scale free or random). 
%
% Input:
%   simIter = Total number of iteration (default = 1000). Please set a
%       number that is multiplier of nCores to make sure that the desired 
%       number of cores will be utilized in all iterations. Total number of
%       iteration will be the multiplier of the nCores even if you set
%       another numbers. For example:
%           if simIter = 1001; and nCores = 10;
%       It will run 1000 times instead of 1001. 
%   nCores = Number of cores to be used, enter -1 to utilize all cores 
%       (default = 1).
%   conds = Structure of effect/noise conditions. The structure must be
%       as followings: conds.(condName) = condValue. Defaults:
%       Classification  - 0.25, 0.5, 0.75, 1.0 CNRs
%       Regression      - 0.1, 1.0, 3.0, 5.0 Noise
%   ifRegression = Runs simulations for classification or regression
%       problems (1 Regression, 0 Classification) (default = 0).
%   randSeed = Seed number for random generator. Pass an integer for
%       reproducible results or 'shuffle' to randomize (default = 42).
%   algorithm = Algorithms used to simulate (default = NBSPredict):
%       NBSPredict  = NBS-Predict. 
%       CPM         = Connectome-based predictive modeling (Shen et al., 2017)
%       ElasticNet  = Elastic Net.
%       Lasso       = Lasso.
%       pVal        = Selects suprathreshold features below a given p-value
%           threshold.
%       Top5        = Selects top 5% of features based on their test
%           statistics.
%   saveX = Whether features used in each iteration will be saved 
%       (default = 1).
%   formNetwork = Whether edges with ground truth form a network 
%       (default = 1).
%
%    Additional arguements (e.g. networks, models parameters) documented in
%       test_NBSPredict function.
%
% Output:
%   simResults = Output structure as follows:
%           SimResults:
%                info = Several information and parameters.
%                conds: Effect/Noise conditions
%                   cond (e.g. CNR_25 for 0.25 CNR):
%                       y_true          = True labels.
%                       edgeWeight      = Vectorized raw edge weights.
%                       sEdgeWeight     = Vectorized scaled edge weights.
%                       predPerf        = Prediction performances.
%                       time            = CPU time.
%       If you run CPM algorithm, you will have predPerf including two
%           columns. These columns represent prediction performance of
%           positive and negative networks, respectively.
%       This structure is also saved in
%           ~/test/simulationResults/simRes_[algorithm]_[Reg or Class]_[date].mat directory.
% Example:
%   [simResults] = sim_testNBSPredict();
%   [simResults] = sim_testNBSPredict('simIter',500,'ifRegression',1,...
%       'n',125,'randSeed','shuffle');
%
% Suggestions:
%   We suggest setting n parameter (i.e. number of simulated subject pairs
%       in each run) to at least 50 (100 subjects) for classification, and 
%       125 (250 subjects) for regression problems.
%
% Created by Emin Serin, 08.04.2021
%
% Reference:
%   Shen, Xilin, et al. "Using connectome-based predictive modeling to
%   predict individual behavior from brain connectivity." nature protocols
%   12.3 (2017): 506-518.
%
% See also: test_NBSPredict, get_NBSPredictInput
%
%
%%
% Default Input
defaultVals.simIter = 1000; defaultVals.nCores = 1;
defaultVals.conds = []; defaultVals.ifRegression = 0; 
defaultVals.saveX = 0; defaultVals.formNetwork = 1;
defaultVals.randSeed = 42; defaultVals.algorithm = 'NBSPredict';
algorithmOptions = {'NBSPredict','CPM','ElasticNet','Lasso','pVal','Top5'};

% Validation
validationNumeric = @(x) isnumeric(x);
validationAlgorithm = @(x) any(validatestring(x,algorithmOptions));

% Add NBSPredict parameters. 
p = inputParser();
p.PartialMatching = 0; % deactivate partial matching.
p.KeepUnmatched = true;
addParameter(p,'algorithm',defaultVals.algorithm,validationAlgorithm);
addParameter(p,'simIter',defaultVals.simIter,validationNumeric);
addParameter(p,'nCores',defaultVals.nCores,validationNumeric);
addParameter(p,'conds',defaultVals.conds);
addParameter(p,'saveX',defaultVals.saveX);
addParameter(p,'formNetwork',defaultVals.formNetwork);
addParameter(p,'ifRegression',defaultVals.ifRegression);
addParameter(p,'randSeed',defaultVals.randSeed);

% Parse inputs. 
parse(p,varargin{:});
ifRegression = p.Results.ifRegression;
nCores = p.Results.nCores; 
simIter = p.Results.simIter;
conds = p.Results.conds;
algorithm = p.Results.algorithm;
saveX = p.Results.saveX;
formNetwork = p.Results.formNetwork;

% Generate random seeds. 
rng(p.Results.randSeed);
randSeeds = randi(1000000,simIter,1);
simResults.info.randSeeds = randSeeds;

% Check if parallel pool exists
if license('test','Distrib_Computing_Toolbox')
    delete(gcp('nocreate'));
    if (nCores > 1)
        parpool(nCores);
    elseif nCores == -1
        pool = gcp();
        nCores = pool.NumWorkers;
    end
else
    parpool(1);
end
forIter = round(simIter/nCores);
simIter = nCores*forIter;

% Turn-off verbose.
varargin = [varargin,{'verbose',0}];

if isempty(conds)
    if ifRegression
        % Noise
        condVals = [0.1, 1, 3, 5];
        condNames = {'zeroOne','one','three', 'five'};
    else
        % CNRs
        condVals = [0.25, 0.5, 0.75, 1];
        condNames = {'twoFive','five','sevenFive','one'};
    end
    nConds = numel(condVals);
else
    condNames = fieldnames(conds);
    nConds = numel(condNames);
    condVals = zeros(nConds,1);
    for c = 1:nConds
        condVals(c) = conds.(condNames{c});
    end
end
simResults.info.conds = condVals;

% Info field in structure.
simResults.info.simIter = simIter;
simResults.info.ifRegression = ifRegression;
simResults.info.dateStarted = date;
simResults.info.algorithm = algorithm;
simResults.info.formNetwork = formNetwork;
simResults.info.saveX = saveX; 

%Output dir
referenceFile = 'start_NBSPredict.m';
baseOutDir = fileparts(which(referenceFile));
baseOutDir = [baseOutDir,filesep,'simulationResults',filesep];
if ~(exist(baseOutDir,'dir')==7)
    mkdirStatus = mkdir(baseOutDir);
    assert(mkdirStatus,'Folder could not be created! Please check folder permissions!')
end

% Preallocate.
[X,y,trueEdges,edgeWeight,sEdgeWeight,edgeIdx,nNodes,testParams] =...
    preAllocSim(ifRegression,condVals,simIter,varargin,saveX);
simResults.info.testParams = testParams;
simResults.info.nNodes = nNodes;
simResults.info.y = y;
time = zeros(simIter,1);

if strcmpi(algorithm,'CPM')
    predPerf = zeros(simIter,2);
else
    predPerf = zeros(simIter,1);
end
%% Run Simulation
fprintf('Started...\n');

iterMsg = '\n\nAlgorithm = %s, Regression = %d, ';
if ifRegression
    iterMsg = [iterMsg,'Noise: %.2f\n\n'];
    cName = 'noise';
    outName = 'Reg';
else
    iterMsg = [iterMsg,'CNR: %.2f\n\n'];
    cName = 'cnr';
    outName = 'Class';
end

% Set output file name.
outputFileName = [baseOutDir,sprintf('simRes_%s_%s_%s.mat',...
    algorithm,outName,date)];
fileNum = 1;
while isfile(outputFileName)
    % Add number at the end to avoid overwriting.
    outputFileName = [baseOutDir,sprintf('simRes_%s_%s_%s_%d.mat',...
        algorithm,outName,date,fileNum)];
    fileNum = fileNum + 1;
end
simResults.info.outputFileName = outputFileName;

startSim = tic;
assign = 1;
for c = 1:nConds
    if c > 1
        assign = 0;
    end
    fprintf(iterMsg,algorithm,ifRegression,condVals(c));
    parameters = {cName,condVals(c)};
    if ~isempty([varargin{:}])
        parameters = {parameters{:},varargin{:}};
    end
    simResults = run_for(simResults,parameters,...
        condNames{c},forIter,nCores,X,y,trueEdges,edgeWeight,...
        sEdgeWeight,edgeIdx,predPerf,time,randSeeds,assign,saveX);
end

simElapsedTime = toc(startSim);
fprintf('\t Time Elapsed: %.2f seconds.\n',simElapsedTime);
simResults.info.dateFinished = date;
simResults.info.elapsedTime = simElapsedTime/60; %in mins.
save(outputFileName,'simResults');

fprintf('\nDone....\n')
end

% Running functions.
function [simResults] = run_for(simResults,parameters,contFieldName,...
    forIter,nCores,X,y,trueEdges,edgeWeight,sEdgeWeight,edgeIdx,...
    predPerf,time,randSeeds,assign,saveX)
% Runs test function recursively and saves the results into simResults
% struct.
j = 1;
reverseStr = '';
for iter = 1:forIter
    cIdx = j:j+nCores-1;
    if saveX
        X_to_parfor = X(cIdx,:,:);
    else
        X_to_parfor = [];
    end
    if simResults.info.ifRegression
        y_to_parfor = y(cIdx,:);
        saveY = 1;
    else
        y_to_parfor = [];
        saveY = 0;
    end
    
    [X_to_parfor,y_to_parfor,trueEdges(cIdx,:),edgeWeight(cIdx,:),...
        sEdgeWeight(cIdx,:), edgeIdx(cIdx,:),predPerf(cIdx,:),time(cIdx)]=...
        run_testFunction(parameters,X_to_parfor,y_to_parfor,trueEdges(cIdx,:),...
        edgeWeight(cIdx,:),sEdgeWeight(cIdx,:),edgeIdx(cIdx,:),...
        predPerf(cIdx,:),time(cIdx),randSeeds(cIdx),assign,saveX,saveY);
    
    if saveX
        X(cIdx,:,:) = X_to_parfor;
    end
    if saveY 
        y(cIdx,:) = y_to_parfor;
    end
    % Show Progress
    % http://undocumentedmatlab.com/articles/command-window-text-manipulation/
    progressMsg = sprintf('Processing: %d/%d\n',iter*nCores,...
        simResults.info.simIter);
    fprintf([reverseStr, progressMsg]);
    reverseStr = repmat(sprintf('\b'), 1, length(progressMsg));
    j = j + nCores;
end
if assign
    if saveX
        simResults.info.X = X;
    end
    if saveY
        simResults.info.y = y;
    end
    simResults.info.edgeIdx = edgeIdx;
    simResults.info.trueEdges = trueEdges;
end
simResults.conds.(contFieldName).edgeWeight = edgeWeight;
simResults.conds.(contFieldName).sEdgeWeight = sEdgeWeight;
simResults.conds.(contFieldName).predPerf = predPerf;
simResults.conds.(contFieldName).time = time;
save(simResults.info.outputFileName,'simResults');
end

function [X,y,trueEdges,edgeWeight,sEdgeWeight,edgeIdx,predPerf,time] =...
    run_testFunction(parameters,X,y,trueEdges,edgeWeight,sEdgeWeight,edgeIdx,...
    predPerf,time,randSeeds,assign,saveX,saveY)
% Run test function n times. It runs the test function in parallel if
% nCores set to more than 1. 
nIter = size(trueEdges,1);
parfor iter = 1: nIter
    startIter = tic;
    params = {parameters{:},'randomState',randSeeds(iter)};
    result = test_NBSPredict(params{:});
    
    if result.parameter.ifModelOpt
        model = result.results.bestEstimator;
    else
        model = result.parameter.MLmodels{1};
    end
    
    if assign
        if saveX
            X(iter,:,:) = result.data.X;
        end
        if saveY
            y(iter,:) = result.data.y(:,2);
        end
        trueEdges(iter,:) = result.data.contrastedEdges;
        edgeIdx(iter,:) = result.data.edgeIdx;
    end
    edgeWeight(iter,:) = result.results.(model).meanEdgeWeight;
    sEdgeWeight(iter,:) = result.results.(model).scaledMeanEdgeWeight;
    predPerf(iter,:) = result.results.(model).meanRepCVscore;
    time(iter) = toc(startIter);
end
end

function [X,y,trueEdges,edgeWeight,sEdgeWeight,edgeIdx,nNodes,paramStruct] =...
    preAllocSim(ifRegression,condVals,simIter,addParameters,saveX)
% Preallocate results for faster memory allocation.
fprintf('Preallocating...\n')
% Preallocate for simulation.
parameters = {'simPreAllocate',1};
if ifRegression
    parameters = {parameters{:},'noise',condVals(1)};
else
    parameters = {parameters{:},'cnr',condVals(1)};
end
if ~isempty([addParameters{:}])
    parameters = {parameters{:},addParameters{:}};
end
preAllocate = test_NBSPredict(parameters{:});
dataSize  = size(preAllocate.data.X);
nFeatures = dataSize(2);
paramStruct = preAllocate.parameter;
nNodes = preAllocate.data.nodes;

% Preallocation
if saveX
    X = ones([simIter,dataSize],'single');
else
    X = [];
end
if ~ifRegression
    y = preAllocate.data.y(:,2);
else
    nSub = numel(preAllocate.data.y(:,2));
    y = ones(simIter,nSub,'single');
end
trueEdges = ones(simIter,nFeatures,'double');
edgeWeight = ones(simIter,nFeatures,'single');
sEdgeWeight = ones(simIter,nFeatures,'single');
edgeIdx = ones(simIter,nFeatures,'single');
end



