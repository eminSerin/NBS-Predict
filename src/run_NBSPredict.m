function [NBSPredict] = run_NBSPredict(NBSPredict)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_NBSPredict is the main function which consists combines machine
% learning with graph theoretical concept of connected components.
% Specifically, it selects features(i.e. edges) using graph-based feature
% selection algorithm and performs prediction in a repeated
% cross-validation structure (nested CV if desired). 
%
% Arguments:
%   NBSPredict - Structure including data and parameters. NBSPredict
%       structure is prepared by NBSPredict GUI. However it could also be
%       provided by user to bypass the GUI (see MANUAL for details).
%
% Output:
%   NBSPredict = Output structure as follows:
%       info = Several information and parameters.
%       parameter: Toolbox parameters.
%       data: Substructure comprising data, contrast, directories and brain
%           parcellation..
%       searchHandle: Function handle for selection algorithm.
%       results: Substructure containing results.
%   This structure is also saved in
%       ~/Results/date/NBSPredict.mat directory.
%
% Last edited by Emin Serin, 27.08.2022
%
% See also: start_NBSPredictGUI, get_NBSPredictInput
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
NBSPredict = get_NBSPredictInput(NBSPredict);
repCViter = NBSPredict.parameter.repCViter;
verbose = NBSPredict.parameter.verbose;

% Random Seed
rndSeeds = generate_randomStream(NBSPredict.parameter.randSeed, repCViter);

% Init parallel pool if desired.
create_parallelPool(NBSPredict.parameter.numCores);

% Write an start tag.
NBSPredict.info.startDate = string(datetime("today"));
startTime = tic;

nEdges = numel(NBSPredict.data.edgeIdx);
nModels = numel(NBSPredict.parameter.MLmodels);
% nSub = size(NBSPredict.data.y,1);

% Preallocation
repCVscore = zeros(repCViter,1,'single');
meanRepCVscore = zeros(nModels,1);
meanRepCVscoreCI = zeros(nModels,2);
edgeWeight = zeros(repCViter,NBSPredict.parameter.kFold,...
    nEdges,'single');
stability = zeros(repCViter,1,'single');
truePredLabels = cell(repCViter, NBSPredict.parameter.kFold,2);
bestParams = cell(repCViter, NBSPredict.parameter.kFold);
corrXy = cell(repCViter, 1);

