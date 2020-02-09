function [NBSPredict] = run_NBSPredict(NBSPredict)
% run_NBSPredict is a function which consists main nested cross-validation
% structure. It performs cross-validated prediction on given data.
%
% Arguements:
%   NBSPredict - Structure including data and parameters. NBSPredict
%       structure is prepared by NBSPredict GUI. However it could also be
%       provided by user to bypass the GUI (see MANUAL for details).
%
% Output:
%   NBSPredict - Structure provided by the user or GUI with results saved in.
%
% Last edited by Emin Serin, 03.09.2019.
%
% See also: start_NBSPredictGUI, get_NBSPredictInput

NBSPredict = get_NBSPredictInput(NBSPredict);

if NBSPredict.parameter.ifParallel && isempty(gcp('nocreate'))
    % Init parallel pool.
    parpool('local');
end

% Write an start tag.
NBSPredict.info.startDate = date;
startTime = tic;

nEdges = numel(NBSPredict.data.edgeIdx);
nModels = numel(NBSPredict.parameter.MLmodels);
nSub = size(NBSPredict.data.y,1);
totalRepCViter = NBSPredict.parameter.repCViter;

% Preallocation
repCVscore = zeros(totalRepCViter,1,'single');
meanRepCVscore = zeros(nModels,1);
meanRepCVscoreCI = zeros(nModels,2);
edgeWeight = zeros(totalRepCViter,NBSPredict.parameter.kFold,...
    nEdges,'single');
truePredLabels = zeros(totalRepCViter,nSub,2,'single');

fileDir = save_NBSPredict(NBSPredict);
cNBSPredict = NBSPredict; % current NBSPredict.
for cModelIdx = 1: nModels
    % Run repeated nested CV using ML models provided.
    cModel = NBSPredict.parameter.MLmodels{cModelIdx};
    cNBSPredict.parameter.paramGrid = NBSPredict.parameter.paramGrids(cModelIdx);
    cNBSPredict.parameter.model = cModel; % TODO: remove after oop progress fun.
    MLhandle = gen_MLhandles(cNBSPredict.parameter.model);
    cNBSPredict.MLhandle = MLhandle;
    show_NBSPredictProgress(cNBSPredict,0);
    if cNBSPredict.parameter.ifParallel
        % Run parallelly.
        parfor repCViter = 1: totalRepCViter
            [outerCVscore,edgeWeight(repCViter,:,:),truePredLabels(repCViter,:,:)] = outerFold(cNBSPredict);
            repCVscore(repCViter) = outerCVscore;
            show_NBSPredictProgress(cNBSPredict,repCViter,outerCVscore);
        end
    else
        % Run sequentially.
        for repCViter = 1: totalRepCViter
            [outerCVscore,edgeWeight(repCViter,:,:),truePredLabels(repCViter,:,:)] = outerFold(cNBSPredict);
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
    
    % Edge Weights
    reshapedEdgeWeight = reshape(ipermute(edgeWeight,[3 2 1]),nEdges,[]);
    meanEdgeWeight = mean(reshapedEdgeWeight,2);
    NBSPredict.results.(cModel).edgeWeight = reshapedEdgeWeight;
    
    % Mean edge weight.
    NBSPredict.results.(cModel).meanEdgeWeight = meanEdgeWeight; % mean
    [NBSPredict.results.(cModel).wAdjMat] = gen_weightedAdjMat(NBSPredict.data.nodes,...
        NBSPredict.data.edgeIdx,NBSPredict.results.(cModel).meanEdgeWeight); % weighted Adj matrix.
    
    % Scaled mean edge weight
    NBSPredict.results.(cModel).scaledMeanEdgeWeight = rescale(meanEdgeWeight); % Min-max scaled mean weights
    NBSPredict.results.(cModel).scaledWAdjMat = gen_weightedAdjMat(NBSPredict.data.nodes,...
        NBSPredict.data.edgeIdx,NBSPredict.results.(cModel).scaledMeanEdgeWeight); % weighted Adj matrix.
    
    % Save values to NBSPredict.
    NBSPredict.results.(cModel).repCVscore = repCVscore;
    NBSPredict.results.(cModel).meanCVscoreCI = [lowerBoundRCVscore,upperBoundRCVscore];
    NBSPredict.results.(cModel).meanRepCVscore = meanRepCVscore(cModelIdx);
    show_NBSPredictProgress(cNBSPredict,-1,repCVscore);
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
    % Print summary results if more than one estimators are used.
    fprintf('\n\n\n\t\t\t<strong>OVERALL RESULTS:</strong>\n\n');
    for cModelIdx = 1:nModels
        fprintf(['ML Estimator: %s,\n\tMean Repeated Nested CV Score: %.2f,\n\t',...
            'Confidence Interval: [%.2f,%.2f]\n'],...
            NBSPredict.parameter.MLmodels{cModelIdx},meanRepCVscore(cModelIdx),...
            meanRepCVscoreCI(cModelIdx,:))
    end
    fprintf('Estimator with minimum error is <strong>%s</strong> \n',NBSPredict.results.bestEstimator);
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

