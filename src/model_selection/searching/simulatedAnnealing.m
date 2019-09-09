function [bestParam,bestParamScore,bestParamIdx] = simulatedAnnealing(objFun,data,paramGrid,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simulatedAnnealing performs simulated annealing over parameters provided.
% Simulated annealing is a Monte Carlo method, that approximates global
% optimization in a parameter space. It resembles to Hill Climbing search
% algorithm with a difference that it picks a random move instead of best
% move.
%
% Arguements:
%   objFun = Objective function (e.g., estimator).
%   data = Data structure including X and y matrices. 
%   paramGrid = Parameter grid.
%   nIter: Number of iteration.
%   alpha:  Boltzmann's constant.
%   T = initial temperature.
%   kFold = Number of CV folds (default = 10). 
%   ifParallel = Parallelize CV (1 or 0, default = 0).
%   bestParamMethod = Method to choose best parameter ('max','ose','median','min' default = "max").
%       Check help section of bestParamMetric for detailed information.     
%   sortDirection = Direction of sorting ('ascend' or 'descend', default= 'ascend'). 
%       Check help section of bestParamMetric for detailed information.
%
% Output:
%   bestParam = Parameter with best CV score. 
%   bestParamScore = Cross-validation score of best parameters found. 
%   bestParamIdx = Index of best parameter in a parameter space given.
%
% Reference:
%   https://en.wikipedia.org/wiki/Simulated_annealing
%
% To calculate required iteration to get a specific T minimum value. 
%   (log(Tmin) - log(T))/log(alpha)
%
% Emin Serin - 01.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set default inputs.
% validate parameters and return default parameters if no provided. 
searchInputs = get_searchInputs('simulatedAnnealing',varargin{:}); 
nIter = searchInputs.nIter; kFold = searchInputs.kFold;
T = searchInputs.T; ifParallel = searchInputs.ifParallel;
%%
% Set the random seed based on current time.
rng('shuffle');

% Total number of parameters.
[~,nComb] = get_paramGridShapeComb(paramGrid);

% Preallocate parameter memory.
% 1st cell = parameter position, 2nd cell = parameter score.
paramMem = cell(3,1);
paramMem(1:2,1) = {zeros(nIter+1,1)};
paramMem{3,1} = cell(nIter+1,1);
% paramMem(3,1) = {zeros(NBSPredict.parameter.kFold,nIter+1,nParamGrid)};

% Initial score
initParamPer = 10; % Initial percentage of total parameters.
oldParamPos = round(nComb/initParamPer);
params = get_paramItem(paramGrid,oldParamPos);
CVfun = @(data) objFun(data,params);
[CVscore] = crossValidation(CVfun,data, 'ifParallel',ifParallel,...
    'kFold',kFold);
oldParamScore = mean(CVscore);
% Save scores to parameter memory.
paramMem{1,1}(1) = oldParamPos;
paramMem{2,1}(1) = oldParamScore;
paramMem{3,1}(1) = {CVscore};

% Optimization loop.
for iter = 1 : nIter
    % Find candidate parameter.
    newParamPos = climb(oldParamPos,nComb,T);
    
    % Check if candidate parameter already picked or out of the threshold.
    if ~ismember(newParamPos,paramMem{1})
        params = get_paramItem(paramGrid,newParamPos);
        CVfun = @(data) objFun(data,params);
        % Fit model with the candidate parameter and get mean CV score.
        [CVscore] = crossValidation(CVfun,data, 'ifParallel',ifParallel,...
            'kFold',kFold);
        newParamScore = mean(CVscore);
        paramMem{3,1}(iter+1) = {CVscore};
    else
        sameParamIdx = find(paramMem{1,1}==newParamPos,1,'first');
        newParamScore = paramMem{2,1}(sameParamIdx);
        paramMem{3,1}(iter+1) = paramMem{3,1}(sameParamIdx);
%         midAdj = paramMem{3,1}(:,sameParamIdx,:);
    end
    
    % Save scores to parameter memory.
    paramMem{1,1}(iter+1) = newParamPos;
    paramMem{2,1}(iter+1) = newParamScore;
%     paramMem{3,1}(:,iter+1,:) = midAdj;
    
    % Annealing
    if newParamScore >= oldParamScore
        oldParamPos = newParamPos;
        oldParamScore = newParamScore;
    else
        acceptProb = exp((newParamScore-oldParamScore)/T); % Calculate acceptance probability.
        if acceptProb >= rand()
            oldParamPos = newParamPos;
            oldParamScore = newParamScore;
        end
    end
    
    % Update temperature;
    T = T * searchInputs.alpha;
end

% Find best parameter
[bestParam,bestParamScore,bestParamIdx] = get_bestParam(cell2mat(paramMem{3,1}'),paramMem{1,1},...
    paramGrid,...
    'metric',searchInputs.bestParamMethod,...
    'sortDirection',searchInputs.sortDirection);
% bestParamEdgeMat = squeeze(paramMem{3,1}(:,mIdx,:));

    function [newParamPos] = climb(oldParamPos,paramSpaceDim,T)
        % Climb is a neighboring function for simulated annealing algorithm. I is
        % basically a different version of a climbing function in Hill Climbing
        % algorithm. Climb returns position of new parameter in parameter space.
        % It generates a random sample from a Gaussian Distribution with mean of
        % position of the current parameter in given parameter space and standard
        % deviation of (parameterSpaceDimension/100)*Current temperature in the
        % simulated annealing algorithm. From the generated normally distributed
        % random sample, a random point is drawn, and returned. In some
        % cases, if a random point drawn is out of parameter space, a new
        % point is drawn from random sample. If that happens 5 times in row
        % which indicates there is no suitable point left, it climb returns
        % position of the current parameter.
        %
        % Arguements:
        %   oldParamPos: Position of the current parameter in a parameter space.
        %   paramSpaceDim: Shape of the parameter space.
        %   T: Current temperature.
        %
        % Output:
        %   newParamPos: Position of new parameter in a parameter space.
        %
        % Example:
        %   [newParamPos] = climb(50,1000,0.52)
        %
        % Emin Serin - 22.07.2019
        %
        %%
        sigma = (paramSpaceDim/100)*T; % Sigma of standard distribution.
        newParamPos = round(oldParamPos+(sigma*randn(1)));
        k = 1;
        while newParamPos < 1 || newParamPos > paramSpaceDim
            if k == 6
                newParamPos = oldParamPos;
                break;
            end
            newParamPos = round(oldParamPos+(sigma*randn(1)));
            k = k+1;
        end
        
    end
end