fileDir = save_NBSPredict(NBSPredict);
cNBSPredict = NBSPredict; % current NBSPredict.
for cModelIdx = 1: nModels
    modelTime = tic;
    % Run repeated nested CV using ML models provided.
    cModel = NBSPredict.parameter.MLmodels{cModelIdx};
    if isfield(NBSPredict.parameter,'paramGrids')
        cNBSPredict.parameter.paramGrids = NBSPredict.parameter.paramGrids(cModelIdx);
    end
    cNBSPredict.parameter.model = cModel; % TODO: remove after oop progress fun.
    MLhandle = gen_MLhandles(cNBSPredict.parameter.model);
    cNBSPredict.MLhandle = MLhandle;
    show_NBSPredictProgress(cNBSPredict,0);
    if cNBSPredict.parameter.numCores > 1
        % Run parallelly.
        parfor r = 1: repCViter
            rng(rndSeeds(r));
            [repCVscore(r),edgeWeight(r,:,:),...
                truePredLabels(r,:,:),stability(r),...
                bestParams(r,:), corrXy{r, :}] = outerFold(cNBSPredict);
            show_NBSPredictProgress(cNBSPredict,r,repCVscore(r));
        end
    else
        % Run sequentially.
        for r = 1: repCViter
            rng(rndSeeds(r));
            [repCVscore(r),edgeWeight(r,:,:),...
                truePredLabels(r,:,:),stability(r),...
                bestParams(r,:), corrXy{r, :}] = outerFold(cNBSPredict);
            show_NBSPredictProgress(cNBSPredict,r,repCVscore);
        end
    end
    
    if NBSPredict.parameter.ifModelExtract
        % Extract model if desired.
        NBSPredict.results.(cModel).model = modelExtract(cNBSPredict);
    end

    % Repeated CV corr between edges and outcome
    if ~NBSPredict.parameter.ifClass
        NBSPredict.results.(cModel).corrXyMat = gen_weightedAdjMat(NBSPredict.data.nodes, ...
            NBSPredict.data.edgeIdx, ...
            sum(cell2mat(corrXy'), 2));
    end
    
    % Repeated CV scores.
    meanRCVscore =  mean(repCVscore);
    meanRepCVscore(cModelIdx) = meanRCVscore;
    meanRepCVscoreCI(cModelIdx,:) = compute_CI(repCVscore);
    
    % True and predicted labels
    NBSPredict.results.(cModel).truePredLabels = truePredLabels;
    
    % Stability
    NBSPredict.results.(cModel).stability = stability;
    NBSPredict.results.(cModel).meanStability = mean(stability);
    
    % Best hyperparameters. 
    NBSPredict.results.(cModel).bestParams = bestParams;
    
    % EdgeWeights
    maxScore_ = meanRCVscore; % will be used while scaling edge weights. 
    if ismember(NBSPredict.parameter.metric,{'rmse','mse','mad'})
        maxScore_ = compute_mRCVscore(truePredLabels, 'correlation');
    end
    totalFold = NBSPredict.parameter.repCViter*NBSPredict.parameter.kFold;
    [NBSPredict.results.(cModel).edgeWeight,NBSPredict.results.(cModel).meanEdgeWeight,...
        NBSPredict.results.(cModel).wAdjMat,NBSPredict.results.(cModel).scaledMeanEdgeWeight,...
        NBSPredict.results.(cModel).scaledWAdjMat] =...
        compute_meanWeights(edgeWeight,maxScore_,NBSPredict.data.nodes,nEdges,NBSPredict.data.edgeIdx,totalFold);
    
    % Save values to NBSPredict.
    NBSPredict.results.(cModel).repCVscore = repCVscore;
    NBSPredict.results.(cModel).meanCVscoreCI = meanRepCVscoreCI(cModelIdx,:);
    NBSPredict.results.(cModel).meanRepCVscore = meanRepCVscore(cModelIdx);
    show_NBSPredictProgress(cNBSPredict,-1,repCVscore);
    
    if verbose
        toc(modelTime);
    end
    
    % Run Permutation test.
    if NBSPredict.parameter.ifPerm
        NBSPredict.results.(cModel).permScore = run_permTesting(cNBSPredict);
    end
        
end

if ismember(NBSPredict.parameter.metric,{'mad','rmse','mse'})
    [~,bestEstimatorIdx] = min(meanRepCVscore); % find min error.
else
    [~,bestEstimatorIdx] = max(meanRepCVscore); % find min error.
end

if NBSPredict.parameter.ifModelOpt
    NBSPredict.results.bestEstimator = NBSPredict.parameter.MLmodels{bestEstimatorIdx};
    if verbose
        % Print summary results if more than one estimators are used.
        fprintf('\n\n\n\t\t\t<strong>OVERALL RESULTS:</strong>\n\n');
        for cModelIdx = 1:nModels
            fprintf(['ML Estimator: %s,\n\tMean Repeated CV Score: %.2f,\n\t',...
                'Confidence Interval: [%.2f,%.2f]\n'],...
                NBSPredict.parameter.MLmodels{cModelIdx},meanRepCVscore(cModelIdx),...
                meanRepCVscoreCI(cModelIdx,:))
        end
        fprintf('Estimator with minimum error is <strong>%s</strong> \n',NBSPredict.results.bestEstimator);
    end
end

NBSPredict.info.endDate = string(datetime("today"));
timeElapsed = toc(startTime); % in minutes;
NBSPredict.info.timeElapsed = timeElapsed;

if verbose
    fprintf('Total time elapsed (in minutes): %.2f\n',timeElapsed/60);
end

if isstring(fileDir)
    if verbose
       fprintf('\nResults are being saved...\n') 
    end
    save(fileDir,'NBSPredict');
end

if NBSPredict.parameter.ifView
    % Run post analysis view window.
    view_NBSPredict(NBSPredict);
end
end

function varargout = outerFold(NBSPredict)
% outerFold is the first (or outer) layer of the 2-layer nested
% cross-validation structure. outerFold performs model evaluation.
% Prepare data.
data.X = NBSPredict.data.X;
data.y = NBSPredict.data.y;
if ~isempty(NBSPredict.data.confounds)
    % Check if confounds are provided.
    data.confounds = NBSPredict.data.confounds;
end

% Model handler.
modelEvaluateFun = @(data) modelEvaluate(data,NBSPredict);
[outerFoldCVresults] = crossValidation(modelEvaluateFun,data,...
    'kfold',NBSPredict.parameter.kFold); % Run handler in CV.

    function [modelEvalResults] = modelEvaluate(data,NBSPredict)
        % Preprocess data.
        data = preprocess_data(data,NBSPredict.parameter.scalingMethod);
        
        % Run hyperparameter optimization in the inner fold if desired.
        params = [];
        if NBSPredict.parameter.ifHyperOpt 
            %Prepare data for middle fold.
            middleFoldData.X = data.X_train;
            middleFoldData.y = data.y_train;
            if isfield(data,'confounds_train')
                middleFoldData.confounds = data.confounds_train;
            end
            params = middleFoldHyperOpt(middleFoldData,NBSPredict);
        end
        modelEvalResults.params = params;
        
        filterData.X = data.X_train;
        filterData.y = data.y_train;
        if ~NBSPredict.parameter.ifClass
            modelEvalResults.corrXy = corr(filterData.X, filterData.y(:, 2));
        end
        edgeSelectMask = run_graphPval(filterData,NBSPredict);
        
        
        % Transform data for model evaluation using parameters found in middle fold.
        modelEvalData.X = data.X_train;
        modelEvalData.y = data.y_train;
        
        X_train_transformed = modelEvalData.X(:,edgeSelectMask);
        
        % Reconstruct data structure.
        data.X_train = X_train_transformed;
        data.X_test  = data.X_test(:,edgeSelectMask);
        data.y_test = data.y_test(:,2);
        data.y_train = data.y_train(:,2);
        
        [modelEvalResults.score,modelEvalResults.truePredLabels,...
            ~] = fit_hyperParam(data,params,NBSPredict.MLhandle,...
            NBSPredict.parameter.metric);
        weightScore = modelEvalResults.score;
        
        if ismember(NBSPredict.parameter.metric,{'rmse','mse','mad'})
            weightScore = compute_modelMetrics(modelEvalResults.truePredLabels{1},...
                modelEvalResults.truePredLabels{2},...
                'correlation');
        end
        % Multiply features selected with test score of model to compute
        % weight for each feature.
        modelEvalResults.outerFoldEdgeWeight = edgeSelectMask .* weightScore;
    end


varargout{1} = mean([outerFoldCVresults.score]);
varargout{2} = [outerFoldCVresults.outerFoldEdgeWeight]';
varargout{3} = reshape([outerFoldCVresults.truePredLabels],2,[])';
varargout{4} = compute_stability(single([outerFoldCVresults.outerFoldEdgeWeight]' > 0));
varargout{5} = {outerFoldCVresults.params};
varargout{6} = [];
if ~NBSPredict.parameter.ifClass
    varargout{6} = sum([outerFoldCVresults.corrXy], 2);
end
end

function [bestParam] = middleFoldHyperOpt(data,NBSPredict)
% middleFold is the second (or middle) layer of the 2-layer nested
% cross-validation structure. middleFold performs feature selection using a
% searching algorithm selected. If requested, a function for hyperparameter
% optimization (i.e., inner layer) is called in this function.
hyperOptFun = @(data,param) optimize_hyperOpt(data,NBSPredict,param);
[bestParam] = NBSPredict.searchHandle(hyperOptFun,data,...
    NBSPredict.parameter.paramGrids);

    function [hyperOptResults] = optimize_hyperOpt(data,NBSPredict,params)
        % Preprocess data.
        data = preprocess_data(data,NBSPredict.parameter.scalingMethod);
        
        % Select features.
        filterData.X = data.X_train;
        filterData.y = data.y_train;
        edgeSelectMask = run_graphPval(filterData,NBSPredict);
        
        % Construct labels.
        data.y_test = data.y_test(:,2);
        data.y_train = data.y_train(:,2);
        
        % Transform data with selected features.
        data.X_train = data.X_train(:,edgeSelectMask);
        data.X_test = data.X_test(:,edgeSelectMask);
        
        % Fit model and get score.
        if ~NBSPredict.parameter.ifHyperOpt
            params = [];
        end
        hyperOptResults.score = fit_hyperParam(data,params,NBSPredict.MLhandle,...
            NBSPredict.parameter.metric);
    end
end

function [edgeSelectMask] = run_graphPval(data,NBSPredict)
% run_graphPval is a univariate feature selection method that combines
% univariate statistical methods (t-test or F-test) and graph theoretical
% concept of connected component.
[~, pVal] = run_nbsPredictGlm(data.y,data.X,NBSPredict.parameter.contrast,...
    NBSPredict.parameter.test);
cEdgesIdx = find(pVal < NBSPredict.parameter.pVal);
[extIdx] = extractComponentIdx(NBSPredict.data.nodes,...
    NBSPredict.data.edgeIdx,cEdgesIdx);
edgeSelectMask = false(size(data.X,2),1);
edgeSelectMask(extIdx) = true;
if isempty(cEdgesIdx)
   warning(['No features survived the feature selection! ',...
       'The data might not contain enough effect or you should ',...
       'use more liberal p-value thresholds!'])
end
end

function [model] = modelExtract(NBSPredict)
% Extracts model if desired. 
% It runs the pipeline using all the data (no-CV). 

data.X = NBSPredict.data.X;
data.y = NBSPredict.data.y;
if ~isempty(NBSPredict.data.confounds)
    % Check if confounds are provided.
    data.confounds = NBSPredict.data.confounds;
end

% Preprocess the data. 
[data, preprocess.scaler, preprocess.confCorr] = preprocess_data(data, ...
    NBSPredict.parameter.scalingMethod);

params = [];
if NBSPredict.parameter.ifHyperOpt
    % Perfom hyperparameter optimization if selected.
    params = middleFoldHyperOpt(data,NBSPredict);
end
preprocess.edgeSelectMask = run_graphPval(data, NBSPredict); % Feature selection.
data.X = data.X(:, preprocess.edgeSelectMask);
data.y = data.y(:, 2);
Mdl = NBSPredict.MLhandle(params);
estimator = Mdl.fit(data.X, data.y); % Fit model.
predictor = @(X, confMat) predict_label(estimator, X, Mdl, edgeSelectMask, ...
    scaler, confCorr, confMat);

% Save parameters and models into a structure.
model.Mdl = Mdl;
model.estimator = estimator;
model.predictor = predictor; 
model.preprocess = preprocess;
end

function permScore = run_permTesting(NBSPredict)
% Run Permutation test.
% It randomly permutes target variable and run the same pipeline. 
% It returns permutation score and p-value
% p-value represents the fraction of models yielding similar to or better
% prediction performance than the tested model.
if NBSPredict.parameter.ifPerm
    permIter = NBSPredict.parameter.permIter;
    fprintf('Permutation testing is running! Permutations: %d\n',...
        permIter);
    
    % Random Seed
    if NBSPredict.parameter.randSeed ~= -1 % -1 refers to random shuffle.
        rng(NBSPredict.parameter.randSeed);
    else
        rng('shuffle');
    end
    rndSeeds = generate_randomStream(randi(1e+9), permIter);
    
    nSub = size(NBSPredict.data.y,1);
    permCVscore = zeros(permIter+1, 1, 'single');
    [permCVscore(1),~, ~, ~] = outerFold(NBSPredict);
    if NBSPredict.parameter.numCores > 1
        if isempty(gcp('nocreate'))
            % Init parallel pool if desired.
            create_parallelPool(NBSPredict.parameter.numCores);
        end
        pctRunOnAll warning off % Suppress warnings.
        if NBSPredict.parameter.verbose
            permMsg = 'This will take quite time. Please be patient...\n';
            fprintf(permMsg)
        end
        parfor p = 1: permIter
            rng(rndSeeds(p));
            permNBSPredict = NBSPredict;
            permNBSPredict.data.y = permNBSPredict.data.y(randperm(nSub), :);
            [permCVscore(p+1),~, ~, ~] = outerFold(permNBSPredict);
        end
    else
        warning('off') % Suppress warnings.
        if NBSPredict.parameter.verbose
            permMsg = 'Progress:';
            permProg = CmdProgress(permMsg, permIter);
        end
        for p = 1: permIter
            rng(rndSeeds(p));
            permNBSPredict = NBSPredict;
            permNBSPredict.data.y = permNBSPredict.data.y(randperm(nSub), :);
            [permCVscore(p+1),~, ~, ~] = outerFold(permNBSPredict);
            permProg.increment;
        end
    end
    permScore = [permCVscore(1), ...
        (sum(permCVscore >= permCVscore(1))-1)/permIter];
    if NBSPredict.parameter.verbose
        fprintf(['Permutation testing has finished. ',...
            'Prediction performance: %.3f, p = %.3f\n'],...
            permScore(1), permScore(2));
    end
    warning('on'); % Reactivate warnings.
end
end

%% Helper functions
function varargout = fit_hyperParam(data,hyperparam,MLhandle,metrics)
% fit_hyperParam fits ML algorithm on provided data with hyperparameters
% provided.
Mdl = MLhandle(hyperparam);
if ischar(metrics)
    metrics = {metrics};
end
nMetrics = numel(metrics);
varargout = cell(1,nMetrics+2);

[varargout{:}] = modelFitScore(Mdl,data,metrics);
end

function [reshapedEdgeWeight,meanEdgeWeight,wAdjMat,scaledMeanEdgeWeight,scaledWAdjMat]...
    = compute_meanWeights(edgeWeight,CVscore,nNodes,nEdges,edgeIdx,totalFold)
% compute_meanWeights computes vector and adjacency matrix of mean edge
% weights. It also returns scaled version of those outputs using
% MinMaxScaler. 

% Edge Weights
reshapedEdgeWeight = reshape(ipermute(edgeWeight,[3 2 1]),nEdges,[]);

% Mean edge weight.
meanEdgeWeight = mean(reshapedEdgeWeight,2);
wAdjMat = gen_weightedAdjMat(nNodes,edgeIdx,meanEdgeWeight); % weighted Adj matrix.

% Scaled mean edge weight
scaler = MinMaxScaler([0,CVscore]);
scaledMeanEdgeWeight = scaler.fit_transform(meanEdgeWeight); % Min-max scaled mean weights
scaledMeanEdgeWeight = round(scaledMeanEdgeWeight,round(log10(totalFold))+1); % Tolarate minor difference. 
scaledWAdjMat = gen_weightedAdjMat(nNodes,edgeIdx,scaledMeanEdgeWeight); % weighted Adj matrix.
end

function [fileDir] = save_NBSPredict(NBSPredict)
% save_NBSPredict saves NBSPredict structure in a results folder in the main
% directory of the toolbox. It will save in a file which is named with the
% current date of analysis. If there is another NBSPredict exists in the
% same folder (i.e., multiple analysis in a day), the current file is named
% with suffix.
if NBSPredict.parameter.ifSave
    referencePath = NBSPredict.data.corrPath;
    saveDir = fileparts(referencePath); % parent directory
    if NBSPredict.parameter.ifTest
        saveDir = fullfile(saveDir, "test", "Results", string(datetime("today")));
    else
        saveDir = fullfile(saveDir, "Results", string(datetime("today")));
    end
    fileDir = fullfile(saveDir, 'NBSPredict.mat');
    if ~exist(saveDir, 'dir')
        mkdirStatus = mkdir(saveDir);
        assert(mkdirStatus,'Folder could not be created! Please check folder permissions!');
    else
        fileNum = 1;
        while exist(fileDir, 'file') == 2
            fileDir = fullfile(saveDir, sprintf("NBSPredict_%d.mat", fileNum));
            fileNum = fileNum + 1;
        end
    end
    save(fileDir,'NBSPredict');
else
    if ~NBSPredict.parameter.ifTest
        warning(['Save parameter is disabled! So, NBSPredict file will not be saved!',...
            ' To save it, set ifSave to 1.']);
    end
    fileDir = 0;
end
end