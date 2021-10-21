function [Mdl] = run_ElasticNetR(params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_ElasticNetR returns Mdl structure including function handles of fit,
% predict and score functions for Elastic Net regression. 
%
% Arguments: 
%   params: Structure including following hyperparameters:
%   lambda: Intensity of penalty terms (default = 0.1). 
%   alpha:  Mixing parameter; 0 (L2) <= alpha <= 1(L1) (default = 0.5).
% 
% Output: 
%   Mdl: Structure that includes fit, predict and score function handles. 
%
% Reference:
%   https://en.wikipedia.org/wiki/Elastic_net_regularization
%   https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.ElasticNet.html
%   Glmnet for Matlab (2013) Qian, J., Hastie, T., Friedman, J., Tibshirani, R. and Simon, N.
%       http://www.stanford.edu/~hastie/glmnet_matlab/
%
% Last edited by Emin Serin - 08.04.2021
%
% See also: run_ElasticNetC, run_NBSPredict_ElasticNet, glmnet
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters.
defaultParams.lambda = 0.1;
defaultParams.alpha = 0.5;

if nargin < 1 || isempty(params)
    % Create struct if no provided.
    params = struct;
end
% Validate hyperparameter provided (if not, return default hyperparameters)
params = check_MLparams(params,defaultParams);

% Function handles.
Mdl.fit = @(X,y) glmnet(X,y,'gaussian', params);
Mdl.pred = @(clf,newX) predict(clf,newX);
Mdl.score = @compute_modelMetrics;
end

function [y_pred] = predict(clf,newX)
% Predict continous target.
y_pred = glmnetPredict(clf,newX,clf.lambda,'response');
end