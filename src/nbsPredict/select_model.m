function [Mdl] = select_model(modelName,varargin)
%   SELECT_MODEL returns required functions for given machine learning
%   algorithm in a structure.
%
%   Input:
%       modelName: name of the given model. Available classifiers are:
%           'elasticnetC':  ElasticNet logistic regression
%           'svmC':         Support Vector Machine Classifier
%           'decisionTree': Decision Trees
%           'randomForest': Random Forest Trees
%           'logitBoost':   LogitBoost boosting algorithm.
%           'adaBoost':     AdaBoost boosting algorihm for binary classification.
%           'naive':        NaiveBayes
%           'knn':          K-nearest neighbors
%           'lda':          Linear Discriminant Analysis
%           'logit':          Logistic Regression
%
%
%   Output:
%       Mdl: A structure which includes functions for train a classifier,
%       predict labels for new data points and score the performance of the classifier.
%
%   Usage:
%       Mdl = select_model('elasticnetC');
%       Mdl = select_model('adaBoost');
%
%   This function requires at oldest MATLAB R2016b and Statistics and
%   Machine Learning toolbox to run fully functional.
%
%   Emin Serin - Berlin School of Mind and Brain
%
% Input parser.
numvarargs = length(varargin);
if numvarargs > 1
    % maximum number of optional inputs.
    error('too many inputs.')
end

    function [y_pred] = pred_labels(probs)
        % converts probabilities of observations created by elasticNet to
        % labels.
        y_pred = ones(size(probs));
        y_pred(probs < 0.5) = 0;
    end

switch modelName
    case 'elasticNetC'
        % ElasticNet
        % https://en.wikipedia.org/wiki/Elastic_net_regularization
        optargs = {[1,0]}; % ridge regression by default.
        optargs(1:numvarargs) = varargin;
        Mdl.params = optargs{:}; % default parameter.
        Mdl.fit = @(X,y) glmnet(X,y,'binomial',struct('alpha', Mdl.params(1), 'nlambda', 1, 'lambda', Mdl.params(2)));
        Mdl.pred = @(clf,newX) pred_labels(glmnetPredict(clf,newX, clf.lambda,'response'));
        
    case 'elasticNetR'
         % ElasticNet
        % https://en.wikipedia.org/wiki/Elastic_net_regularization
        optargs = {[1,0]}; % ridge regression by default.
        optargs(1:numvarargs) = varargin;
        Mdl.params = optargs{:}; % default parameter.
        Mdl.fit = @(X,y) glmnet(X,y,'gaussian',struct('alpha', Mdl.params(1), 'nlambda', 1, 'lambda', Mdl.params(2)));
        Mdl.pred = @(clf,newX) glmnetPredict(clf,newX, clf.lambda,'response',0);
        
    case 'svmC'
        % Support vector machine
        % https://en.wikipedia.org/wiki/Support_vector_machine
        optargs = {1};
        optargs(1:numvarargs) = varargin;
        Mdl.params = optargs{:}; % default parameter.
        Mdl.fit = @(X,y) svmtrain(y,X,['-t 0 -s 0 -q -c ' num2str(Mdl.params)]);
        Mdl.pred = @(clf,newX) svmpredict(zeros(size(newX,1),1),newX,clf,'-q');
        
    case 'svmR'
        % Support vector machine regression
        Mdl.fit = @(X,y) fitrlinear(X,y,'Learner','svm');
        Mdl.pred = @predict; 
        
    case 'svmR'
        % Support Vector Machines Regressor
        optargs = {0.5};
        optargs(1:numvarargs) = varargin;
        Mdl.params = optargs{:}; % default parameter.
        Mdl.fit = @(X,y) svmtrain(y,X,['-t 0 -s 4 -q -n ' num2str(Mdl.params)]);
        Mdl.pred = @(clf,newX) svmpredict(zeros(size(newX,1),1),newX,clf,'-q');
        
    case 'decisionTree'
        % Decision trees
        % https://en.wikipedia.org/wiki/Decision_tree
        optargs = {1};
        optargs(1:numvarargs) = varargin;
        Mdl.params = optargs{:}; % default parameter.
        Mdl.fit = @(X,y) fitctree(X,y,'MinLeafSize',Mdl.params);
        Mdl.pred = @predict;
        
    case 'decisionTreeR'
        % Decision tree regressor
        %
        optargs = {1};
        optargs(1:numvarargs) = varargin;
        Mdl.params = optargs{:}; % default parameter.
        Mdl.fit = @(X,y) fitrtree(X,y,'MinLeafSize',Mdl.params);
        Mdl.pred = @predict;
        
    case 'logit'
        % Logistic regression
        % https://en.wikipedia.org/wiki/Logistic_regression
        Mdl.fit = @(X,y) glmfit(X,y,'binomial','logit');
        Mdl.pred = @(clf,newX) pred_labels(glmval(clf,newX,'logit'));
        
    case 'linearR'
        % Linear regression
        Mdl.fit = @(X,y) fitrlinear(X,y,'Learner','leastsquares');
        Mdl.pred = @predict; 
        
    case 'randomForest'
        % Random forest
        % https://en.wikipedia.org/wiki/Random_forest
        Mdl.fit = @(X,y) fitcensemble(X,y,'Method','bag');
        Mdl.pred = @predict;
        
    case 'logitBoost'
        % LogitBoost boosting algorithm
        % https://en.wikipedia.org/wiki/LogitBoost
        Mdl.fit = @(X,y) fitcensemble(X,y,'Method','LogitBoost');
        Mdl.pred = @predict;
        
    case 'adaBoost'
        % AdaBoost boosting algorithm.
        % https://en.wikipedia.org/wiki/AdaBoost
        Mdl.fit = @(X,y) fitcensemble(X,y,'Method','AdaBoostM1');
        Mdl.pred = @predict;
        
    case 'naive'
        % NaiveBayes
        % https://en.wikipedia.org/wiki/Naive_Bayes_classifier
        Mdl.fit = @fitcnb;
        Mdl.pred = @predict;
        
    case 'knn'
        % K-nearest neighbors
        % https://en.wikipedia.org/wiki/K-nearest_neighbors_algorithm
        optargs = {1};
        optargs(1:numvarargs) = varargin;
        Mdl.params = optargs{:}; % default parameter.
        Mdl.fit = @(X,y) fitcknn(X,y,'NumNeighbors',Mdl.params);
        Mdl.pred = @predict;
        
    case 'lda'
        % Linear Discriminant Analysis
        % https://en.wikipedia.org/wiki/Linear_discriminant_analysis
        optargs = {[0,1]};
        optargs(1:numvarargs) = varargin;
        Mdl.params = optargs{:}; % default parameter.
        Mdl.fit = @(X,y) fitcdiscr(X,y,'Delta',Mdl.params(1),'Gamma',Mdl.params(2));
        Mdl.pred = @predict;
        
        
end
Mdl.score = @compute_modelMetrics;

end
