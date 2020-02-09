 function [varargout] = compute_modelMetrics(y_true,y_pred,metrics)
% compute_modelMetrics evaulates classification or prediction performance
% of the model given and returns a performance score.
%
% Arguements:
%   y_true = True labels.
%   y_pred = Predicted labels.
%   metrics = Performance metrics:
%       Classification:
%           Binary or Multi-Class:
%               accuracy = Accuracy score.
%               sensitivity = Sensitivity score.
%               specificity = Specificity score.
%               precision = Precision score.
%               f1 = F1 score.
%           Only Binary: 
%               matthews_cc = Matthews Correlation Coefficient (MCC).
%               cohens_kappa = Cohen's Kappa score.
%               auc = Area Under the Receiver Operating Characteristic Curve (AUC ROC).
%       Regresssion:
%           correlation = Pearson correlation coefficient.
%           r_squared = R squared.
%           mse = Mean squared error.
%           rmse = Root Mean squared error regression loss.
%           explained_variance = Explained variance score.
%           mad = Median absolute deviation.
%
% Output:
%   score = Score of performance metrics.
%   Additional metrics provided if classification performed:
%       TP = True positive.
%       FP = False positive.
%       TN = True negative.
%       FN = False negative.
%
% Usage:
%   score = compute_modelMetrics(y_true,y_pred,metrics);
%   score = compute_modelMetrics(y_true,y_pred,'mse');
%   [score,TP,FP,TN,FN] = compute_modelMetrics(y_true,y_pred,'auc');
%
% Emin Serin, 2018. Berlin School of Mind and Brain
%
% Last edited by Emin Serin, 25.09.2019.
%

% Make sure that vectors are at least single for compatibility.
y_true = single(y_true);
y_pred = single(y_pred);

uniqueClasses = unique([y_true,y_pred]); % Find unique classes.
nClass = numel(uniqueClasses); % Number of unique classes.

multiClass = {'accuracy','specificity','sensitivity','precision',...
    'recall','f1'};
classification = {multiClass{:},'matthews_cc','cohens_kappa','auc'};

confMatMet = {};
if ismember(metrics,classification)
    % Compute confusion matrix.
    CM = confusionMatrix(y_true,y_pred);
    accuracy = @() numel(find(y_true==y_pred))/numel(y_true); % Accuracy
    if nClass > 1
        TP = CM.TP; FP = CM.FP; TN = CM.TN; FN = CM.FN;
        confMatMet = {CM.TP,CM.FP,CM.TN,CM.FN};
        % Classification metrics
        sensitivity = @() mean(TP ./ (TP + FN)); % Sensitivity
        specificity = @() mean(TN ./ (TN+FP)); % Specificity
        precision = @() mean(TP ./ (TP+FP)); % Precision
        recall = @() mean(TP./(TP+FN)); % Recall
        f1 = @() 2*((precision()*recall())/(precision()+recall())); % F1 Score
        matthews_cc = @() matthews_cc_score(TP,TN,FP,FN); % Matthew's Correlation Coefficient
        cohens_kappa = @() cohens_kappa_score(TP,TN,FP,FN); % Cohen's Kappa
        auc = @() roc_auc_score(TP,TN,FP,FN); % Area Under the Curve
    end
else
    % Regression metrics
    mse = @() sum((y_true-y_pred).^2)/numel(y_true);
    rmse = @() sqrt(mse()); % Root Means Squared Error
    correlation = @() corr(y_true,y_pred);
    r_squared = @() correlation()^2; % R Squared
    explained_variance = @() 1 - var(y_true-y_pred)/var(y_true); % Explained Variance
    mad = @() median(abs(y_true-y_pred)); % Median Absolute Difference
end
%% Compute 
% compute decision rates and performance metrics.
if nClass == 1
    score = accuracy();
else
    score =  eval([metrics,'()']);
end

% Check if nan
if isnan(score)
    score = 0;
end

varargout = {score,confMatMet{:}};
end

function [CM] = confusionMatrix(y_true,y_pred)
% Confusion matrix for classification. 
% Arguements: 
%   y_true = True labels.
%   y_pred = Predicted labels.
% Output:
%   CM structure including: 
%       confMat = Confusion matrix.
%       TP = True positives.
%       FP = False positives.
%       TN = True negatives.
%       FN = False negatives.
% Example:
%   CM = confusionMatrix(y_true,y_pred);
%
% Created by Emin Serin, 25.09.2019.
%

% Check if size of the predicted and true labels arrays are similar.  
assert(length(y_true) == length(y_pred),'Input vectors have different lengths');

uniqueClasses = unique([y_true,y_pred]); % find unique classes.
nClass = numel(uniqueClasses); % Number of unique classes.

% Create confusion matrix.
cMatrix = zeros(nClass);
for i=1:nClass
    for j=1:nClass
        cMatrix(i, j) = sum((y_true == uniqueClasses(i)) & (y_pred == uniqueClasses(j)));
    end
end

CM.confMat = cMatrix;
if nClass > 1
    if nClass == 2
        % If binomial classification
        TP=cMatrix(2,2); % True positive
        FN=cMatrix(2,1); % False negative
        FP=cMatrix(1,2); % False positive
        TN=cMatrix(1,1); % True negative
    elseif nClass >= 3
        % If multinomial classification
        TP=zeros(1,nClass);
        FN=zeros(1,nClass);
        FP=zeros(1,nClass);
        TN=zeros(1,nClass);
        for i=1:nClass
            TP(i)=cMatrix(i,i);
            FN(i)=sum(cMatrix(i,:))-cMatrix(i,i);
            FP(i)=sum(cMatrix(:,i))-cMatrix(i,i);
            TN(i)=sum(cMatrix(:))-TP(i)-FP(i)-FN(i);
        end
    end
    CM.TP = TP;
    CM.FP = FP;
    CM.TN = TN;
    CM.FN = FN;
else
    if uniqueClasses == 1
        CM.TP = cMatrix;
    else
        CM.TN = cMatrix;
    end
end
end

function [matthews] = matthews_cc_score(TP,TN,FP,FN)
% Computes Matthew's Correlation Coefficient. 
checkMultiClass(TP); % Check if no multilabel class provided.
matthews = ((TP*TN)-(FP*FN))/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN)); % Matthew's Correlation Coefficient
end

function [kappa] = cohens_kappa_score(TP,TN,FP,FN)
% Computes Cohen's Kappa. 
checkMultiClass(TP); % Check if no multilabel class provided.
po = (TP + TN) / (TP + TN + FP + FN);
pe = ((TP+FN)*(TP+FP) + (FP + TN)*(FN+TN))/(TP+FN+FP+TN)^2;
kappa = (po-pe)/(1-pe);
end

function [ROCAUC] = roc_auc_score(TP,TN,FP,FN)
% Area Under the Receiver Operating Characteristic Curve.
checkMultiClass(TP); % Check if no multilabel class provided.
TPR = TP / (TP + FN); % true positive rate
FPR = FP / (FP+TN); % false positive rate
X = [0;TPR;1]; % coordinates of TPR.
Y = [0;FPR;1]; % coordinates of FPR.
ROCAUC = trapz(Y,X); % apply trapezoid rule to find AUC.
end

function [] = checkMultiClass(x)
assert(numel(x) >= 1,'Multi-class data provided! You can only use binary labels.');
end
