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