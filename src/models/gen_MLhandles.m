function [MLhandle] = gen_MLhandles(modelName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gen_MLhandles returns function handle to initiate given machine learning
% model. Once you generate function handle, you can initiate machine
% learning model with parameters you define.
%
% Arguements:
%   modelName: name of the given model.
%       Classification:
%           'svmC':             Support Vector Machine Classification
%           'decisionTreeC':    Decision Tree Classification 
%           'lda':              Linear Discriminant Analysis
%           'LogReg':           Logistic Regression
%           'ElasticNetC':      Elastic Net Classification
%           'LassoC':           Lasso Classification
%       Regression:
%           'svmR':             Support Vector Machine Regression
%           'decisionTreeR':    Decision Tree Regression
%           'LinReg':           Linear Regression
%           'ElasticNetR':      Elastic Net Regression
%           'LassoR':           Lasso Regression
%
%   Output:
%       MLhandles = Function handle to initiate fit, predict and score
%       methods of selected machine learning model.
%
%   Usage:
%       MLhandle = gen_MLhandles('svmC');
%
%   This function requires at oldest MATLAB R2016b and Statistics and
%   Machine Learning toolbox to run fully functional.
%
% Emin Serin - 10.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if only one input is provided. 
assert(nargin == 1, 'Inaccurate inputs given. Please check help section!');

% Check if model name given is correct. 
availableModels = {'svmC','decisionTreeC','LogReg','lda','ElasticNetC',...
    'LassoC','decisionTreeR','svmR','LinReg','ElasticNetR','LassoR'};
assert(ismember(modelName,availableModels),...
    'Model name is incorrect! Please check help section!')

% Function handle. 
MLhandle= str2func(['run_',modelName]);
end



