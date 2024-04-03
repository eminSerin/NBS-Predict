function [mainNBSPredict] = get_NBSPredictInput(NBSPredict)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_NBSPredictInput checks NBSPredict structure provided and set default
% parameters if no provided. It also loads correlation matrices using
% a directory containing correlation matrices provided in NBSPredict
% structure. It returns structure containing all data and parameters
% required for NBS-Predict to run.
%
% Arguments:
%   NBSPredict = A structure containing parameters and directory including
%       correlation matrices. It automatically created by NBS-Predict GUI,
%       however, it could also be created by user manually (for command
%       line usage)
%
% Output:
%   mainNBSPredict = NBSPredict structure including all data and parameters
%       required for the toolbox.
%
% Example:
%   [NBSPredict] = get_NBSPredictInput(NBSPredict);
%
% Last edited by Emin Serin, 24.02.2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set default parameters
default.parameter.kFold = 10;
default.parameter.repCViter = 10;
default.parameter.pVal = 0.01;
default.parameter.numCores = 1;
default.parameter.ifHyperOpt = 0;
default.parameter.verbose = 1;
default.parameter.ifSave = 1;
default.parameter.ifView = 0; 
default.parameter.scalingMethod = [];
default.parameter.randSeed = 42;
default.parameter.ifPerm = 0;
default.parameter.permIter = 500;
default.parameter.ifModelExtract = 1;

if isstring(NBSPredict) || ischar(NBSPredict)
    assert(exist(NBSPredict, 'file') == 2, 'The input file is not found!') 
    load(NBSPredict)
end

if isfield(NBSPredict,'info')
    default.info = NBSPredict.info;
end

% Check important data are provided.
if NBSPredict.parameter.ifTest
    assert(isfield(NBSPredict.data, 'y'), 'Target is not provided!');
else
    assert(isfield(NBSPredict.data,'designPath'),'Design matrix is not provided!');
    NBSPredict.data.y = loadData(NBSPredict.data.designPath); % Load y
end
assert(isfield(NBSPredict.parameter,'contrast'),'Contrast vector is not provided!');

if isfield(NBSPredict.parameter,'ifHyperOpt')
    % Set default hyperOptSteps parameter if ifHyperOpt exists and set to 1
    % in the NBSPredict struct provided.
    if NBSPredict.parameter.ifHyperOpt == 1
        hyperOptSteps = 5;
        default.parameter.hyperOptSteps = hyperOptSteps;
    end
end

% Set default feature selection method if no provided.
if ~isfield(NBSPredict.parameter,'selMethod')
    NBSPredict.parameter.selMethod = 'randomSearch';
end
hyperOptMethods = NBSPredict.parameter.selMethod;
switch hyperOptMethods
    % Set default parameters for feature selection method.
    case {'bayesOpt','randomSearch'}
        default.parameter.nIter = 20;
        hyperOptParamNames = {'nIter'};
        if strcmpi(hyperOptMethods,'bayesOpt')
            default.parameter.acquisitionFun = 'expected-improvement';
        end
    case 'gridSearch'
        hyperOptParamNames = {};
end
hyperOptParamNames = {hyperOptParamNames{:},'kFold','bestParamMethod','metric'};

if ~isfield(NBSPredict.parameter,'ifModelOpt')
    % Set ifModelOpt parameter if no provided.
    NBSPredict.parameter.ifModelOpt = 1;
end
ifModelOpt = NBSPredict.parameter.ifModelOpt;

[ifClassif, nClasses] = check_classification(NBSPredict.data.y);
if ifClassif
    % Set default models.
    if ifModelOpt
        default.parameter.MLmodels = {'LogReg','svmC','lda'};
    else
        default.parameter.MLmodels = {'LogReg'};
    end
    default.parameter.metric = 'accuracy';
    if nClasses > 2
        error('NBS-Predict can only be used binary classification and regression problems!');
    else
        default.parameter.test = 't-test';
    end
    default.parameter.ifClass = 1;
else
    if ifModelOpt
        default.parameter.MLmodels = {'LinReg', 'svmR'};
    else
        default.parameter.MLmodels = {'LinReg'};
    end
    default.parameter.metric = 'correlation';
    default.parameter.test = 'f-test';
    default.parameter.ifClass = 0;
end

%% Assign entered values.
dataFields = fieldnames(NBSPredict.data);
parameterFields = fieldnames(NBSPredict.parameter);
enteredFields = {dataFields,parameterFields};
enteredFieldNames = {'data','parameter'};
for mainFielditer = 1: numel(enteredFieldNames)
    cMainField = enteredFields{mainFielditer};
    for enteredValiter = 1: numel(cMainField)
        cEnteredVal = cMainField{enteredValiter};
        default.(enteredFieldNames{mainFielditer}).(cEnteredVal) =...
            NBSPredict.(enteredFieldNames{mainFielditer}).(cEnteredVal);
    end
