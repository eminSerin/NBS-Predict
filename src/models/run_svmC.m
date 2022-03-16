function [Mdl] = run_svmC(params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_svmC returns Mdl structure including function handles of
% builtin fit, predict and score functions for support vector
% classification.
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
%   https://en.wikipedia.org/wiki/Support_vector_machine
%   https://uk.mathworks.com/help/stats/fitclinear.html
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
Mdl.fit = @(X,y) fitclinear(X, y, 'Learner', 'svm',...
    'Lambda', params.lambda,...
    'Solver', params.solver,...
    'Regularization', 'ridge');
    
% if isempty(params.C)
%     Mdl.fit = @(X,y) fitclinear(X,y,'Learner','svm','Lambda', 0,...
%         'Solver', params.solver, 'Regularization', 'ridge');
% else
%     Mdl.fit = @(X,y) fitcsvm(X,y,'BoxConstraint',params.C,'KernelFunction','linear');
% end

Mdl.pred = @(clf,newX) clf.predict(newX);
Mdl.score = @compute_modelMetrics;
end