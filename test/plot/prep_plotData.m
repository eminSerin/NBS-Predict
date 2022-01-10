function [plotData] = prep_plotData(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prep_plotData prepares data for simulation plots. Data can be used by
% gen_SimFigures function to plot results. The files generated using this
% function can be used by prep_plotData function.
%   
% Arguments:
%   Simulation results derived using sim_testNBSPredict function
%       (e.g. simRes_CPM_Reg_09-Apr-2021.mat).
%   metrics = Cell array including performance metrics
%      (default = {'sensitivity','specificity'}). Available metrics are
%      documented in compute_modelMetrics function.
%   wtSteps = Weight threshold steps between 0 and 1 (default = 100).
%   numCores  = Number of CPU cores to use (default = 1).
%   ifSave  = Save processed data to generate plots (default = 1). If true
%       it will save processed file into
%       ~/plotData/[inputFileName]_plotData.mat
%    
% Output:
%   plotData = Structure including results of simulation for NBSPredict.
%
% Example:
%   [plotData] = prep_plotData;
%   [plotData] = prep_plotData('wtSteps',50,'nCores',4,...
%       'metrics',{'precision','recall'});
%
% Created by Emin Serin, 11.04.2021
%
% See also: sim_testNBSPredict, plot_plotData, compute_modelMetrics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters
% Default parameters
defaultVals.ifSave = 10; defaultVals.wtSteps = 100;
defaultVals.numCores = 1; defaultVals.weightPredPerf = 0;
defaultVals.metrics = {'sensitivity','specificity'};

% Validation
validationNumeric = @(x) isnumeric(x);
p = inputParser();
p.PartialMatching = 0; % deactivate partial matching.

% Add NBSPredict parameters.
addParameter(p,'ifSave',defaultVals.ifSave);
addParameter(p,'weightPredPerf',defaultVals.weightPredPerf);
addParameter(p,'wtSteps',defaultVals.wtSteps);
addParameter(p,'numCores',defaultVals.numCores,validationNumeric);
addParameter(p,'metrics',defaultVals.metrics);

% Parse inputs.
parse(p,varargin{:});

ifSave = p.Results.ifSave;
wtSteps = p.Results.wtSteps;
metrics = p.Results.metrics;
numCores = p.Results.numCores;
weightPredPerf = p.Results.weightPredPerf;

% Init parallel pool if desired.
create_parallelPool(numCores);

% Load simulation data.
[files, path] = uigetfile('.mat','Please load simulation results .mat file.',...
    'MultiSelect','on');

if ~iscell(files)
    files = {files};
end

nFiles = numel(files);
fprintf('\n');
for f = 1: nFiles
    cFile = files{f};
    load([path cFile]);
    fprintf('Progress: %d/%d File: %s\n',f,nFiles,cFile);
    plotData = prep_data(simResults,wtSteps,metrics,weightPredPerf);
    if ifSave
        if simResults.info.ifRegression
            prob = 'Reg';
        else
            prob = 'Class';
        end
        outDir = [path,filesep,'plotData',filesep,prob,filesep];
        if ~(exist(outDir,'dir')==7)
            mkdirStatus = mkdir(outDir);
            assert(mkdirStatus,'Folder could not be created! Please check folder permissions!')
        end
        save([outDir,cFile(1:end-4),'_plotData.mat'],'plotData')
    end
end
fprintf('-------DONE------\n');

end

function [plotData] = prep_data(simResults,wtSteps,metrics,weightPredPerf)
% Get parameters.
conds = fieldnames(simResults.conds);
weightTresh = linspace(0,1,wtSteps);
trueEdges = simResults.info.trueEdges;
algorithm = simResults.info.algorithm;
nNodes = simResults.info.nNodes;

subNetwork = strcmpi(algorithm,'NBSPredict');
if subNetwork
    edgeIdx = simResults.info.edgeIdx;
else
    edgeIdx = [];
end

if weightPredPerf
    if all(isfield(simResults.info,{'y','X'}))
        data.X = simResults.info.X;
        data.y = simResults.info.y;
        data.model = simResults.info.testParams.MLmodels{1};
        if simResults.info.ifRegression
            metrics = {metrics{:},'weight_correlation'};
        else
            metrics = {metrics{:},'weight_accuracy'};
        end
    else
        errorMsg =...
            ["You can't evaluate the prediction performance of weight threshold,",...
            " because X or y doesn't exist in simResults.info substructure.",...
            " Set weightPredPerf parameter to 0 to continue!"];
        error(errorMsg);
    end
else
    data = [];
end

% Save into plotData
plotData.info.simulationInfo = simResults.info;
plotData.info.metrics = metrics;
plotData.info.weightTresh = weightTresh;

% Parameter length
nConds = numel(conds);

% 
for c = 1: nConds
    cCond = conds{c};
    edgeWeight = simResults.conds.(cCond).sEdgeWeight;
    plotData.conds.(cCond) = compute_perf(data,trueEdges,edgeWeight,edgeIdx,...
        weightTresh,wtSteps,metrics,subNetwork,nNodes);
    plotData.conds.(cCond).time = simResults.conds.(cCond).time;
    plotData.conds.(cCond).predPerf = simResults.conds.(cCond).predPerf;
end

end

function [perf] = compute_perf(data,trueEdges,edgeWeights,edgeIdx,...
    weightTresh,wtSteps,metrics,subNetwork,nNodes)
% Computes given performance metrics for each iteration of simulation. 
nSim = size(trueEdges,1);
nMetrics = numel(metrics);
tmp = zeros(nSim,nMetrics,wtSteps);
parfor simIter = 1:nSim
    cEdgeIdx = edgeIdx;
    if subNetwork
        cEdgeIdx = edgeIdx(simIter,:);
    end
    cData = data;
    if ~isempty(cData)
        cData.X = cData.X(simIter,:);
        cData.y = cData.y(simIter,:);
    end
    tmp(simIter,:,:) = comp_thresholdPerf(cData,trueEdges(simIter,:),...
        edgeWeights(simIter,:),cEdgeIdx,weightTresh,wtSteps,...
        metrics,subNetwork,nNodes);
end
for m = 1: nMetrics
    cMetric = metrics{m};
    perf.(cMetric) = compute_stats(squeeze(tmp(:,m,:)));
end
end

function [perf] = comp_thresholdPerf(data,trueEdges,edgeWeights,edgeIdx,...
    weightTresh,wtSteps,metrics,subNetwork,nNodes)
% Computes performance for each threshold steps. It will also evaluate
% prediction performance of each selected set of suprathreshold edges using
% 10-fold CV. 
nMetrics = numel(metrics);
if ~isempty(data)
    nMetrics = nMetrics - 1;
end
perf = zeros(nMetrics,wtSteps);
for w = 1: wtSteps
    thresh = weightTresh(w);
    if thresh > 0
        selectedEdges = edgeWeights >= thresh;
    else
        selectedEdges = edgeWeights > thresh;
    end
    if subNetwork
        % Identify connected components if NBSPredict.
        extIdx = extractComponentIdx(nNodes,edgeIdx,selectedEdges);
        selectedEdges = false(size(edgeIdx));
        selectedEdges(extIdx) = true;
    end
    
    for m = 1:nMetrics
        cMetric = metrics{m};
        perf(m,w) = compute_modelMetrics(trueEdges,selectedEdges,cMetric);
    end
    
    if ~isempty(data)
        % Evaluate prediction performance!
        cMetric = metrics{end}; 
        perf(end,w) = nanmean(runCV(data,cMetric(8:end)));
    end
end
end

function [results] = compute_stats(perf)
% compute_CI gets full data matrix of values and return mean, se, std.
results.perf = perf;
results.mean = nanmean(perf,1);
results.std = std(perf);
results.se = results.std/sqrt(size(perf,1));
end

function CVscores = runCV(inData,metric)
% If desired it evaluates prediction performance of each selected set of
% features using simple 10-fold CV. It run the same ML model used in the
% simulation. The performance is evaluated using correlation coefficient
% (regression) or accuracy (classification).
data.X = inData.X;
data.y = inData.y;
model = inData.model;

if ~isempty(X)
    subnetEvalFun = @(data) subnetEvaluate(data,model,metric);
    CVscores = crossValidation(subnetEvalFun,data,'kfold',10); % Run handler in CV.
else
    CVscores = zeros(nFold,1);
end

    function score = subnetEvaluate(data,model,metric)
        MLhandle = gen_MLhandles(model);
        Mdl = MLhandle();
        score = modelFitScore(Mdl,data,metric);
    end
end



