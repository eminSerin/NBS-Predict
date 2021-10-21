function [Mdl] = run_LassoR(params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_LassoC returns Mdl structure including function handles of
% builtin fit, predict and score functions for Lasso regression.
%
% Arguments: 
%   params: Structure including following hyperparameters:
%   lambda: Lambda parameter. 
% 
% Output: 
%   Mdl: Structure that includes fit, predict and score function handles. 
%
% Reference:
%   https://en.wikipedia.org/wiki/Lasso_(statistics)
%   
%
% Emin Serin - 10.08.2019
%
% See also: fitclinear, run_LassoC, run_NBSPredict_Lasso
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters.
defaultParams.lambda = 'auto';

if nargin < 1 || isempty(params)
    % Create struct if no provided.
    params = struct;
end
% Validate hyperparameter provided (if not, return default hyperparameters)
params = check_MLparams(params,defaultParams);

% Function handles.
Mdl.fit = @(X,y) fitrlinear(X,y,'Learner','leastsquares',...
    'Regularization','lasso','Lambda', params.lambda);
Mdl.pred = @(clf,newX) clf.predict(newX);
Mdl.score = @compute_modelMetrics;
end