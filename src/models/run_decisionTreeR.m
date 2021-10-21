function [Mdl] = run_decisionTreeR(params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_decisionTreeR returns Mdl structure including function handles of fit,
% predict and score functions for decision tree regression. 
%
% Arguments: 
%   params: Structure including following hyperparameters:
%       MinLeafSize: MinLeafSize parameter. 
% 
% Output: 
%   Mdl: Structure that includes fit, predict and score function handles. 
%
% Reference:
%   https://en.wikipedia.org/wiki/Decision_tree
%
% Emin Serin - 10.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters.
defaultParams.MinLeafSize = 1;

if nargin < 1 || isempty(params)
    % Create struct if no provided.
    params = struct;
end
% Validate hyperparameter provided (if not, return default hyperparameters)
params = check_MLparams(params,defaultParams);

% Function handles. 
Mdl.fit = @(X,y) fitrtree(X,y,'MinLeafSize',getfieldi(params,'MinLeafSize'));
Mdl.pred = @predict;
Mdl.score = @compute_modelMetrics;
end