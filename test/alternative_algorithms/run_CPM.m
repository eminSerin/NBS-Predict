function [CPM] = run_CPM(data,varargin)
% run_CPM performs Connectom-based Predictive Modeling (CPM).
% Connectome-based predictive modeling is a predictive based method to
% analyze brain connectivity. 
% 
%   Arguements: 
%       data = A structure containing matrix for predictor and target
%           variables. Confound variables are added into correlation 
%           analysis (i.e., partial correlation) if provided.
%       thresh = p-value threshold to select features (default = 0.01). 
%       kFold = Number of CV folds (default = 10).
%       repCVIter = Number of CV repetition (default = 1).
%       ifParallel = Performs repeated nested CV parallel
%           (1 or 0, default = 0). 
%       metric = Performance metrics (correlation, mse; default = correlation).
%       learner = Estimator (LinReg,svmR or decisionTreeR, default = LinReg).
%       verbose = Whether or not give messages (default = 1);
%       randomState = Controls the randomness. Pass an integer value for
%           reproducible results or 'shuffle' to randomize (default = 42).  
%   
%   Output:
%       CPM: An outcome structure containing data, parameter and results.
%   
%   Example: 
%       run_CPM(data);
%       run_CPM(data,'thresh',0.05,'kFold',5,'ifParallel',1,'learner','svmR');
%
%   Reference:
%       Shen, X., Finn, E. S., Scheinost, D., Rosenberg, M. D., Chun, M.
%       M., Papademetris, X., & Constable, R. T. (2017). Using
%       connectome-based predictive modeling to predict individual behavior
%       from brain connectivity. nature protocols, 12(3), 506.
%   
%   Last edited by Emin Serin, 08.04.2021.
%

%% Input parser.
% Default parameters for CPM.
defaultVals.thresh = 0.01; defaultVals.ifParallel = 0;
defaultVals.metric = 'correlation'; defaultVals.learner = 'LinReg';
defaultVals.repCVIter = 1;  defaultVals.ifScale = 1; 
defaultVals.kFold = 10; defaultVals.verbose = 1; 
defaultVals.randomState = 42;
learnerOptions = {'LinReg','decisionTreeR','svmR'};

% Validation
validationLearner = @(x) any(validatestring(x,learnerOptions));
validationNumeric = @(x) isnumeric(x);

% Add NBSPredict parameters.
p = inputParser();
p.PartialMatching = 0; % deactivate partial matching.
addParameter(p,'thresh',defaultVals.thresh,validationNumeric);
addParameter(p,'kFold',defaultVals.kFold,validationNumeric);
addParameter(p,'ifParallel',defaultVals.ifParallel,validationNumeric);
addParameter(p,'metric',defaultVals.metric);
addParameter(p,'ifScale',defaultVals.ifScale,validationNumeric);
addParameter(p,'repCVIter',defaultVals.repCVIter,validationNumeric);
addParameter(p,'learner',defaultVals.learner,validationLearner);
addParameter(p,'verbose',defaultVals.verbose,validationNumeric);
addParameter(p,'randomState',defaultVals.randomState);


% Parse inputs.
parse(p,varargin{:});

% Organize user inputs.
CPM.data = data;
CPM.parameter.thresh = p.Results.thresh;
CPM.parameter.learner = p.Results.learner;
CPM.parameter.kFold = p.Results.kFold;
CPM.parameter.ifParallel = p.Results.ifParallel;
CPM.parameter.metric = p.Results.metric;
CPM.parameter.repCVIter = p.Results.repCVIter; 
CPM.parameter.ifScale = p.Results.ifScale;
CPM.parameter.randomState = p.Results.randomState;
verbose = p.Results.verbose; 

rng(p.Results.randomState);
%% Run CPM in a k-fold CV structure. 
if verbose
    fprintf('\nCPM is running!\n')
end
objFun = @(data) evaluateModel(data,CPM.parameter.thresh,CPM.parameter.learner,...
    CPM.parameter.metric,CPM.parameter.ifScale);

posCVscores = zeros(CPM.parameter.repCVIter,CPM.parameter.kFold);
negCVscores = posCVscores;
posSelectedEdges = zeros(CPM.parameter.repCVIter,size(data.X,2));
negSelectedEdges = posSelectedEdges; 
posMeanCVScores = zeros(CPM.parameter.repCVIter,1);
negMeanCVScores = posMeanCVScores; 
posStability = posMeanCVScores;
negStability = posStability;

