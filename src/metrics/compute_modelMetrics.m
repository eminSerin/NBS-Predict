function [score] = compute_modelMetrics(y_true,y_pred,metrics)
%COMPUTE_MODELMETRICS evaulates classification or prediction performance of
% the model given. It requires Statistics and Machine Learning toolbox.
%
%   It provides for classification problems:
% - Accuracy score,
% - Sensitivity score,
% - Specificity score
% - Precision score
% - F1 score
% - Matthews Correlation Coefficient (MCC)
% - Cohen's Kappa score
% - Area Under the Receiver Operating Characteristic Curve (AUC ROC).
%
%   For regression problems:
% - R squared
% - Root Mean squared error regression loss
% - Explained variance score.
% - Correlation
% - Median absolute deviation
%
%   Usage:
%   score = compute_modelMetrics(y_true,y_pred,metrics)
%   e.g.
%   score = compute_modelMetrics(y_true,y_pred,'mse')
%
%   Emin Serin, 2018. Berlin School of Mind and Brain
%

%% Compute Performance metrics. 
% Check the input vectors have same length.
if length(y_true) ~= length(y_pred)
    error('Input vectors have different lengths')
end

uniqueClasses = unique([y_true,y_pred]); % find unique classes. 
nClass = numel(uniqueClasses); % Number of unique classes.

if nargin < 3
    % Default metrics. 
    if nClass < 4
        % Use roc_auc if classification.
        metrics = 'auc';
    else
        % Use mean squared error if regresson.
        metrics = 'rmse';
    end
end     
    
% compute decision rates and performance metrics.
if nClass == 1
    score = numel(find(y_true==y_pred))/numel(y_true);
%     disp('There is only one unique class. Therefore the result is accuracy score.')
elseif ~ismember(metrics,{'mad','rmse','r-squared','explained_variance'})
    % If classification. 
    
    % Create confusion matrix.
    cMatrix = zeros(nClass);
    for i=1:nClass
        for j=1:nClass
            cMatrix(i, j) = sum((y_true == uniqueClasses(i)) & (y_pred == uniqueClasses(j)));
        end
    end
    if nClass <= 2
        % If binomial classification
        TP=cMatrix(2,2); % True positive
        FN=cMatrix(2,1); % False negative
        FP=cMatrix(1,2); % False positive
        TN=cMatrix(1,1); % True negative
        switch metrics
            case 'accuracy'
                % Classification accuracy score.
                score = numel(find(y_true==y_pred))/numel(y_true);
            case 'sensitivity'
                % Sensitivity score
                score = mean(TP ./ (TP + FN));
            case 'specificity'
                % Specificity score
                score = mean(TN ./ (TN+FP));
            case 'precision'
                % Precision (a.k.a positive predictive value) score
                score =  mean(TP ./ (TP+FP));
            case 'recall'
                score = TP/(TP+FN);
            case 'f1'
                % F1 score
                precision = TP/(TP+FP);
                recall = TP/(TP+FN);
                score = 2*((precision*recall)/(precision+recall));
            case 'matthews_cc'
                % Matthews Correlation Coefficient (MCC)
                score = ((TP*TN)-(FP*FN))/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN));
            case 'cohens_kappa'
                % Cohen's Kappa score
                po = (TP + TN) / (TP + TN + FP + FN);
                pe = ((TP+FN)*(TP+FP) + (FP + TN)*(FN+TN))/(TP+FN+FP+TN)^2;
                score = (po-pe)/(1-pe);
            case 'auc'
                % Area Under the Receiver Operating Characteristic Curve.
                TPR = TP / (TP + FN); % true positive rate
                FPR = FP / (FP+TN); % false positive rate
                X = [0;TPR;1]; % coordinates of TPR. 
                Y = [0;FPR;1]; % coordinates of FPR. 
                score = trapz(Y,X); % apply trapezoid rule to find AUC. 
        end
    else
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
        
        switch metrics
            case 'accuracy'
                % Classification accuracy score.
                score = numel(find(y_true==y_pred))/numel(y_true);
            case 'sensitivity'
                % Sensitivity score
                score = mean(TP ./ (TP + FN));
            case 'specificity'
                % Specificity score
                score = mean(TN ./ (TN+FP));
            case 'precision'
                % Precision (a.k.a positive predictive value) score
                score =  mean(TP ./ (TP+FP));
            otherwise
                % If target is not binary.
                disp('Target is not binary.')      
        end
    end
else
    % If regression
    switch metrics
        case 'r-squared'
            % R squared
            score = corr(y_true,y_pred)^2;
        case 'rmse'
            % Root Mean squared error regression loss
            score = sqrt(sum((y_true-y_pred).^2)/numel(y_true));
        case 'explained_variance'
            % Explained variance score.
            score = 1 - var(y_true-y_pred)/var(y_true);
        case 'mad'
            % Median absolute deviation
            score = median(abs(y_true-y_pred));
    end
end

% Check if nan
if isnan(score)
    score = 0;
end
end


