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
% Emin Serin - 05.07.2020
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

if isstring(NBSPredict) || ischar(NBSPredict)
    assert(exist(NBSPredict, 'file') == 2, 'The input file is not found!') 
    load(NBSPredict)
end

if isfield(NBSPredict,'info')
    default.info = NBSPredict.info;
end

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
        default.parameter.MLmodels = {'decisionTreeC','svmC','LogReg','lda'};
    else
        default.parameter.MLmodels = {'decisionTreeC'};
    end
    default.parameter.metric = 'accuracy';
    if nClasses > 2
        error('NBS-Predict can only be used binary classification and regression problems!');
    else
        default.parameter.test = 't-test';
    end
else
    if ifModelOpt
        default.parameter.MLmodels = {'decisionTreeR','svmR','LinReg'};
    else
        default.parameter.MLmodels = {'decisionTreeR'};
    end
    default.parameter.metric = 'rmse';
    default.parameter.test = 'f-test';
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
        [default.data.X,default.data.nodes,default.data.edgeIdx] = load_corrMatFiles(default.data.corrPath);
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

% Check important data are provided.
assert(isfield(default.data,'y'),'Design matrix is not provided!');
assert(isfield(default.parameter,'contrast'),'Contrast vector is not provided!');

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

%% Check if Linear Model
linearModels = {'svmC','svmR','LinReg','LogReg'};
ifLinear = ismember(default.parameter.MLmodels,linearModels);
default.parameter.ifLinear = ifLinear; 
%% Hyperparameters
% Set default hyperparameters for given model.
for m = 1:numel(default.parameter.MLmodels)
    if default.parameter.ifHyperOpt
        switch default.parameter.MLmodels{m}
            case 'svmC'
                default.parameter.paramGrids(m).C = logspace(-1,3,hyperOptSteps);
            case 'svmR'
                default.parameter.paramGrids(m).epsilon = logspace(-1,2,hyperOptSteps);
            case {'decisionTreeC','decisionTreeR'}
                %Rafael Gomes Mantovani, Tomáš Horváth, Ricardo Cerri,
                %Sylvio Barbon Junior, Joaquin Vanschoren, André Carlos
                %Ponce de Leon Ferreira de Carvalho, “An empirical study on
                %hyperparameter tuning of decision trees” arXiv:1812.02207
                default.parameter.paramGrids(m).MinLeafSize = linspace(1,20,hyperOptSteps);
            case {'LinReg','LogReg'}
                default.parameter.paramGrids(m).lambda = logspace(-2,3,hyperOptSteps);
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
nFeatSelparams = numel(hyperOptParamNames);
featSelParams = cell(nFeatSelparams*2,1);
featSelParams(linspace(1,nFeatSelparams*2-1,nFeatSelparams)) = hyperOptParamNames; 
cFeatParamIdx = 0;
for i = 1:nFeatSelparams
    cFeatParamIdx = cFeatParamIdx+2;
    featSelParams(cFeatParamIdx) = {default.parameter.(hyperOptParamNames{i})};
end

% assign feature selection function handle
featSelHandle = str2func(default.parameter.selMethod); 
default.featSelHandle = @(objFun,data,paramGrid) featSelHandle(objFun,data,paramGrid,featSelParams{:});

%% Return assigned default structure.
mainNBSPredict = default; 
end