tic;
if p.Results.ifParallel
    parfor r = 1:CPM.parameter.repCVIter
        CVresults = crossValidation(objFun,data,'kfold',CPM.parameter.kFold); % Run handler in CV.
        
        % Results
        CVresultsPOS = [CVresults.pos];
        CVresultsNEG = [CVresults.neg];
        
        posCVscores(r,:) = [CVresultsPOS.score];
        posMeanCVScores(r) = mean([CVresultsPOS.score]);
        posSelectedEdges(r,:) = mean([CVresultsPOS.selectedEdges],2)';
        posStability(r) = compute_stability(single([CVresultsPOS.selectedEdges]'));
        negCVscores(r,:) = [CVresultsNEG.score];
        negMeanCVScores(r) = mean([CVresultsNEG.score]);
        negSelectedEdges(r,:) =  mean([CVresultsNEG.selectedEdges],2)';
        negStability(r) = compute_stability(single([CVresultsNEG.selectedEdges]'));
    end
else
    for r = 1:CPM.parameter.repCVIter
        CVresults = crossValidation(objFun,data,'kfold',CPM.parameter.kFold); % Run handler in CV.
        
        % Results
        CVresultsPOS = [CVresults.pos];
        CVresultsNEG = [CVresults.neg];
        
        posCVscores(r,:) = [CVresultsPOS.score];
        posMeanCVScores(r) = mean([CVresultsPOS.score]);
        posSelectedEdges(r,:) = mean([CVresultsPOS.selectedEdges],2)';
        posStability(r) = compute_stability(single([CVresultsPOS.selectedEdges]'));
        negCVscores(r,:) = [CVresultsNEG.score];
        negMeanCVScores(r) = mean([CVresultsNEG.score]);
        negSelectedEdges(r,:) =  mean([CVresultsNEG.selectedEdges],2)';
        negStability(r) = compute_stability(single([CVresultsNEG.selectedEdges]'));
    end
end
CPM.results.elapsedTime = toc;
CPM.results.posCVscores = posCVscores;
CPM.results.posMeanCVScore = mean(posMeanCVScores);
CPM.results.posSelectedEdges = mean(posSelectedEdges,1);
CPM.results.posStability = mean(posStability);
CPM.results.negCVscores = negCVscores;
CPM.results.negMeanCVScore = mean(negMeanCVScores);
CPM.results.negSelectedEdges = mean(negSelectedEdges,1);
CPM.results.negStability = mean(negStability);

if verbose
        fprintf('\nPositive Network: %.3f\n',CPM.results.posMeanCVScore);
        fprintf('Negative Network: %.3f\n',CPM.results.negMeanCVScore);
        fprintf('Total time elapsed (in minutes): %.2f\n',...
            CPM.results.elapsedTime/60);
end

    function [modelEvalResults] = evaluateModel(data,thresh,learner,metric,ifScale)
        if ifScale
            % Scale
            scaler = MinMaxScaler;
            data.X_train = scaler.fit_transform(data.X_train);
            data.X_test = scaler.transform(data.X_test);
        end
        
        % Relate connectivity to behavior
        if isfield(data,'confound_train')
            deconf = ConfoundRegression; 
            data.X_train = deconf.fit_transform(data.X_train,data.confound_train);
            data.X_test = deconf.transform(data.X_test,data.confound_test);
        end
        
        [rMat,pMat] = corr(data.X_train,data.y_train);
        
        % Feature selection. Features with p-values that are lower than threshold
        % are selected.
        threshMask = pMat<thresh;
        posEdgesMask = rMat > 0 & threshMask;
        negEdgesMask = rMat < 0 & threshMask;
        modelEvalResults.pos.selectedEdges = posEdgesMask;
        modelEvalResults.neg.selectedEdges = negEdgesMask;
        
        % Calculate a single-subject summary values.
        sumPos_train = sum(data.X_train(:,posEdgesMask),2);
        sumNeg_train = sum(data.X_train(:,negEdgesMask),2);
        sumPos_test = sum(data.X_test(:,posEdgesMask),2);
        sumNeg_test = sum(data.X_test(:,negEdgesMask),2);
        
        modelEvalData_positive.y_train = data.y_train;
        modelEvalData_positive.y_test = data.y_test;
        modelEvalData_negative = modelEvalData_positive;
        modelEvalData_positive.X_train = sumPos_train;
        modelEvalData_negative.X_train = sumNeg_train;
        modelEvalData_positive.X_test = sumPos_test;
        modelEvalData_negative.X_test = sumNeg_test;
        
        Mdl = feval(['run_',learner]);
        [modelEvalResults.pos.score] =...
            modelFitScore(Mdl,modelEvalData_positive,metric);
        [modelEvalResults.neg.score] =...
            modelFitScore(Mdl,modelEvalData_negative,metric);
    end
    
end
