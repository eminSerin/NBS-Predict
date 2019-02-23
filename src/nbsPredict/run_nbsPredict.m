function [NBSPredict] = run_nbsPredict(NBSPredict)
%   RUN_NBSPREDICT Summary of this function goes here
%   Detailed explanation goes here

%% Pre-compute
% Load files and get edge matrix.
[edgeMat,nodes,edgeIdx] = load_nbsPredictFiles(NBSPredict);


% Cross-validation.
if NBSPredict.ifLOOCV
    cvgen = @(y) gen_cvpartition(y,true); % loocv
else
    cvgen = @(y) gen_cvpartition(y,false,NBSPredict.kFold); % Kfold CV
end

compFun = @(x) max(x); % Select highest value for best performance
if ismember(NBSPredict.metric,{'rmse','mad'})
    % if RMSE or MAD is selected. 
    compFun = @(x) min(x); % Select lowest value for best performance
end

if NBSPredict.ifModelOpt
    if strcmpi(NBSPredict.MLtype,'classification')
        NBSPredict.mlModel = {'svmC','decisionTree'};
    else
        NBSPredict.mlModel = {'svmR','decisionTreeR','linearR'};
    end
end
% NBSPredict.mlModel = {'decisionTree'}; % REMOVE!

tic;
% Main Loop.
for mm = 1:numel(NBSPredict.mlModel)
    Mdl = select_model(NBSPredict.mlModel{mm});
    % Hyperparameter optimization
    doOpt = 0; % Perform hyperparameter optimization.
    if doOpt
        % Create parameter space for grid search.
        % TODO: add hyperparameter optimization for other classifiers.
        paramSteps = 5;
        if strcmpi(NBSPredict.mlModel(mm),'elasticnetC')
            % Elastic net
            alpha = linspace(0,1,paramSteps);
            lambda = logspace(-7,3,paramSteps);
            pGrid = {alpha,lambda};
            [pGrid{:}] = ndgrid(pGrid{:});
        elseif strcmpi(NBSPredict.mlModel(mm),'svmC')
            % SVM
            pGrid{:} = logspace(-1,3,paramSteps);
        else
            % TODO: develop.
            doOpt = 0;
        end
    else
        pGrid = {};
    end
    
    % Cross validation
    outerFoldIdx = cvgen(NBSPredict.designMat); % outer fold cv.
    noutFold = numel(outerFoldIdx);
    
    % Display some info.
    fprintf('Starting...\nSelected model: %s\n# of Folds: %d\n',NBSPredict.mlModel{mm},noutFold);
    
    % Verbose
    verbose = 1;
    if verbose
        str1 = '--------------------------------------------------------------------';
        fprintf([str1,'\n','| Outer Fold | Winning Threshold | Accuracy Score | Moving Average |\n',str1,'\n'])
    end
    
    % Allocate some variables.
    tic;
    % scores = zeros(noutFold);
    outerScores = zeros(noutFold,1);
    outAdj = false(nodes,nodes,noutFold);
    for outerFold = 1:noutFold
        % Current outer fold.
        cOuterFold.y = edgeMat(outerFoldIdx(outerFold).trainIdx,:); % data
        cOuterFold.X = NBSPredict.designMat(outerFoldIdx(outerFold).trainIdx,:); % design matrix
        
        % Generate indices for middle fold.
        middleFoldIdx = cvgen(cOuterFold.X); % middle fold cv.
%         middleFoldIdx = gen_cvpartition(y,false,10);
        %     bigCompN = false(noutFold,nodes); % nodes in biggest components.
        %     tEdges = false(lenTList,noutFold,numel(edgeIdx)); % edges.
        
        nFolds = numel(middleFoldIdx);
        midAdj = false(nFolds,10,nodes,nodes);
        scores = zeros(nFolds,1);
        
        
        % Perform feature selection in the middle fold.
        pU = 100;
        k = 1;
        OptLowLim = 0;
        while k <= NBSPredict.optSteps && ~(pU <= OptLowLim)
            for middleFold = 1:nFolds
                % Calculate t-value using GLM
                glm.y = cOuterFold.y(middleFoldIdx(middleFold).trainIdx,:); % data
                glm.X = cOuterFold.X(middleFoldIdx(middleFold).trainIdx,:); % design matrix
                glm.contrast = NBSPredict.contrast;
                glm.test = NBSPredict.test;
                glm = run_nbsPredictGlm(glm); % run glm and get test statistics.
                
                [V,I] = sort(glm.Stats,'descend');
                
                %%%%%%%%%%%%%%%%%%%%
