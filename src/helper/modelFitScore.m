function [varargout] = modelFitScore(Mdl,trainTestData,metrics)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modelFitScore fits model on train data, test model performance on test
% data and return its performance score.
%
% Arguements: 
%   Mdl = Structure of model where function handlers of fit, prediction and
%       score locate. 
%   trainTestData = Structure in which test and train features and labels
%       locate.
%   metrics = Performance metric (e.g., accuracy, f1, auc). 
%
% Output:
%   score = Prediction score. 
%
% Emin Serin - 02.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clf = Mdl.fit(trainTestData.X_train,trainTestData.y_train); % fit
y_pred = Mdl.pred(clf,trainTestData.X_test); % predict
if ischar(metrics)
    metrics = {metrics};
end
nMetrics = numel(metrics);
varargout = cell(1,nMetrics);
for i = 1:nMetrics
    varargout{i} = Mdl.score(trainTestData.y_test,...
        y_pred,metrics{i}); % score
end
end