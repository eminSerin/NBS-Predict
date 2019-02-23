
%[ROC_plot, AUC_score] = function (classNames, nROC_Thresholds, actual_label, predicted_label)

% this function generates an ROC plot with (per class) ROC curves and the
% AUC underneath them (using trapz method).
%
% for non- discrite classifiers, TPR and FPR at nThresholds(user defined)
% are calculated.
%
% first step, if discrete classifier, get TPR, FPR (1) per each class
% (vectors), elseif non-discrete case (ie. probability distribution) 
% => get FPR, TRP  vector (for each class) 

%%% note: for integration (GraphVar) -> fit to window (GUI window INSIDE results viewer)

% import classNames, example... 
classNames = {'cat' 'dog' 'turtle'} 

% example scores per class (ie. assuming 10 thresholds)
% => put all FPR together, TPRs together (ie. nClasses x nROC_Thresholds)
FPR = [0.2, 0.23, 0.25, 0.29, 0.31, 0.51, 0.56, 0.59, 0.7, 0.9;
       0.2, 0.24, 0.25, 0.33, 0.38, 0.51, 0.56, 0.66, 0.72, 0.87;
       0.1, 0.33, 0.33, 0.35, 0.37, 0.39, 0.56, 0.59, 0.7, 0.9]
   
TPR = [0.5, 0.6, 0.7, 0.8, 0.8, 0.8, 0.8, 0.9, 0.91, 0.99;
       0.5, 0.6, 0.7, 0.8, 0.8, 0.8, 0.8, 0.9, 0.91, 0.99;
       0.2, 0.6, 0.7, 0.8, 0.8, 0.8, 0.8, 0.9, 0.91, 0.99]

% input n FPR and TRP vectors (of same length ie. 1x10 doubles)
% plot ROC curve for each class & calculate AUC (using trapezoid method)
for i = 1: length(classNames)
    x = [0 FPR(i,:) 1]
    y = [0 TPR(i,:) 1]
    plot (x,y, '-o')
    AUC(i)= [trapz(x, y)]
    hold on
end

xlim([0 1.05])
ylim([0 1.05])               % correct axis limits so plot allows border visual
plot ([0 1],[0 1], '--b')    % plot "chance level" line (ie. 50%) 

xlabel({''; ''; 'False Positive Rate (1- Specificity)'; ''; ''})
ylabel({'True Positive Rate (Sensitivity)'; ''; ''})
title({'Receiver operating characteristic (ROC)'; ''  })
                                
legendCell = cellstr(num2str(AUC', '%-d'))            %change precision for "legendCell"    


lgd  = legend( {legendCell{1:end}}, 'Location','southeast','Orientation','vertical')  
title(lgd,'Area Under Curve (AUC)')

% end                 end of function