%                 % Filter stat values
%                 statFilter = V > 1;
%                 I = I(statFilter);
                %%%%%%%%%%%%%%%%%%%%
                
                if k == 1
                    OptLowLim = (1/length(I)*100); % Lowest limit of optimization (only one feature.)
                    pl = OptLowLim;
                end
                
                cThresh = linspace(pl,pU,NBSPredict.optSelNum);
                for cc = 1 : NBSPredict.optSelNum
                    cPercent = cThresh(cc);
                    cEdgesIdx = I(1:round(length(I)*(0.01*cPercent)));
                    adj = spalloc(nodes,nodes,length(cEdgesIdx)*2);
                    adj(edgeIdx(cEdgesIdx)) = 1;
                    adj = adj + adj';
                    
                    % Get components.
                    % TODO: If two or more component with same size.
                    [comp,compSz]=get_components(adj); % components and their sizes.
                    [~, mCompIdx] = max(compSz); % value and index of biggest component.
                    tmp =  (mCompIdx == comp);
                    
                    % Extract values of components.
                    adj(:,~tmp) = 0; % set 0 to non-component nodes.
                    midAdj(middleFold,cc,:,:) = adj;
                    [~,extIdx] = ismember(find(triu(adj)),edgeIdx); % find indexes of edges to be extracted
                    ML.X = glm.y(:,extIdx); % extract values of edges of each subject.
                    ML.y = glm.X(:,2);
                    
                    % HyperOpt
                    if doOpt
                        bestParams = doHyperOpt(Mdl,ML.X,ML.y,pGrid,cvgen);
                        Mdl.params = bestParams;
                    end
                    ML.X = ML.X; % Normalize to z-score.
                    clf = Mdl.fit(ML.X,ML.y); % fit
                    y_pred = Mdl.pred(clf,cOuterFold.y(middleFoldIdx(middleFold).testIdx,extIdx)); % predict
                    scores(middleFold,cc) = Mdl.score(cOuterFold.X(middleFoldIdx(middleFold).testIdx,2),...
                        y_pred,NBSPredict.metric); % score
                end
            end
            scores = mean(scores,1);
            [~,mIdx] = compFun(scores);
            pU = cThresh(mIdx);
            pl = pU - (cThresh(end)-pl)/(NBSPredict.optSelNum-1);
            k = k + 1;
        end
        
        winPercent = pU;
        % Extract mean component.
        % Sum ones from each fold and divide by # of cvFolds. Weighted network.
        mMidAdj = squeeze(sum(midAdj(:,mIdx,:,:),1))/size(midAdj,1);
        
        % Extract mean component.
        mMidAdj = mMidAdj == 1; % only extract edges with weight 1, which gives us a overlapped components.
        outAdj(:,:,outerFold) = mMidAdj;
        [~,extIdx] = ismember(find(triu(mMidAdj)),edgeIdx); % find indexes of edges to be extracted
        
        
        % Extract t-vals from components.
        ML.X = cOuterFold.y(:,extIdx); % extract values of edges of each subject, and normlize to z-score.
        ML.y = cOuterFold.X(:,2);
        
        % Model
        if ~isempty(ML.X)
            clf = Mdl.fit(ML.X,ML.y);
            y_pred = Mdl.pred(clf,edgeMat(outerFoldIdx(outerFold).testIdx,extIdx));
            outerScores(outerFold) = Mdl.score(NBSPredict.designMat(outerFoldIdx(outerFold).testIdx,2),...
                y_pred,NBSPredict.metric);
        else
            outerScores(outerFold) = 0;
        end
        
        if verbose
            fprintf('|     %s     |       %.3f       |      %.3f     |      %.3f     |\n',...
                num2str(outerFold,'%02d'),winPercent,...
                outerScores(outerFold),mean(outerScores(1:outerFold)));
        end
    end
    modelSc(mm) = mean(outerScores);
    tmp = sum(outAdj,3)/outerFold;
    modelAdj(:,:,mm) = tmp;
    
    
    fprintf([str1,'\nFinished.\nOverall prediction score: %.03f\n'],  modelSc(mm));
    
