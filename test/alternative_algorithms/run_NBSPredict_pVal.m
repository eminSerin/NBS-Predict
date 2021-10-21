function [NBSPredict] = run_NBSPredict_pVal(NBSPredict)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_NBSPredict_pVal runs p-value thresholding algorithm to perform
% prediction using connectome data and evaluate the contribution of the
% relevant edges to the overal performance of the model. The algorithm is
% highly similar to NBS-Predict's algorithm with a few discrepencies:
%   - Features (edges) are selected by selecting features below a  
%       predefined p-value threshold.
%   - Connected components are NOT utilized in feature selection.
%
% Arguments:
%   NBSPredict - Structure including data and parameters. NBSPredict
%       structure is prepared by NBSPredict GUI. However it could also be
%       provided by user to bypass the GUI (see MANUAL for details).
%
% Output:
%   NBSPredict - Structure provided by the user or GUI with results saved in.
%
% Last edited by Emin Serin, 08.04.2021.
%
% See also: test_NBSPredict, sim_testNBSPredict
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
NBSPredict = get_NBSPredictInput(NBSPredict);
totalRepCViter = NBSPredict.parameter.repCViter;

% Random Seed
randSeed = NBSPredict.parameter.randSeed;
if randSeed ~= -1 % -1 refers to random shuffle.
    if NBSPredict.parameter.ifParallel
        rndSeeds = linspace(randSeed,randSeed+totalRepCViter-1,totalRepCViter);
    else
        rng(randSeed);
    end
else
    rng('shuffle');
end

% Init parallel pool if desired.
if NBSPredict.parameter.ifParallel && isempty(gcp('nocreate'))
    parpool('local');
end

% Write an start tag.
NBSPredict.info.startDate = date;
startTime = tic;

nEdges = numel(NBSPredict.data.edgeIdx);
nModels = numel(NBSPredict.parameter.MLmodels);
nSub = size(NBSPredict.data.y,1);

% Preallocation
repCVscore = zeros(totalRepCViter,1,'single');
meanRepCVscore = zeros(nModels,1);
meanRepCVscoreCI = zeros(nModels,2);
edgeWeight = zeros(totalRepCViter,NBSPredict.parameter.kFold,...
    nEdges,'single');
activationPattern = edgeWeight;
stability = zeros(totalRepCViter,1,'single');
truePredLabels = zeros(totalRepCViter,nSub,2,'single');

