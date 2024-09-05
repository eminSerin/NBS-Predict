function [CPM] = run_CPM(data,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_CPM performs Connectom-based Predictive Modeling (CPM).
% Connectome-based predictive modeling is a predictive based method to
% analyze brain connectivity. 
% 
% Arguments: 
%     data = A structure containing matrix for predictor and target
%         variables. Confound variables are added into correlation 
%         analysis (i.e., partial correlation) if provided.
%     thresh = p-value threshold to select features (default = 0.01). 
%     kFold = Number of CV folds (default = 10).
%     repCViter = Number of CV repetition (default = 1).
%     numCores = Number of CPU cores (default = 1).
%     metric = Performance metrics (correlation, mse; default = correlation).
%     learner = Estimator (LinReg,svmR or decisionTreeR, default = LinReg).
%     verbose = Whether or not give messages (default = 1).
%     randSeed = Controls the randomness. Pass an integer value for
%         reproducible results or 'shuffle' to randomize (default = 42).
%     ifPerm = Whether to run permutation testing (default = 0).
%     permIter = Number of permutations (default = 100). 
%   
% Output:
%     CPM: An outcome structure containing data, parameter and results.
%   
% Example: 
%     run_CPM(data);
%     run_CPM(data,'thresh',0.05,'kFold',5,'numCores',3,'learner','svmR');
%
% Reference:
%     Shen, X., Finn, E. S., Scheinost, D., Rosenberg, M. D., Chun, M.
%     M., Papademetris, X., & Constable, R. T. (2017). Using
%     connectome-based predictive modeling to predict individual behavior
%     from brain connectivity. nature protocols, 12(3), 506.
%   
% Last edited by Emin Serin, 27.08.2022.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input parser.
% Default parameters for CPM.
defaultVals.thresh = 0.01; defaultVals.numCores = 1;
defaultVals.metric = 'correlation'; defaultVals.learner = 'LinReg';
defaultVals.repCViter = 1;  defaultVals.ifScale = 1; 
defaultVals.kFold = 10; defaultVals.verbose = 1; 
defaultVals.randSeed = 42; defaultVals.ifPerm = 0;
defaultVals.permIter = 100; 
learnerOptions = {'LinReg','decisionTreeR','svmR'};

% Validation
validationLearner = @(x) any(validatestring(x,learnerOptions));
validationNumeric = @(x) isnumeric(x);

% Add NBSPredict parameters.
p = inputParser();
p.PartialMatching = 0; % deactivate partial matching.
addParameter(p,'thresh',defaultVals.thresh,validationNumeric);
addParameter(p,'kFold',defaultVals.kFold,validationNumeric);
addParameter(p,'numCores',defaultVals.numCores,validationNumeric);
addParameter(p,'metric',defaultVals.metric);
addParameter(p,'ifScale',defaultVals.ifScale,validationNumeric);
addParameter(p,'repCViter',defaultVals.repCViter,validationNumeric);
addParameter(p,'learner',defaultVals.learner,validationLearner);
addParameter(p,'verbose',defaultVals.verbose,validationNumeric);
addParameter(p,'ifPerm',defaultVals.ifPerm,validationNumeric);
addParameter(p,'randSeed',defaultVals.randSeed,validationNumeric);
addParameter(p,'permIter',defaultVals.permIter,validationNumeric);

% Parse inputs.
parse(p,varargin{:});

% Organize user inputs.
CPM.data = data;
CPM.parameter.thresh = p.Results.thresh;
CPM.parameter.learner = p.Results.learner;
CPM.parameter.kFold = p.Results.kFold;
CPM.parameter.numCores = p.Results.numCores;
CPM.parameter.metric = p.Results.metric;
CPM.parameter.repCViter = p.Results.repCViter; 
CPM.parameter.ifScale = p.Results.ifScale;
CPM.parameter.randSeed = p.Results.randSeed;
CPM.parameter.ifPerm = p.Results.ifPerm; 
CPM.parameter.permIter = p.Results.permIter; 
CPM.parameter.verbose = p.Results.verbose; 

set_seed(p.Results.randSeed);

% Initiate parallel pool if desired.
create_parallelPool(CPM.parameter.numCores);

%% Run CPM in a k-fold CV structure. 
if CPM.parameter.verbose
    fprintf(['\nCPM is running!\n', ...
        '%d-repeated %d-fold CV\n'],...
        CPM.parameter.kFold, CPM.parameter.repCViter);
end
CPM.objFun = @(data) evaluateModel(data,CPM.parameter.thresh,CPM.parameter.learner,...
    CPM.parameter.metric,CPM.parameter.ifScale);

% Preallocate output variables.
posCVscores = zeros(CPM.parameter.repCViter,CPM.parameter.kFold);
negCVscores = posCVscores;
combCVscores = posCVscores; 
posSelectedEdges = zeros(CPM.parameter.repCViter,size(data.X,2));
negSelectedEdges = posSelectedEdges; 
posMeanCVScores = zeros(CPM.parameter.repCViter,1);
negMeanCVScores = posMeanCVScores;
combMeanCVScores = posMeanCVScores;
posStability = posMeanCVScores;
negStability = posStability;
posTruePredLabels = cell(CPM.parameter.repCViter, CPM.parameter.kFold,2);
negTruePredLabels = posTruePredLabels;
combTruePredLabels = posTruePredLabels; 

tic;
CVresults = cell(CPM.parameter.repCViter, 1);
if p.Results.numCores > 1
    parfor r = 1:CPM.parameter.repCViter
        CVresults(r) = {crossValidation(CPM.objFun,data,'kfold',CPM.parameter.kFold)}; % Run handler in CV.
    end
else
    for r = 1:CPM.parameter.repCViter
        CVresults(r) = {crossValidation(CPM.objFun,data,'kfold',CPM.parameter.kFold)}; % Run handler in CV.
    end
end

for r = 1:CPM.parameter.repCViter
    % Results
    CVresultsPOS = [CVresults{r}.pos];
    CVresultsNEG = [CVresults{r}.neg];
    CVresultsComb = [CVresults{r}.comb];
    
    % Positive
    posCVscores(r,:) = [CVresultsPOS.score];
    posMeanCVScores(r) = mean([CVresultsPOS.score]);
    posSelectedEdges(r,:) = mean([CVresultsPOS.selectedEdges],2)';
    posStability(r) = compute_stability(single([CVresultsPOS.selectedEdges]'));
    posTruePredLabels(r,:,:) = reshape([CVresultsPOS.truePredLabels],2,[])';
    
    % Negative
    negCVscores(r,:) = [CVresultsNEG.score];
    negMeanCVScores(r) = mean([CVresultsNEG.score]);
    negSelectedEdges(r,:) =  mean([CVresultsNEG.selectedEdges],2)';
    negStability(r) = compute_stability(single([CVresultsNEG.selectedEdges]'));
    negTruePredLabels(r,:,:) = reshape([CVresultsNEG.truePredLabels],2,[])';
    
    % Combined
    combCVscores(r,:) = [CVresultsComb.score];
    combMeanCVScores(r) = mean([CVresultsComb.score]);
    combTruePredLabels(r,:,:) = reshape([CVresultsComb.truePredLabels],2,[])';
end

CPM.results.elapsedTime = toc;

% Save results into the CPM structure. 
% Positive
CPM.results.posCVscores = posCVscores;
CPM.results.posMeanCVScore = mean(posMeanCVScores);
CPM.results.posWeights = mean(posSelectedEdges,1);
CPM.results.posStability = mean(posStability);
CPM.results.posTruePredLabels = posTruePredLabels; 

% Negative
CPM.results.negCVscores = negCVscores;
CPM.results.negMeanCVScore = mean(negMeanCVScores);
CPM.results.negWeights = mean(negSelectedEdges,1);
CPM.results.negStability = mean(negStability);
CPM.results.negTruePredLabels = negTruePredLabels; 

% Combined
CPM.results.combCVscores = combCVscores;
CPM.results.combMeanCVScore = mean(combMeanCVScores);
CPM.results.combTruePredLabels = combTruePredLabels; 

if CPM.parameter.verbose
        fprintf('\nPositive Network: %.3f\n',CPM.results.posMeanCVScore);
        fprintf('Negative Network: %.3f\n',CPM.results.negMeanCVScore);
        fprintf('Combined Network: %.3f\n',CPM.results.combMeanCVScore);
        fprintf('Total time elapsed (in minutes): %.2f\n\n',...
            CPM.results.elapsedTime/60);
end

% Run Permutation test.
if CPM.parameter.ifPerm
    CPM.results.permScore = run_permTesting(CPM);
end

    function [modelEvalResults] = evaluateModel(data,thresh,learner,metric,ifScale)
        if ifScale
            % Scale
            scaler = MinMaxScaler;
            data.X_train = scaler.fit_transform(data.X_train);
            data.X_test = scaler.transform(data.X_test);
        end
        
        % Relate connectivity to behavior
        if isfield(data,'confounds_train')
            deconf = ConfoundRegression; 
            data.X_train = deconf.fit_transform(data.X_train,data.confounds_train);
            data.X_test = deconf.transform(data.X_test,data.confounds_test);
        end
        
        % Organize CV data. 
        modelEvalData_positive.y_train = data.y_train;
        modelEvalData_positive.y_test = data.y_test;
        modelEvalData_negative = modelEvalData_positive;
        modelEvalData_comb = modelEvalData_positive; 
        
        % Select features.
        [modelEvalResults] = feature_selection(data, thresh);
        
        % Calculate a single-subject summary values.
        modelEvalData_positive.X_train = ...
            sum(data.X_train(:, modelEvalResults.pos.selectedEdges),2);
        modelEvalData_negative.X_train = ...
            sum(data.X_train(:, modelEvalResults.neg.selectedEdges),2);
        modelEvalData_comb.X_train = [modelEvalData_negative.X_train,...
            modelEvalData_positive.X_train];
        modelEvalData_positive.X_test = ...
            sum(data.X_test(:, modelEvalResults.pos.selectedEdges),2);
        modelEvalData_negative.X_test = ...
            sum(data.X_test(:, modelEvalResults.neg.selectedEdges),2);
        modelEvalData_comb.X_test = [modelEvalData_negative.X_test,...
            modelEvalData_positive.X_test];
        
        % Fit ML models.
        Mdl = feval(['run_',learner]);
        
        [modelEvalResults.pos.score,...
            modelEvalResults.pos.truePredLabels] = ... % Positive
            modelFitScore(Mdl,modelEvalData_positive,metric);
        
        [modelEvalResults.neg.score,...
            modelEvalResults.neg.truePredLabels] =... % Negative
            modelFitScore(Mdl,modelEvalData_negative,metric);
        
        [modelEvalResults.comb.score,...
            modelEvalResults.comb.truePredLabels] =... % Combined
            modelFitScore(Mdl,modelEvalData_comb,metric);
        
        function [selEdges] = feature_selection(data, thresh)
            % Selects features based on Pearson Correlation Coeffieicnt 
            % between features and target.
            
            % Pearson's CC
            [rMat,pMat] = corr(data.X_train,data.y_train);
            
            % Feature selection. Features with p-values that are lower than threshold
            % are selected.
            threshMask = pMat<thresh;
            selEdges.pos.selectedEdges = rMat > 0 & threshMask;
            selEdges.neg.selectedEdges = rMat < 0 & threshMask;
        end
    end
    
end


function permScore = run_permTesting(CPM)
% Run Permutation test.
% It randomly permutes target variable and run the same pipeline. 
% It returns permutation score and p-value
% p-value represents the fraction of models yielding similar to or better
% prediction performance than the tested model.
if CPM.parameter.ifPerm
    permIter = CPM.parameter.permIter;
    fprintf('Permutation testing is running! Permutations: %d\n',...
        permIter);
    
    % Random Seed
    set_randomSeed(CPM.parameter.randSeed)
    rndSeeds = generate_randomStream(randi(1e+9), permIter);
    
    nSub = size(CPM.data.y,1);
    
    % Preallocate permutation testing scores.
    posPermCVscore = zeros(permIter+1, 1, 'single');
    negPermCVscore = posPermCVscore;
    combPermCVscore = posPermCVscore;
    
    tic;
    % Run ground analysis.
    set_randomSeed(CPM.parameter.randSeed)
    [posPermCVscore(1), negPermCVscore(1), combPermCVscore(1)] = crossVal_wrapper(CPM);
    
    % Permutation testing. 
    if CPM.parameter.numCores > 1
        if isempty(gcp('nocreate'))
            % Init parallel pool if desired.
            create_parallelPool(CPM.parameter.numCores);
        end
        pctRunOnAll warning off % Suppress warnings.
        if CPM.parameter.verbose
            permMsg = 'This will take quite time. Please be patient...\n';
            fprintf(permMsg)
        end
        parfor p = 1: permIter
            set_seed(rndSeeds(p));
            permCPM = CPM;
            permCPM.data.y = permCPM.data.y(randperm(nSub), :);
            [posPermCVscore(p+1), negPermCVscore(p+1), combPermCVscore(p+1)] = crossVal_wrapper(permCPM);
        end
    else
        warning('off') % Suppress warnings.
        if CPM.parameter.verbose
            permMsg = 'Progress:';
            permProg = CmdProgress(permMsg, permIter);
        end
        for p = 1: permIter
            set_seed(rndSeeds(p));
            permCPM = CPM;
            permCPM.data.y = permCPM.data.y(randperm(nSub), :);
            [posPermCVscore(p+1), negPermCVscore(p+1), combPermCVscore(p+1)] = crossVal_wrapper(permCPM);
            permProg.increment;
        end
    end
    elapsedTime = toc; 
    
    permScore.pos = [posPermCVscore(1), ...
        (sum(posPermCVscore >= posPermCVscore(1))-1)/permIter];
    permScore.neg = [negPermCVscore(1), ...
        (sum(negPermCVscore >= negPermCVscore(1))-1)/permIter];
    permScore.comb = [combPermCVscore(1), ...
        (sum(combPermCVscore >= combPermCVscore(1))-1)/permIter];
    if CPM.parameter.verbose
        fprintf(['Permutation testing has finished.\n',...
            'Positive Network: %.3f, p = %.3f\n', ...
            'Negative Network: %.3f, p = %.3f\n', ...
            'Combined Network: %.3f, p = %.3f\n',...
            'Total time elapsed (in minutes): %.2f\n\n'],...
            permScore.pos(1), permScore.pos(2),...
            permScore.neg(1), permScore.neg(2),...
            permScore.comb(1), permScore.comb(2),...
            elapsedTime/60);
    end
    warning('on'); % Reactivate warnings.
end

    function [] = set_randomSeed(randSeed)
        % set_randomSeed sets seeds to the random generator. 
        % Random Seed
        if randSeed ~= -1 % -1 refers to random shuffle.
            set_seed(randSeed);
        else
            set_seed('shuffle');
        end
    end

end

function [pos, neg, comb] = crossVal_wrapper(CPM)
% crossVal_wrapper is a wrapper function to make crossValidation
% function compatible with permutation testing function.
cvResults = crossValidation(CPM.objFun,CPM.data,'kfold',CPM.parameter.kFold);
pos = [cvResults.pos];
neg = [cvResults.neg];
comb = [cvResults.comb];
pos = mean([pos.score]);
neg = mean([neg.score]);
comb = mean([comb.score]);
end


