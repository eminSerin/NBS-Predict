function [Mdl] = run_svmR(params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_svmR returns Mdl structure including function handles of fit,
% predict and score functions for support vector regression. 
%
% Arguments: 
%   params: Structure including following hyperparameters:
%       lambda: Lambda parameter. 
%       solver: ML solver (default = 'sgd')
%   
% Output: 
%   Mdl: Structure that includes fit, predict and score function handles. 
%
% Reference:
%   https://en.wikipedia.org/wiki/Support-vector_machine
%   https://www.mathworks.com/help/stats/understanding-support-vector-machine-regression.html
%
% Last edited by Emin Serin, 25.02.2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters.
defaultParams.lambda = 0;
defaultParams.solver = 'sgd';

if nargin < 1 || isempty(params)
    % Create struct if no provided.
    params = struct;
end
% Validate hyperparameter provided (if not, return default hyperparameters)
params = check_MLparams(params,defaultParams);

% Function handles.
Mdl.fit = @(X,y) fitrlinear(X, y, 'Learner','svm',...
    'Lambda', params.lambda,...
    'Solver', params.solver,...
    'Regularization', 'ridge');

Mdl.pred = @(clf,newX) clf.predict(newX);
Mdl.score = @compute_modelMetrics;
end