fileDir = save_NBSPredict(NBSPredict);
cNBSPredict = NBSPredict; % current NBSPredict.
for cModelIdx = 1: nModels
    modelTime = tic;
    % Run repeated nested CV using ML models provided.
    cModel = NBSPredict.parameter.MLmodels{cModelIdx};
    ifLinear = NBSPredict.parameter.ifLinear(cModelIdx);
    if isfield(NBSPredict.parameter,'paramGrids')
        cNBSPredict.parameter.paramGrids = NBSPredict.parameter.paramGrids(cModelIdx);
    end
    cNBSPredict.parameter.model = cModel; % TODO: remove after oop progress fun.
    cNBSPredict.parameter.ifLinear = ifLinear;
    MLhandle = gen_MLhandles(cNBSPredict.parameter.model);
    cNBSPredict.MLhandle = MLhandle;
    show_NBSPredictProgress(cNBSPredict,0);
    if cNBSPredict.parameter.ifParallel
        % Run parallelly.
        parfor repCViter = 1: totalRepCViter
            rng(rndSeeds(repCViter));
            if ifLinear
                [outerCVscore,edgeWeight(repCViter,:,:),...
                    truePredLabels(repCViter,:,:),stability(repCViter),...
                    activationPattern(repCViter,:,:)] = outerFold(cNBSPredict);
            else
                [outerCVscore,edgeWeight(repCViter,:,:),...
                    truePredLabels(repCViter,:,:),stability(repCViter)] = outerFold(cNBSPredict);
            end
            repCVscore(repCViter) = outerCVscore;
            show_NBSPredictProgress(cNBSPredict,repCViter,outerCVscore);
        end
    else
        % Run sequentially.
        for repCViter = 1: totalRepCViter
            if ifLinear
                [outerCVscore,edgeWeight(repCViter,:,:),...
                    truePredLabels(repCViter,:,:),stability(repCViter),...
                    activationPattern(repCViter,:,:)] = outerFold(cNBSPredict);
            else
                [outerCVscore,edgeWeight(repCViter,:,:),...
                    truePredLabels(repCViter,:,:),stability(repCViter)] = outerFold(cNBSPredict);
            end
            repCVscore(repCViter) = outerCVscore;
            show_NBSPredictProgress(cNBSPredict,repCViter,repCVscore);
        end
    end
    
    % Repeated CV scores.
    meanRCVscore =  mean(repCVscore);
    meanRepCVscore(cModelIdx) = meanRCVscore;
    seRCVscore = std(repCVscore)/sqrt(totalRepCViter);
    alphaSE = seRCVscore*1.96; % 95% confidence interval.
    lowerBoundRCVscore = meanRCVscore - alphaSE; % lower CI
    upperBoundRCVscore = meanRCVscore + alphaSE; % upper CI
    meanRepCVscoreCI(cModelIdx,:) = [lowerBoundRCVscore,upperBoundRCVscore];
    
    % True and predicted labels
    truePredLabelsR = reshape(ipermute(truePredLabels,[2 1 3]),[],2);
    NBSPredict.results.(cModel).truePredLabels = truePredLabelsR;
    
    % Stability
    NBSPredict.results.(cModel).stability = stability;
    NBSPredict.results.(cModel).meanStability = mean(stability);
    
    % EdgeWeights
    totalFold = NBSPredict.parameter.repCViter*NBSPredict.parameter.kFold;
    [NBSPredict.results.(cModel).edgeWeight,NBSPredict.results.(cModel).meanEdgeWeight,...
        NBSPredict.results.(cModel).wAdjMat,NBSPredict.results.(cModel).scaledMeanEdgeWeight,...
        NBSPredict.results.(cModel).scaledWAdjMat] =...
        compute_meanWeights(edgeWeight,NBSPredict.data.nodes,nEdges,NBSPredict.data.edgeIdx,totalFold);
    
    if ifLinear
        % ActivationPatterns
        [NBSPredict.results.(cModel).actPattern,NBSPredict.results.(cModel).mActPattern,...
            NBSPredict.results.(cModel).actAdjMat,NBSPredict.results.(cModel).scaledMeanActPattern,...
            NBSPredict.results.(cModel).scaledActAdjMat] =...
            compute_meanWeights(edgeWeight,NBSPredict.data.nodes,nEdges,NBSPredict.data.edgeIdx,totalFold);
    end
    
    % Save values to NBSPredict.
    NBSPredict.results.(cModel).repCVscore = repCVscore;
    NBSPredict.results.(cModel).meanCVscoreCI = [lowerBoundRCVscore,upperBoundRCVscore];
    NBSPredict.results.(cModel).meanRepCVscore = meanRepCVscore(cModelIdx);
    show_NBSPredictProgress(cNBSPredict,-1,repCVscore);
    
    if NBSPredict.parameter.verbose
        toc(modelTime);
    end
    
    if fileDir
        save(fileDir,'NBSPredict');
    end
end

if ~ismember(NBSPredict.parameter.metric,{'mad','rmse','explained_variance'})
    [~,bestEstimatorIdx] = max(meanRepCVscore); % find max score.
else
    [~,bestEstimatorIdx] = min(meanRepCVscore); % find min error.
end

if NBSPredict.parameter.ifModelOpt
    NBSPredict.results.bestEstimator = NBSPredict.parameter.MLmodels{bestEstimatorIdx};
    if NBSPredict.parameter.verbose
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

NBSPredict.info.endDate = date;
timeElapsed = toc(startTime); % in minutes;
NBSPredict.info.timeElapsed = timeElapsed;
if NBSPredict.parameter.verbose
    fprintf('Total time elapsed (in minutes): %.2f\n',timeElapsed/60);
end
if fileDir
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
        %Prepare data for middle fold.
        middleFoldData.X = data.X_train;
        middleFoldData.y = data.y_train;
        if isfield(data,'confounds_train')
            middleFoldData.confounds = data.confounds_train;
        end
        
        % Preprocess data.
        data = preprocess_data(data,NBSPredict.parameter.scalingMethod);
        
        if NBSPredict.parameter.ifHyperOpt
            middleFoldBestParams = middleFoldHyperOpt(middleFoldData,NBSPredict);
        end
        
        filterData.X = data.X_train;
        filterData.y = data.y_train;
        extIdx = run_pVal(filterData,NBSPredict);
        
        % Transform data for model evaluation using parameters found in middle fold.
        modelEvalData.X = data.X_train;
        modelEvalData.y = data.y_train;
        
        selectedEdges = false(size(modelEvalData.X,2),1);
        selectedEdges(extIdx) = true;
        X_train_transformed = modelEvalData.X(:,extIdx);
        
        % Reconstruct data structure.
        data.X_train = X_train_transformed;
        data.X_test  = data.X_test(:,selectedEdges);
        data.y_test = data.y_test(:,2);
        data.y_train = data.y_train(:,2);
        if ~NBSPredict.parameter.ifHyperOpt
            params = [];
        else
            params = middleFoldBestParams;
        end
        
        [modelEvalResults.score,modelEvalResults.truePredLabels,...
            estimator] = fit_hyperParam(data,params,NBSPredict.MLhandle,...
            NBSPredict.parameter.metric);
        if NBSPredict.parameter.ifLinear
            modelEvalResults.activationPattern = single(selectedEdges);
            modelEvalResults.activationPattern(extIdx) =...
                abs(transform_toActivationPattern(data.X_train,estimator.Beta));
        end
        modelEvalResults.outerFoldEdgeWeight = single(selectedEdges);
    end