function [meanCVscore,edgeWeights,truePredLabels] = outerFold(NBSPredict)
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
        middleFoldBestParams = middleFold(middleFoldData,NBSPredict); % run middleFold.
        
        % Preprocess data.
        data = preprocess_data(data,NBSPredict.parameter.scalingMethod);
        
        % Transform data for model evaluation using parameters found in middle fold.
        modelEvalData.X = data.X_train;
        modelEvalData.y = data.y_train;
        [X_train_transformed,transformMask] = fsTransform(modelEvalData,NBSPredict,middleFoldBestParams.kBest);
        
        % Reconstruct data structure.
        data.X_train = X_train_transformed;
        data.X_test  = data.X_test(:,transformMask);
        data.y_test = data.y_test(:,2);
        data.y_train = data.y_train(:,2);
        
        params = middleFoldBestParams;
        if ~NBSPredict.parameter.ifHyperOpt
            params = [];
        end
        [modelEvalResults.score,modelEvalResults.truePredLabels] = fit_hyperParam(data,...
            params,NBSPredict.MLhandle,NBSPredict.parameter.metric);
        weightScore = modelEvalResults.score;
        if ismember(NBSPredict.parameter.metric,{'rmse','mad'})
            weightScore = compute_modelMetrics(modelEvalResults.truePredLabels{1},...
                modelEvalResults.truePredLabels{1},'r_squared');
        end
        % Multiply features selected with test score of model to compute
        % weight for each feature.
        modelEvalResults.outerFoldEdgeWeight = transformMask .* weightScore;
    end
meanCVscore = mean([outerFoldCVresults.score]);
edgeWeights = [outerFoldCVresults.outerFoldEdgeWeight]';
truePredLabels = cell2mat(reshape([outerFoldCVresults.truePredLabels],2,[])');
end

function [bestParam] = middleFold(data,NBSPredict)
% middleFold is the second (or middle) layer of the 2-layer nested
% cross-validation structure. middleFold performs feature selection using a
% searching algorithm selected. If requested, a function for hyperparameter
% optimization (i.e., inner layer) is called in this function.
featureSelFun = @(data,param) run_featureSel(data,NBSPredict,param);
[bestParam] = NBSPredict.featSelHandle(featureSelFun,data,...
    NBSPredict.parameter.paramGrid);

    function [score] = run_featureSel(data,NBSPredict,params)
        % Preprocess data.
        data = preprocess_data(data,NBSPredict.parameter.scalingMethod);
        
        % Run GLM and get test statistics
        testStats = run_nbsPredictGlm(data.y_train,data.X_train,NBSPredict.parameter.contrast,...
            NBSPredict.parameter.test);
        [~,I] = sort(testStats,'descend'); % Rank features based on their test statistics.
        
        % Construct labels.
        data.y_test = data.y_test(:,2);
        data.y_train = data.y_train(:,2);
        
        % Select n features.
        cEdgesIdx = I(1:getfieldi(params,'kBest'));
        % Extract features found in the biggest graph component.
        [extIdx] = extractComponentIdx(NBSPredict.data.nodes,...
            NBSPredict.data.edgeIdx,cEdgesIdx);
        
        % Transform data with selected features.
        data.X_train = data.X_train(:,extIdx);
        data.X_test = data.X_test(:,extIdx);
        
        % Fit model and get score.
        if ~NBSPredict.parameter.ifHyperOpt
            params = [];
        end
        score = fit_hyperParam(data,params,NBSPredict.MLhandle,...
            NBSPredict.parameter.metric);
    end

end

%% Helper functions
function data = preprocess_data(data,scalingMethod)
% preprocess_data performs preprocessing on data provided.
% Preprocessing consists of rescaling and, if provided, removing
% confounds from data.
% Preprocess data
if ~isempty(scalingMethod)
    % Rescale data.
    scaler = feval(scalingMethod);
    data.X_train = scaler.fit_transform(data.X_train);
    data.X_test = scaler.transform(data.X_test);
end
if isfield(data,'confounds_train')
    % Remove variance associated with confounds from data.
    confcorr = ConfoundRegression;
    data.X_train = confcorr.fit_transform(data.X_train,data.confounds_train);
    data.X_test = confcorr.transform(data.X_test,data.confounds_test);
end
end

function varargout = fit_hyperParam(data,hyperparam,MLhandle,metrics)
% fit_hyperParam fits ML algorithm on provided data with hyperparameters
% provided.
Mdl = MLhandle(hyperparam);
if ischar(metrics)
    metrics = {metrics};
end
nMetrics = numel(metrics);
varargout = cell(1,nMetrics+1);

[varargout{:}] = modelFitScore(Mdl,data,metrics);
end

function [fileDir] = save_NBSPredict(NBSPredict)
% save_NBSPredict saves NBSPredict structure in a results folder in the main
% directory of the toolbox. It will save in a file which is named with the
% current date of analysis. If there is another NBSPredict exists in the
% same folder (i.e., multiple analysis in a day), the current file is named
% with suffix.
if NBSPredict.parameter.ifSave
    referenceFile = 'start_NBSPredict.m';
    saveDir = fileparts(which(referenceFile));
    if isfield(NBSPredict.parameter,'ifTest')
        saveDir = [saveDir,filesep,'test',filesep,'Results',filesep,date,filesep];
    else
        saveDir = [saveDir,filesep,'Results',filesep,date,filesep];
    end
    fileDir = [saveDir, 'NBSPredict.mat'];
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