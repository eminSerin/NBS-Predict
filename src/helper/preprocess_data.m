function varargout = preprocess_data(data,scalingMethod)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preprocess_data performs preprocessing on data provided.
% Preprocessing consists of rescaling and, if provided, removing
% confounds from data.
%
% Arguments:
%   data: Structure comprising test and train X and y data. 
%   scalingMethod: Scaling method (default: None)
%
% Output: 
%   data: Processed data. 
%   scaler = Scaler object. 
%   confcorr = Confound correction object.
%
% Example:
%   data = preprocess_data(data,'MinMaxScaler');
%
% Last edited by Emin Serin, 11.01.2022.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Preprocess data
varargout = cell(1, 3);
if ~isempty(scalingMethod)
    % Rescale data.
    scaler = feval(scalingMethod);
    if isfield(data, 'X_train') && isfield(data, 'X_test')
        data.X_train = scaler.fit_transform(data.X_train);
        data.X_test = scaler.transform(data.X_test);
    elseif isfield(data, 'X') 
        data.X = scaler.fit_transform(data.X);
    else
        error('No feature data was found!');
    end
    varargout{2} = scaler;
end
if isfield(data,'confounds_train') || isfield(data, 'confounds')
    % Remove variance associated with confounds from data.
    confcorr = ConfoundRegression;
    if isfield(data, 'X_train') && isfield(data, 'X_test')
        data.X_train = confcorr.fit_transform(data.X_train,data.confounds_train);
        data.X_test = confcorr.transform(data.X_test,data.confounds_test);
    elseif isfield(data, 'X') 
        data.X = confcorr.fit_transform(data.X, data.confounds);
    else
        error('No feature data or confound matrix were found');
    end
    varargout{3} = confcorr;
end
varargout{1} = data;
end