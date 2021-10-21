function [varargout] = compute_modelMetrics(y_true,y_pred,metrics)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute_modelMetrics evaulates classification or prediction performance
% of the model given and returns a performance score.
%
% Arguments:
%   y_true = True labels.
%   y_pred = Predicted labels.
%   metrics = Performance metrics:
%       Classification:
%           Binary or Multi-Class:
%               confusionMatrix = Confusion Matrix.
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
% Example:
%   score = compute_modelMetrics(y_true,y_pred,metrics);
%   score = compute_modelMetrics(y_true,y_pred,'mse');
%   [score,TP,FP,TN,FN] = compute_modelMetrics(y_true,y_pred,'auc');
%
% Emin Serin, 2018. Berlin School of Mind and Brain
%
% Last edited by Emin Serin, 03.07.2020.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Make sure that vectors are at least single for compatibility.
y_true = single(y_true);
y_pred = single(y_pred);

uniqueClasses = unique([y_true,y_pred]); % Find unique classes.
nClass = numel(uniqueClasses); % Number of unique classes.

% Compute
if nClass == 1
    if strcmpi(metrics,'accuracy')
        score = accuracy(y_true,y_pred);
    else
        score = nan; 
    end 
else
    score =  feval(metrics,y_true,y_pred);
end

varargout = {score};
end

%% CLASSIFICATION
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

function [score] = accuracy(y_true,y_pred)
% Accuracy
score = nnz(y_true==y_pred)/numel(y_true); % Accuracy
end

function [score] = balanced_accuracy(y_true,y_pred)
% Balanced Accuracy
sensitivityScore = sensitivity(y_true,y_pred);
specificityScore = specificity(y_true,y_pred);
score = (sensitivityScore+specificityScore)/2;
end

function [score] = matthews_cc(y_true,y_pred)
% Computes Matthew's Correlation Coefficient.
CM = confusionMatrix(y_true,y_pred);
TP = CM.TP; FP = CM.FP; TN = CM.TN; FN = CM.FN;
checkMultiClass(TP); % Check if no multilabel class provided.
score = ((TP*TN)-(FP*FN))/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN)); % Matthew's Correlation Coefficient
end

function [score] = cohens_kappa(y_true,y_pred)
% Computes Cohen's Kappa.
CM = confusionMatrix(y_true,y_pred);
TP = CM.TP; FP = CM.FP; TN = CM.TN; FN = CM.FN;
checkMultiClass(TP); % Check if no multilabel class provided.
po = (TP + TN) / (TP + TN + FP + FN);
pe = ((TP+FN)*(TP+FP) + (FP + TN)*(FN+TN))/(TP+FN+FP+TN)^2;
score = (po-pe)/(1-pe);
end

function [score] = auc(y_true,y_pred)
% Area Under the Receiver Operating Characteristic Curve.
CM = confusionMatrix(y_true,y_pred);
TP = CM.TP; FP = CM.FP; TN = CM.TN; FN = CM.FN;
checkMultiClass(TP); % Check if no multilabel class provided.
TPR = TP / (TP + FN); % true positive rate
FPR = FP / (FP+TN); % false positive rate
X = [0;TPR;1]; % coordinates of TPR.
Y = [0;FPR;1]; % coordinates of FPR.
score = trapz(Y,X); % apply trapezoid rule to find AUC.
end

function [score] = sensitivity(y_true,y_pred)
% Sensitivity
CM = confusionMatrix(y_true,y_pred);
TP = CM.TP; FN = CM.FN;
score = mean(TP ./ (TP + FN)); % Sensitivity
end

function [score] = specificity(y_true,y_pred)
% Specificity
CM = confusionMatrix(y_true,y_pred);
FP = CM.FP; TN = CM.TN;
score = mean(TN ./ (TN+FP)); % Specificity
end

function [score] = precision(y_true,y_pred)
% Precision
CM = confusionMatrix(y_true,y_pred);
FP = CM.FP; TP = CM.TP;
score = mean(TP ./ (TP+FP)); % Specificity
end

function [score] = recall(y_true,y_pred)
% Recall
CM = confusionMatrix(y_true,y_pred);
TP = CM.TP; FN = CM.FN;
score =  mean(TP./(TP+FN)); % Recall
end

function [score] = f1(y_true,y_pred)
% F1 Score
precisionScore = precision(y_true,y_pred);
recallScore = recall(y_true,y_pred);
score = 2*((precisionScore()*recallScore())/(precisionScore()+recallScore())); % F1 Score
end

%% REGRESSION
function [score] = mse(y_true,y_pred)
% Mean Squared Error
score = sum((y_true-y_pred).^2)/numel(y_true);
end

function [score] = rmse(y_true,y_pred)
% Root Mean Squared Error
score = sqrt(mse(y_true,y_pred));
end

function [score] = correlation(y_true,y_pred)
% Pearson Correlation Coefficient
score = corr(y_true,y_pred);
end

function [score] = explained_variance(y_true,y_pred)
% Explained Variance
score = 1 - var(y_true-y_pred)/var(y_true);
end

function [score,bestScore] = mad(y_true,y_pred)
% Median Absolute Difference
score = median(abs(y_true-y_pred));
end

function [score] = r_squared(y_true,y_pred)
% R Square
numerator = sum((y_true - y_pred).^2);
denominator = sum((y_true - mean(y_true)).^2);
score = nanmean(1 - (numerator/denominator));
end

%% Helper Function
function [] = checkMultiClass(x)
assert(numel(x) >= 1,'Multi-class data provided! You can only use binary labels.');
end
