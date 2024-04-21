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
% Example:
%    NBSPredict_predict(NBSPredict.results.lda.model, 'connectome',... 
%       '~/Documents/holdout/connMats/subject-001.mat',...
%       'confMat', '~/Documents/holdout/confoundMat.mat');
%
%   Sample script to evaluate the holdout performance of the trained model.
%   
%   % Set main directory for the holdout prediction.
%   holdoutDir = '~Documents/holdoutPrediction/'; 
%   fprintf('Started predicting holdout subjects... \n');
%
%   % Model to predict holdout subjects.
%   model = NBSPredict.results.lda.model;
%   
%   % Predict holdout subjects.
%   yPred = NBSPredict_predict(model,...
%   'connectome', [holdoutDir, 'connMats/'],...
%   'confMat', [holdoutDir, 'confoundMat.csv']); 
%   
%   % Load true labels
%   yTrue = csvread([holdoutDir, 'trueLabels.csv']);
%   
%   % Compute explained variance between predicted and true labels, and print.
%   score = compute_modelMetrics(yTrue, yPred, 'explained_variance'); 
%   fprintf('Explained variance: %.3f \n', score);
%
% Last edited by Emin Serin, 18.02.2022.
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
if ischar(connectome) || isstring(connectome)
    connData = loadData(connectome);
elseif ismatrix(connectome) && ~isstring(connectome)
    connData = connectome;
else
   error(['Unrecognized input type!',...
       'Connectome input must be either matrix or directory for matrix.']) ;
end

% Confound matrix. 
if ~isempty(confMat)
    if ischar(confMat)
        confMat = loadData(confMat);
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

% TODO: Remove in the following versions. 
% function data = loadData(fileName)
%     % Loads .mat or .csv files.
%     assert(exist(fileName, 'file') == 2, 'The file does not exist!')
%     ext = fileName(end-2:end); 
%     if strcmpi(ext, 'csv')
%         data = csvread(fileName);
%     elseif strcmpi(ext, 'mat')
%         data = load(fileName);
%         fieldName = fieldnames(data);
%         data = data.(fieldName{1});
%     else
%         error('Unrecognized file extension! Connectome file must be .csv or .mat!')
%     end
% end
