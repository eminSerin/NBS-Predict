function [MLhandle] = gen_MLhandles(modelName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gen_MLhandles returns function handle to initiate given machine learning
% model. Once you generate function handle, you can initiate machine
% learning model with parameters you define.
%
% Arguments:
%   modelName: name of the given model.
%       Classification:
%           'svmC':             Support Vector Machine Classification
%           'lda':              Linear Discriminant Analysis
%           'LogReg':           Logistic Regression
%       Regression:
%           'svmR':             Support Vector Machine Regression
%           'LinReg':           Linear Regression
%
% Output:
%     MLhandles = Function handle to initiate fit, predict and score
%     methods of selected machine learning model.
%
% Usage:
%     MLhandle = gen_MLhandles('svmC');
%
% This function requires at oldest MATLAB R2016b and Statistics and
% Machine Learning toolbox to run fully functional.
%
% Emin Serin - 10.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if only one input is provided. 
assert(nargin == 1, 'Inaccurate inputs given. Please check help section!');

% Check if model name given is correct (validatestring gives fuzzy matching). 
availableModels = {'svmC','LogReg','lda','svmR','LinReg'};
modelName = validatestring(modelName, availableModels, 'gen_MLhandles', 'modelName');

% Function handle. 
MLhandle = str2func(['run_',modelName]);
end



