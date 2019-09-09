function [Mdl] = run_lda(params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_lda returns Mdl structure including function handles of fit,
% predict and score functions for linear discriminant analysis. 
%
% Optional arguement:
%   params: Structure including following hyperparameters:
%       delta: Delta parameter (default = 0). 
%       gamma: Gamma parameter (default = 1).
% 
% Output: 
%   Mdl: Structure that includes fit, predict and score function handles. 
%
% Reference:
%   https://en.wikipedia.org/wiki/Linear_discriminant_analysis
%
% Emin Serin - 10.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters.
defaultParams.delta = 0; defaultParams.gamma = 1;

if nargin < 1 || isempty(params)
    % Create struct if no provided.
    params = struct;
end
% Validate hyperparameter provided (if not, return default hyperparameters)
params = check_MLparams(params,defaultParams);

% Function handles
Mdl.fit = @(X,y) fitcdiscr(X,y,'Delta',getfieldi(params,'delta'),...
    'Gamma',getfieldi(params,'gamma'));
Mdl.pred = @predict;
Mdl.score = @compute_modelMetrics;
end