if NBSPredict.parameter.ifLinear
    varargout = cell(1,5);
    varargout{5} = [outerFoldCVresults.activationPattern]';
else
    varargout = cell(1,4);
end

varargout{1} = mean([outerFoldCVresults.score]);
varargout{2} = [outerFoldCVresults.outerFoldEdgeWeight]';
varargout{3} = cell2mat(reshape([outerFoldCVresults.truePredLabels],2,[])');
varargout{4} = compute_stability(single([outerFoldCVresults.outerFoldEdgeWeight]' > 0));
end

function [bestParam] = middleFoldHyperOpt(data,NBSPredict)
% middleFold is the second (or middle) layer of the 2-layer nested
% cross-validation structure. middleFold performs feature selection using a
% searching algorithm selected. If requested, a function for hyperparameter
% optimization (i.e., inner layer) is called in this function.
featureSelFun = @(data,param) optimize_hyperOpt(data,NBSPredict,param);
[bestParam] = NBSPredict.featSelHandle(featureSelFun,data,...
    NBSPredict.parameter.paramGrids);

    function [hyperOptResults] = optimize_hyperOpt(data,NBSPredict,params)
        % Preprocess data.
        data = preprocess_data(data,NBSPredict.parameter.scalingMethod);
        
        % Select features.
        filterData.X = data.X_train;
        filterData.y = data.y_train;
        extIdx = run_pVal(filterData,NBSPredict);
        
        % Construct labels.
        data.y_test = data.y_test(:,2);
        data.y_train = data.y_train(:,2);
        
        % Transform data with selected features.
        data.X_train = data.X_train(:,extIdx);
        data.X_test = data.X_test(:,extIdx);
        
        % Fit model and get score.
        if ~NBSPredict.parameter.ifHyperOpt
            params = [];
        end
        hyperOptResults.score = fit_hyperParam(data,params,NBSPredict.MLhandle,...
            NBSPredict.parameter.metric);
    end
end

function [extIdx] = run_pVal(data,NBSPredict)
% run_pVal is a univariate feature selection method that selects suprathreshold 
% features based on univariate statistical methods (t-test or F-test).
[~, pVal] = run_nbsPredictGlm(data.y,data.X,NBSPredict.parameter.contrast,...
    NBSPredict.parameter.test);
extIdx = find(pVal < NBSPredict.parameter.pVal);
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
    = compute_meanWeights(edgeWeight,nNodes,nEdges,edgeIdx,totalFold)
% compute_meanWeights computes vector and adjacency matrix of mean edge
% weights. It also returns scaled version of those outputs using
% MinMaxScaler. 

% Edge Weights
reshapedEdgeWeight = reshape(ipermute(edgeWeight,[3 2 1]),nEdges,[]);

% Mean edge weight.
meanEdgeWeight = mean(reshapedEdgeWeight,2);
wAdjMat = gen_weightedAdjMat(nNodes,edgeIdx,meanEdgeWeight); % weighted Adj matrix.

% Scaled mean edge weight
scaler = MinMaxScaler([0,max(meanEdgeWeight)]);
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
    referencePath = NBSPredict.data.path;
    saveDir = fileparts(referencePath); % parent director
    if isfield(NBSPredict.parameter,'ifTest')
        saveDir = [saveDir,filesep,'test',filesep,'Results',filesep,date,filesep];
    else
        saveDir = [saveDir,filesep,'Results',filesep,date,filesep];
    end
    fileDir = [saveDir, 'NBSPredict_pVal.mat'];
    if ~isfolder(saveDir)
        mkdirStatus = mkdir(saveDir);
        assert(mkdirStatus,'Folder could not be created! Please check folder permissions!');
    else
        fileNum = 1;
        while isfile(fileDir)
            fileDir = [saveDir,['NBSPredict',num2str(fileNum),'.mat']];
            fileNum = fileNum + 1;
        end
    end
    save(fileDir,'NBSPredict');
else
    if ~isfield(NBSPredict.parameter,'ifTest')
        warning(['Save parameter is disabled! So, NBSPredict file will not be saved!',...
            ' To save it, set ifSave to 1.']);
    end
    fileDir = 0;
end
end