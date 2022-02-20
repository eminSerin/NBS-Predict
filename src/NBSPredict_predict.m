function [y_pred] = NBSPredict_predict(model, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NBSPredict_predict predicts labels using given novel connectome data. It
% uses model trained by NBSPredict pipeline. The model locates in the
% outcome NBSPredict.results.(model).model substructure. Please keep in
% mind that the input data must be in the same shape of the data used
% during training. Also, confound matrix must also be provided if confound
% regression was performed in training. 
%
% Arguments:
%   model: Model substructure located under the outcome
%       NBSPredict.results.(cModel) substructure. It contains the trained 
%       model and preprocessing objects.
%   connectome: Connectivity matrices. User can provide directory for
%       connectivity file (.csv or .mat) or connectivity database (.mat,
%       node x node x n_sub), node x node matrix, or node x node x n_sub
%       database. If no input provided, the function automatically asks to
%       load connectivity matrices.
%   confMat: Confound matrix. If deconfounding had performed in training,
%       confound matrix for test data should be provided.
%
% Output:
%   y_pred: Predicted labels.
%
% Last edited by Emin Serin, 12.01.2022.
%
% See also: run_NBSPredict
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse optional inputs.
defaultVals.connectome = []; defaultVals.confMat = [];
p = inputParser();
p.PartialMatching = 0;
addParameter(p,'connectome',defaultVals.connectome);
addParameter(p,'confMat',defaultVals.confMat);

% Parse inputs. 
parse(p,varargin{:});
connectome = p.Results.connectome;
confMat = p.Results.confMat; 

if isempty(connectome)
    % Ask to load connectivity matrices if no provided.
    [files, path] = uigetfile({'*.mat', '*.csv'},...
        'Please select connectivity matrices.', 'Multiselect', 'on');
    if iscell(files)
        for f = 1 : length(files)
           files{f} = [path, files{f}];
        end
        connectome = files;
    else
        connectome = [path, files];
    end
end

if isfolder(connectome)
    % If connectome directory is given.
    connectome = dir(connectome);
    connectome = connectome(~ismember({connectome.name},{'.','..'}));
    nFiles = numel(connectome);
    files = cell(nFiles, 1);
    for f = 1: nFiles
        files{f} = [connectome(f).folder, filesep, connectome(f).name];
    end
    connectome = files;
end

% Load data! 
% Connectome data.
if ischar(connectome)
    connData = load_file(connectome);
elseif iscell(connectome)
    nFiles = length(connectome);
    for f = 1: nFiles
        cFile = connectome{f};
        if f == 1
            tmp = load_file(cFile);
            dataSize = size(tmp);
            connData = zeros([dataSize, nFiles]);
            connData(:, :, f) = tmp;
        end
        connData(:, :, f) = load_file(cFile);
    end 
elseif ismatrix(connectome)
    connData = connectome;
else
   error(['Unrecognized input type!',...
       'Connectome input must be either matrix or directory for matrix.']) ;
end

% Confound matrix. 
if ~isempty(confMat)
    if ischar(confMat)
        confMat = load_file(confMat);
    elseif ismatrix(confMat)
        confMat = confMat;
    else
       error(['Unrecognized input type!',...
           'Confound matrix must be either matrix or directory for matrix.']) ; 
    end
end

% Shrink connectivity matrices into edge matrices.
X = shrinkMat(connData); 

% Predicts label using given data.
if ~isempty(model.preprocess.scaler)
    X = model.preprocess.scaler.transform(X);
end
if ~isempty(model.preprocess.confCorr)
    if ~isempty(confMat)
        X = model.preprocess.confCorr.transform(X, confMat);
    else
        warning(['Confound matrix is not provided! ',...
            'Prediction will continue without deconfounding!'])
    end
end
X = X(:, model.preprocess.edgeSelectMask);
y_pred = model.Mdl.pred(model.estimator, X);
end

function data = load_file(fileName)
    % Loads .mat or .csv files.
    assert(exist(fileName, 'file') == 2, 'The file does not exist!')
    ext = fileName(end-2:end); 
    if strcmpi(ext, 'csv')
        data = csvread(fileName);
    elseif strcmpi(ext, 'mat')
        data = load(fileName);
        fieldName = fieldnames(data);
        data = data.(fieldName{1});
    else
        error('Unrecognized file extension! Connectome file must be .csv or .mat!')
    end
end
