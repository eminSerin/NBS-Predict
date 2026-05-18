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
%           parcellation.
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

% Preallocation
repCVscore = zeros(repCViter,NBSPredict.parameter.kFold,'single');
meanRepCVscore = zeros(nModels,1);
meanRepCVscoreCI = zeros(nModels,2);
edgeWeight = zeros(repCViter,NBSPredict.parameter.kFold,...
    nEdges,'single');
selectedEdges = false(repCViter, NBSPredict.parameter.kFold, nEdges);
statWeightedEdges = zeros(repCViter, NBSPredict.parameter.kFold,...
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
    cNBSPredict.parameter.model = cModel;
    MLhandle = gen_MLhandles(cNBSPredict.parameter.model);
    cNBSPredict.MLhandle = MLhandle;
    show_NBSPredictProgress(cNBSPredict,0);
    if cNBSPredict.parameter.numCores > 1
        % Run parallelly.
        parfor r = 1: repCViter
            set_seed(rndSeeds(r));
            [repCVscore(r,:),edgeWeight(r,:,:),...
                truePredLabels(r,:,:),stability(r),...
                bestParams(r,:), corrXy{r, 1}, ...
                selectedEdges(r,:,:), ...
                statWeightedEdges(r,:,:)] = outerFold(cNBSPredict);
            show_NBSPredictProgress(cNBSPredict,r,mean(repCVscore(r,:)));
        end
    else
        % Run sequentially.
        for r = 1: repCViter
            set_seed(rndSeeds(r));
            [repCVscore(r,:),edgeWeight(r,:,:),...
                truePredLabels(r,:,:),stability(r),...
                bestParams(r,:), corrXy{r, 1}, ...
                selectedEdges(r,:,:), ...
                statWeightedEdges(r,:,:)] = outerFold(cNBSPredict);
            show_NBSPredictProgress(cNBSPredict,r,mean(repCVscore,2));
        end
    end
    
    if NBSPredict.parameter.ifModelExtract
        % Extract model if desired.
        NBSPredict.results.(cModel).model = modelExtract(cNBSPredict);
    end

    % Repeated CV corr between edges and outcome
    if ~NBSPredict.parameter.ifClass
        totalFold = NBSPredict.parameter.repCViter*NBSPredict.parameter.kFold;
        NBSPredict.results.(cModel).corrXyMat = gen_weightedAdjMat(NBSPredict.data.nodes, ...
            NBSPredict.data.edgeIdx, ...
            sum(cell2mat(corrXy'), 2) / totalFold);
    end
    
    % Repeated CV scores.
    meanRepScore = mean(repCVscore,2);
    meanRCVscore =  mean(meanRepScore);
    meanRepCVscore(cModelIdx) = meanRCVscore;
    meanRepCVscoreCI(cModelIdx,:) = compute_CI(repCVscore(:));
    
    % True and predicted labels
    truePredLabels = cellfun(@single, truePredLabels, 'UniformOutput', false);
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
    NBSPredict.results.(cModel).selectedEdges = ...
        reshape(ipermute(selectedEdges,[3 2 1]),nEdges,[]);
    NBSPredict.results.(cModel).statWeightedEdges = ...
        reshape(ipermute(statWeightedEdges,[3 2 1]),nEdges,[]);
    
    % Save values to NBSPredict.
    NBSPredict.results.(cModel).repCVscore = repCVscore;
    NBSPredict.results.(cModel).meanCVscoreCI = meanRepCVscoreCI(cModelIdx,:);
    NBSPredict.results.(cModel).meanRepCVscore = meanRepCVscore(cModelIdx);
    show_NBSPredictProgress(cNBSPredict,-1,meanRepScore);
    
    if verbose
        toc(modelTime);
    end
    
    % Run Permutation test.
    if NBSPredict.parameter.ifPerm
        [NBSPredict.results.(cModel).permScore, ...
            NBSPredict.results.(cModel).permTruePredLabels, ...
            NBSPredict.results.(cModel).permEdgeWeight, ...
            NBSPredict.results.(cModel).permSelectedEdges, ...
            NBSPredict.results.(cModel).permStatWeightedEdges] = ...
            run_permTesting(cNBSPredict, meanRepCVscore(cModelIdx));
        NBSPredict.results.(cModel).permEdgeWeightPValues = ...
            compute_permEdgePvals(NBSPredict.results.(cModel).edgeWeight, ...
            NBSPredict.results.(cModel).permEdgeWeight);
        NBSPredict.results.(cModel).permSelectedEdgesPValues = ...
            compute_permEdgePvals(NBSPredict.results.(cModel).selectedEdges, ...
            NBSPredict.results.(cModel).permSelectedEdges);
        NBSPredict.results.(cModel).permStatWeightedEdgesPValues = ...
            compute_permEdgePvals(NBSPredict.results.(cModel).statWeightedEdges, ...
            NBSPredict.results.(cModel).permStatWeightedEdges);
    end
        
end

if ismember(NBSPredict.parameter.metric,{'mad','rmse','mse'})
    [~,bestEstimatorIdx] = min(meanRepCVscore); % find min error.
else
    [~,bestEstimatorIdx] = max(meanRepCVscore); % find max score.
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
        fprintf('Best estimator is <strong>%s</strong> \n',NBSPredict.results.bestEstimator);
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
    save_wrapper(fileDir,NBSPredict);
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
        [edgeSelectMask, edgeStats] = run_graphPval(filterData,NBSPredict);
        modelEvalResults.edgeSelectMask = edgeSelectMask;
        
        
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
        modelEvalResults.statWeightedEdges = single(edgeSelectMask .* edgeStats);
    end


varargout{1} = single([outerFoldCVresults.score]);
varargout{2} = [outerFoldCVresults.outerFoldEdgeWeight]';
varargout{3} = cellfun(@single, reshape([outerFoldCVresults.truePredLabels],2,[])', ...
    'UniformOutput', false);
varargout{4} = compute_stability(single([outerFoldCVresults.edgeSelectMask]'));
varargout{5} = {outerFoldCVresults.params};
varargout{6} = [];
if ~NBSPredict.parameter.ifClass
    varargout{6} = sum([outerFoldCVresults.corrXy], 2);
end
varargout{7} = [outerFoldCVresults.edgeSelectMask]';
varargout{8} = [outerFoldCVresults.statWeightedEdges]';
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

function [edgeSelectMask, testStats] = run_graphPval(data,NBSPredict)
% run_graphPval is a univariate feature selection method that combines
% univariate statistical methods (t-test or F-test) and graph theoretical
% concept of connected component.
[testStats, pVal] = run_nbsPredictGlm(data.y,data.X,NBSPredict.parameter.contrast,...
    NBSPredict.parameter.test);
testStats = testStats(:);
cEdgesIdx = find(pVal < NBSPredict.parameter.pVal);
if isempty(cEdgesIdx)
   warning(['No features survived the feature selection! ',...
       'The data might not contain enough effect or you should ',...
       'use more liberal p-value thresholds!'])
   edgeSelectMask = false(size(data.X,2),1);
   return;
end
[extIdx] = extractComponentIdx(NBSPredict.data.nodes,...
    NBSPredict.data.edgeIdx,cEdgesIdx);
edgeSelectMask = false(size(data.X,2),1);
edgeSelectMask(extIdx) = true;
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

params = [];
if NBSPredict.parameter.ifHyperOpt
    % Perfom hyperparameter optimization if selected.
    params = middleFoldHyperOpt(data,NBSPredict);
end

% Preprocess the data. 
[data, preprocess.scaler, preprocess.confCorr] = preprocess_data(data, ...
    NBSPredict.parameter.scalingMethod);

preprocess.edgeSelectMask = run_graphPval(data, NBSPredict); % Feature selection.
data.X = data.X(:, preprocess.edgeSelectMask);
data.y = data.y(:, 2);
Mdl = NBSPredict.MLhandle(params);
estimator = Mdl.fit(data.X, data.y); % Fit model.

% Save parameters and models into a structure.
model.Mdl = Mdl;
model.estimator = estimator;
model.preprocess = preprocess;
model.preprocess.edgeIdx = NBSPredict.data.edgeIdx;
model.predictor = @(X, confMat) NBSPredict_predict(model, 'connectome', X, 'confMat', confMat);
end

function [permScore, permTruePredLabels, permEdgeWeight, permSelectedEdges, ...
    permStatWeightedEdges] = run_permTesting(NBSPredict, observedScore)
% Run Permutation test.
% It randomly permutes target variable and runs the same repeated CV
% pipeline as the main training loop.
% It returns the p-value derived from the null distribution.
% p-value represents the fraction of permuted models yielding similar to
% or better prediction performance than the observed model.
%
% Arguments:
%   NBSPredict    - NBSPredict structure (current model).
%   observedScore - Mean repeated CV score from the main training run.
%                   Passed in to avoid redundant re-computation.
%
% Output:
%   permScore          - [observedScore, pValue].
%   permTruePredLabels - Null labels as permIter x repCViter x kFold x 2 cells.
%   permEdgeWeight     - Mean null edge weights as permIter x nEdges.
%   permSelectedEdges  - Mean null selected edges as permIter x nEdges.
%   permStatWeightedEdges - Mean null statistic-weighted edges as permIter x nEdges.
permIter = NBSPredict.parameter.permIter;
repCViter = NBSPredict.parameter.repCViter;
fprintf('Permutation testing is running! Permutations: %d\n', permIter);

% Random Seed
if NBSPredict.parameter.randSeed ~= -1 % -1 refers to random shuffle.
    set_seed(NBSPredict.parameter.randSeed);
else
    set_seed('shuffle');
end

% Generate seeds: one master seed per permutation iteration.
permSeeds = generate_randomStream(randi(1e+9), permIter);

nSub = size(NBSPredict.data.y,1);
nEdges = numel(NBSPredict.data.edgeIdx);
permCVscore = zeros(permIter+1, 1, 'single');
permTruePredLabels = cell(permIter, repCViter, NBSPredict.parameter.kFold, 2);
permEdgeWeight = zeros(permIter, nEdges, 'single');
permSelectedEdges = zeros(permIter, nEdges, 'single');
permStatWeightedEdges = zeros(permIter, nEdges, 'single');

% Use the observed score from the main training run directly.
permCVscore(1) = single(observedScore);

if NBSPredict.parameter.numCores > 1
    if isempty(gcp('nocreate'))
        % Init parallel pool if desired.
        create_parallelPool(NBSPredict.parameter.numCores);
    end
    pctRunOnAll warning off % Suppress warnings.
    if NBSPredict.parameter.verbose
        permMsg = 'This will take quite time. Please be patient...\n';
        fprintf(permMsg);

        % Setup progress tracking for parfor
        if ~verLessThan('matlab', '9.2') % R2017a+
            permProg = CmdProgress('Progress:', permIter);
            dq = parallel.pool.DataQueue;
            afterEach(dq, @(~) permProg.increment());
        else
            fprintf('Progress (each dot = 1 perm): \n');
        end
    end

    parfor p = 1: permIter
        set_seed(permSeeds(p));
        permNBSPredict = NBSPredict;
        permNBSPredict.data.y = permNBSPredict.data.y(randperm(nSub), :);
        % Repeated CV for this permutation.
        repSeeds = generate_randomStream(randi(1e+9), repCViter);
        repScores = zeros(repCViter, NBSPredict.parameter.kFold, 'single');
        cPermEdgeWeight = zeros(repCViter, NBSPredict.parameter.kFold, nEdges, 'single');
        cPermSelectedEdges = false(repCViter, NBSPredict.parameter.kFold, nEdges);
        cPermStatWeightedEdges = zeros(repCViter, NBSPredict.parameter.kFold, nEdges, 'single');
        cPermTruePredLabels = cell(repCViter, NBSPredict.parameter.kFold, 2);
        for r = 1:repCViter
            set_seed(repSeeds(r));
            [repScores(r,:),cPermEdgeWeight(r,:,:), ...
                cPermTruePredLabels(r,:,:), ~, ~, ~, ...
                cPermSelectedEdges(r,:,:), ...
                cPermStatWeightedEdges(r,:,:)] = outerFold(permNBSPredict);
        end
        permCVscore(p+1) = mean(repScores(:));
        permTruePredLabels(p,:,:,:) = cPermTruePredLabels;
        cPermEdgeWeightFlat = reshape(ipermute(cPermEdgeWeight,[3 2 1]),nEdges,[]);
        permEdgeWeight(p,:) = mean(cPermEdgeWeightFlat,2);
        cPermSelectedEdgesFlat = reshape(ipermute(cPermSelectedEdges,[3 2 1]),nEdges,[]);
        permSelectedEdges(p,:) = mean(single(cPermSelectedEdgesFlat),2);
        cPermStatWeightedEdgesFlat = reshape(ipermute(cPermStatWeightedEdges,[3 2 1]),nEdges,[]);
        permStatWeightedEdges(p,:) = mean(cPermStatWeightedEdgesFlat,2);

        if NBSPredict.parameter.verbose
            if ~verLessThan('matlab', '9.2')
                send(dq, 1);
            else
                fprintf('.');
            end
        end
    end

    if NBSPredict.parameter.verbose && verLessThan('matlab', '9.2')
        fprintf('\n'); % Clean up newline for legacy fallback
    end
    pctRunOnAll warning on % Reactivate warnings.
else
    prevWarningState = warning('off'); % Suppress warnings.
    if NBSPredict.parameter.verbose
        permMsg = 'Progress:';
        permProg = CmdProgress(permMsg, permIter);
    end
    for p = 1: permIter
        set_seed(permSeeds(p));
        permNBSPredict = NBSPredict;
        permNBSPredict.data.y = permNBSPredict.data.y(randperm(nSub), :);
        % Repeated CV for this permutation.
        repSeeds = generate_randomStream(randi(1e+9), repCViter);
        repScores = zeros(repCViter, NBSPredict.parameter.kFold, 'single');
        cPermEdgeWeight = zeros(repCViter, NBSPredict.parameter.kFold, nEdges, 'single');
        cPermSelectedEdges = false(repCViter, NBSPredict.parameter.kFold, nEdges);
        cPermStatWeightedEdges = zeros(repCViter, NBSPredict.parameter.kFold, nEdges, 'single');
        cPermTruePredLabels = cell(repCViter, NBSPredict.parameter.kFold, 2);
        for r = 1:repCViter
            set_seed(repSeeds(r));
            [repScores(r,:),cPermEdgeWeight(r,:,:), ...
                cPermTruePredLabels(r,:,:), ~, ~, ~, ...
                cPermSelectedEdges(r,:,:), ...
                cPermStatWeightedEdges(r,:,:)] = outerFold(permNBSPredict);
        end
        permCVscore(p+1) = mean(repScores(:));
        permTruePredLabels(p,:,:,:) = cPermTruePredLabels;
        cPermEdgeWeightFlat = reshape(ipermute(cPermEdgeWeight,[3 2 1]),nEdges,[]);
        permEdgeWeight(p,:) = mean(cPermEdgeWeightFlat,2);
        cPermSelectedEdgesFlat = reshape(ipermute(cPermSelectedEdges,[3 2 1]),nEdges,[]);
        permSelectedEdges(p,:) = mean(single(cPermSelectedEdgesFlat),2);
        cPermStatWeightedEdgesFlat = reshape(ipermute(cPermStatWeightedEdges,[3 2 1]),nEdges,[]);
        permStatWeightedEdges(p,:) = mean(cPermStatWeightedEdgesFlat,2);
        if NBSPredict.parameter.verbose
            permProg.increment;
        end
    end
    warning(prevWarningState); % Reactivate warnings.
end

if ismember(NBSPredict.parameter.metric, {'rmse','mse','mad'})
    pVal = sum(permCVscore <= permCVscore(1)) / (permIter + 1);
else
    pVal = sum(permCVscore >= permCVscore(1)) / (permIter + 1);
end
permScore = [permCVscore(1), pVal];
permTruePredLabels = cellfun(@single, permTruePredLabels, 'UniformOutput', false);

if NBSPredict.parameter.verbose
    fprintf(['Permutation testing has finished. ',...
        'Prediction performance: %.3f, p = %.3f\n'],...
        permScore(1), permScore(2));
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
    save_wrapper(fileDir, NBSPredict);
else
    if ~NBSPredict.parameter.ifTest
        warning(['Save parameter is disabled! So, NBSPredict file will not be saved!',...
            ' To save it, set ifSave to 1.']);
    end
    fileDir = 0;
end
end

function [] = save_wrapper(file, NBSPredict)
% save_wrapper saves NBSPredict in a file. It is a wrapper for save function.
% It tries to save data in v7.3 format if it is not possible to save in
% v7. If it is not possible to save in v7.3, it will give a warning.
try 
    save(file, 'NBSPredict');
catch
    try 
        save(file, '-v7.3', 'NBSPredict');
    catch
        warning('NBSPredict could not be saved!');
    end
end
end