end

% Select best performing model. 
tmp = max(mm);
NBSPredict.Results.weightAdj = modelAdj(:,:,tmp);
NBSPredict.Results.predScore = modelSc(tmp);
NBSPredict.Results.model = NBSPredict.mlModel{tmp};
fprintf(['\nBest Model: %s Overall prediction score: %.03f\n'],NBSPredict.Results.model,NBSPredict.Results.predScore);

% View Results. 
figure;
view_NBSPredict(NBSPredict);


%% Helper functions
    function [bestParams] = doHyperOpt(Mdl,X,y,pGrid,cvgen)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   doHyperOpt performs hyperparameter optimization using grid search
        %       method.
        %   Input:
        %       Mdl: Model structure created by "select_model" function.
        %       X: features.
        %       y: labels.
        %       pGrid: parameter grid
        %       cvgen = cross-validation function handler.
        %   Output:
        %       bestParams: Best parameters.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        nParams = numel(pGrid{1});
        paramScores = zeros(nParams,1);
        for iter = 1 : nParams
            cParam = cellfun(@(c) c(iter),pGrid);
            foldIdx = cvgen(y);
            nFold = numel(foldIdx);
            cvScores = zeros(nFold,1);
            for f = 1: nFold
                % Run classifier.
                clf = Mdl.fit(X(foldIdx(f).trainIdx,:),y(foldIdx(f).trainIdx,:),cParam);
                y_pred = Mdl.pred(clf,X(foldIdx(f).testIdx,:));
                cvScores(f) = Mdl.score(y(foldIdx(f).testIdx),y_pred,modelMetric);
            end
            %     tmp = sort(cvScores);
            %     paramScores(iter) = tmp(round(length(tmp)/2)); % median hyperparameter performance scores.
            paramScores(iter) = mean(cvScores);
        end
        tmp = sort(paramScores);
        paramIdx = find(paramScores==tmp(round(length(tmp)/2)),1,'last');
        bestParams = cellfun(@(c) c(paramIdx),pGrid);
    end

    function [idx] = gen_cvpartition(y,varargin)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   gen_cvpartition generates k-fold cross-validation random or sequential
        %       partition for data of specified size. It returns a structure which
        %       consists of test and train indices for each iteration.
        %   Input:
        %       y: labels.
        %       loocv: leave-one-out cross validation (default: false)
        %       kFold: number of cv folds (default: 5).
        %       ifRand: if randomized (default: true)
        %   Output:
        %       idx = Structure of test and train indices.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Input parser.
        numvarargs = length(varargin);
        if numvarargs > 3
            % maximum number of optional inputs.
            error('too many inputs.')
        end
        optargs = {false,5,true}; % default inputs.
        optargs(1:numvarargs) = varargin; %overwrite given inputs to defaults.
        [loocv,kFold,ifRand] = optargs{:};
        
        if loocv
            % If loocv, the number of folds is equal to number of observation.
            kFold = length(y);
        end
        
        CVFolds = mod(1:length(y), kFold) + 1; % Create sequence of cv folds.
        
        if ifRand
            % Shuffle cv indices if random.
            CVFolds = CVFolds(randperm(length(CVFolds)));
        else
            % Sequential cv.
            CVFolds = sort(CVFolds);
        end
        
        for cFold = 1: kFold
            % Find train and test index for each iteration and store in a structure
            idx(cFold).testIdx = CVFolds == cFold; % test index
            idx(cFold).trainIdx = CVFolds ~= cFold; % train index.
        end
        
    end
end

