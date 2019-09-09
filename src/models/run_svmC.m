function [Mdl] = run_svmC(params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_svmC returns Mdl structure including function handles of fit,
% predict and score functions for support vector machine classification. 
%
% Optional arguement: 
%   params: Structure including following hyperparameters:
%       C: C parameter (default = 1). 
% 
% Output: 
%   Mdl: Structure that includes fit, predict and score function handles. 
%
% Reference:
%   https://en.wikipedia.org/wiki/Support_vector_machine
%
% Emin Serin - 10.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters.
defaultParams.C = 1;

if nargin < 1 || isempty(params)
    % Create struct if no provided.
    params = struct;
end
% Validate hyperparameter provided (if not, return default hyperparameters)
params = check_MLparams(params,defaultParams);

% Function handles.
Mdl.fit = @(X,y) svmtrain(y,X,['-t 0 -s 0 -q -c ' num2str(getfieldi(params,'c'))]);
Mdl.pred = @(clf,newX) svmpredict(zeros(size(newX,1),1),newX,clf,'-q');
Mdl.score = @compute_modelMetrics;
end