end

if default.parameter.numCores > 1 && ~ license('test','distrib_computing_toolbox')
    % Set number of cores to 1 again, if no Parallel Computing Toolbox 
    % found on local computer.
    warning('No Parallel Computing Toolbox found! NBS-Predict will run sequantially.');
    default.parameter.numCores = 1;
end

%% Load data if has not been loaded.
if ~isfield(default.data,'X')
    % Check important data are provided.
    if ~isfield(default.data,'corrPath')
       error('A directory containing correlation matrices is not defined!');
    else
        [default.data.X,default.data.nodes,default.data.edgeIdx] = load_corrMatFiles(default.data.corrPath,...
            default.parameter.verbose);
    end
    if ~isfield(default.data,'brainRegionsPath')
       error('Brain regions are not provided!')
    else
        try
            brainRegions = loadData(default.data.brainRegionsPath);
            brainRegions.Properties.VariableNames = {'X','Y','Z','labels'};
            default.data.brainRegions = brainRegions;
        catch 
            error(['Brain regions cannot be loaded. ',...
                'Please check the sample data for the example input structure!']);
        end
    end
end

% Check if confound variable is provided. 
nuisanceIdx = find(default.parameter.contrast == 0); 
if ~isempty(nuisanceIdx)
    if ~isfield(NBSPredict.data,'confounds')
        confoundsIdx = nuisanceIdx(nuisanceIdx~=1); 
        default.data.confounds = default.data.y(:,confoundsIdx);
        default.data.y(:,confoundsIdx) = [];
        default.parameter.originalContrast = default.parameter.contrast;
        default.parameter.contrast(confoundsIdx) = [];
    end
else
    default.data.confounds = [];
end
% Extract y (i.e., independent variables) from the design matrix. 
default.data.y = default.data.y(:, 1:2); 

% Check if LOOCV is selected.
if default.parameter.kFold == -1 
    default.parameter.kFold = size(default.data.y,1);
end
% if LOOCV and regression, then throw error
if ~default.parameter.ifClass && default.parameter.kFold == size(default.data.y,1)
    error('LOOCV cannot be used for regression problems!');
end
if default.parameter.kFold == size(default.data.y,1)
    default.parameter.repCViter = 1;
    warning('LOOCV is selected. repCViter is set to 1.');
end

%% Hyperparameters
% Set default hyperparameters for given model.
for m = 1:numel(default.parameter.MLmodels)
    if default.parameter.ifHyperOpt
        switch default.parameter.MLmodels{m}
            case {'decisionTreeC','decisionTreeR'}
                %Rafael Gomes Mantovani, Tomáš Horváth, Ricardo Cerri,
                %Sylvio Barbon Junior, Joaquin Vanschoren, André Carlos
                %Ponce de Leon Ferreira de Carvalho, “An empirical study on
                %hyperparameter tuning of decision trees” arXiv:1812.02207
                default.parameter.paramGrids(m).MinLeafSize = linspace(1,20,hyperOptSteps);
                if strcmpi(default.parameter.MLmodels{m}, 'decisionTreeC')
                    default.parameter.paramGrids(m).SplitCriterion = {'gdi','deviance'};
                end
            case {'LinReg','LogReg','svmC','svmR'}
                default.parameter.paramGrids(m).lambda = logspace(-2,3,hyperOptSteps);
%                 if ismember(default.parameter.MLmodels{m}, {'svmC','svmR'})
%                     % If SVM.
%                     default.parameter.paramGrids(m).solver =  {'sgd','asgd','lbfgs','dual'};
%                 else
%                     % If regression.
%                     default.parameter.paramGrids(m).solver = {'sgd','asgd','lbfgs'};
%                 end
            case {'lda'}
                default.parameter.paramGrids(m).gamma = linspace(0,1,hyperOptSteps);
        end
    end
end

%% Best parameter selection metric. 
if ~isfield(default.parameter,'bestParamMethod')
    default.parameter.bestParamMethod = 'best';
end

%% Feature selection
% Prepare a cell array including feature selection parameters.
nSearchParams = numel(hyperOptParamNames);
searchParams = cell(nSearchParams*2,1);
searchParams(linspace(1,nSearchParams*2-1,nSearchParams)) = hyperOptParamNames; 
cSearchParamIdx = 0;
for i = 1:nSearchParams
    cSearchParamIdx = cSearchParamIdx+2;
    searchParams(cSearchParamIdx) = {default.parameter.(hyperOptParamNames{i})};
end

% assign feature selection function handle
searchHandle = str2func(default.parameter.selMethod); 
default.searchHandle = @(objFun,data,paramGrid) searchHandle(objFun,data,paramGrid,searchParams{:});

%% Return assigned default structure.
mainNBSPredict = default; 
end

