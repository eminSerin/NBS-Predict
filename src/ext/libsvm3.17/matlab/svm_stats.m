%function svm_metrics (actual_label, predicted_label, perm_predicted_label, classNames)

%%%% inputs to the function from graphvar_svm
%%%% 1.actual label 
%%%% 2. predicted label (x kFolds)
%%%% 3. perm_predicted_label  (x nPerms) *if nPerm=>1
%%%% 4. classNames in cell array format
%%%% Note: dependency => confusionmat.m file (Abbas M, file exchange)

nclasses= numel(unique(actual));                                            %%determine class problem
length = numel(actual);
classNames = {'cat' 'dog' 'kitten' 'puppy' 'student'} %import

%% calculate confusion metrics 
function confusion_calc (actual_label, predicted_label)
% calculates metrics for main classifier, import these to evaluate
% classifier performance
[A B] = size(predicted);      

%% code from Er.Abbas Manthiri S confusionmat (File Exchange)              %% total confusion_mat
[c_matrix]= confusionmat(actual, predicted(:,1));
c_total = c_matrix;                                         
for i = 1:B
[c_matrix]= confusionmat(actual, predicted(:,i));      
c_total = c_matrix + c_total;
end 

%% from c-matrix                 
%%%% per class calculations
for i= 1: nclasses                                                         %ie. 3 classes
TP = c_total(i,i);   
FP = sum (c_total(:, i)) - TP;
FN = sum (c_total(i, :)) - TP;
TN = sum(sum (c_total))- (sum (c_total(i, :)) + sum (c_total(:, i))) + TP;
TP_v(i) =[TP];
TN_v(i) =[TN];
FN_v(i) =[FN];
FP_v(i) =[FP];
end 

%% balanced (ie per class metrics calculated)    %can be made into function
%%%% accuracy
for i= 1: nclasses;
acc = (TP_v(i)+TN_v(i))/(TP_v(i)+TN_v(i)+FP_v(i)+FN_v(i)) *100;
bal_acc_v(i) = [acc];                                                  
end
%%%%% error 
bal_err_v = 100 - bal_acc_v;
%%%% sensitivity
for i= 1: nclasses;
sens = TP_v(i)/(TP_v(i)+ FN_v(i)) *100;
bal_sens_v(i) = [sens];                                                         
end
%%%% specificity
for i= 1: nclasses;
spec = TN_v(i)/(FP_v(i)+ TN_v(i)) *100;
bal_spec_v(i) = [spec];                                                         
end
%%%% positive predictive value
for i= 1: nclasses;
ppv = TP_v(i)/(TP_v(i)+ FP_v(i)) *100;
bal_ppv_v(i) = [ppv];                                                          
end
%%%% negative predictive value
for i= 1: nclasses;
nvp = TN_v(i)/(TN_v(i)+ FN_v(i)) *100;
bal_nvp_v(i) = [nvp];                                                         
end

%% from c-matrix (overall metrics)                          
acc_overall = ((sum(TP_v) + sum(TN_v))/ (sum (TP_v)+ sum(TN_v) + sum(FP_v) +sum (FN_v)) ) *100;
err_overall = 100 - acc_overall;
sens_overall = sum(TP_v)/(sum((TP_v)+ sum(FN_v))) *100
spec_overall = sum(TN_v)/(sum(FP_v)+ sum(TN_v)) *100
ppv_overall = sum(TP_v)/(sum(TP_v)+ sum(FP_v)) *100
npv_overall = TN_v(i)/(TN_v(i)+ FN_v(i)) *100;

perclass_table = transpose([bal_sens_v; bal_spec_v; bal_acc_v; bal_err_v; bal_nvp_v; bal_ppv_v])
over_vect = [sens_overall spec_overall acc_overall err_overall npv_overall ppv_overall]
mets_table= [perclass_table; over_vect]

end 

%% confusion matrix (plot) 
function confusion_plot (c_total, classNames)
% plots confusion matrics with summed values across k-folds 

[A nclasses] = size(classNames);
image(c_total);  
colormap(flipud(gray));

textStrings = num2str(c_total(:),'%0.2f'); %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
[x,y] = meshgrid(1:nclasses); %# Create x and y coordinates for the strings
hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
                'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
textColors = repmat(c_total(:) > midValue,1,3);  %# Choose white or black for the
                                             %#   text color of the strings so
                                             %#   they can be easily seen over
                                             %#   the background color
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors
    
%end
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:nclasses,...               %# Change the axes tick marks
        'XTickLabel',{classNames{1:end}},...                                                                   % class as strings
        'YTick',1:nclasses,... 
        'YTickLabel',{classNames{1:end}},...
        'TickLength',[0 0]);
          
xlabel('Predicted Class')
ylabel('Actual Class')
title({'Confusion Matrix (Summed over Folds)' ; ''; ''})
end    

%% confusion metrics table (plot)
function confusion_metrics (mets_table, classNames) 
%plots per class as well as overall confusion metrics 

y_lab = [classNames 'OVERALL']

%# matrix
M = mets_table;
[r c] = size(M);

%# text location and labels
[xloc yloc] = meshgrid(1:c,1:r);
xloc = xloc(:); yloc = yloc(:);
str = strtrim(cellstr( num2str(M(:),'%0.3g') ))
str = strcat(str, '%')
yticklabels = cellstr( num2str((1:r)','M%s')) ;     

%# plot colored cells
mask = M>0.9;               %# or any other mask
h = imagesc(1:c, 1:r, ones(size(M)));
set(h, 'AlphaData',mask)
colormap(summer)            %# colormap([0 1 0])

set(gca,'xaxisLocation','top')
set(gca,'XTick',1:6,...                                                       %# Change the axes tick marks
        'XTickLabel',{'SENSITIVITY','SPECIFICITY','ACCURACY','ERROR','NVP','PPV'},...      %#  class labels strings
        'YTick', 1:r ,... 
        'YTickLabel',{y_lab{1:end}},...                               % import strings from classNames 
        'TickLength',[0 0]);
    
%# plot grid
xv1 = repmat((2:c)-0.5, [2 1]); xv1(end+1,:) = NaN;
xv2 = repmat([0.5;c+0.5;NaN], [1 r-1]);
yv1 = repmat([0.5;r+0.5;NaN], [1 c-1]);
yv2 = repmat((2:r)-0.5, [2 1]); yv2(end+1,:) = NaN;
line([xv1(:);xv2(:)], [yv1(:);yv2(:)], 'Color','k', 'HandleVisibility','off')

%# plot text
text(xloc, yloc, str, 'FontSize',10, 'HorizontalAlignment','center');
t = title({'Confusion matrix metrics (per class + overall)'; ''; ''});
set(t, 'FontSize', 15);
    
end

%% permutation metrics & plot 
function permutation_stats (perm_pred_label, actual_label, acc_overall)
% plots permutation distribution plot
%if perm_pred_label imported (if case Perm)
% nperms (ie. 100) from dimension of nperms x kfold xlabel_length

%predicted_perm = randi([1,5],100,34,10)  % sample perm_pred_label 
[A B C] = size(perm_pred_label)    % a=nPerms  b=label_length  c=KFolds 
nPerms = A
% repeat for each (ie. 100x) perm_pred_label

for ii= 1:nPerms
PP= squeeze(perm_pred_label(ii, :, :))
    
    [c_matrix]= confusionmat(actual, PP(:,1))               % total c_matrix across kfolds
    c_total = c_matrix
        for i = 1:C
        [c_matrix]= confusionmat(actual, PP(:,i))
         c_total = c_matrix + c_total
        end   

%%%% per class calculations
for ic= 1: nclasses                                                %ie. 3
TP = c_matrix(ic,ic)  ;   
FP = sum (c_matrix(:, ic)) - TP;
FN = sum (c_matrix(ic, :)) - TP;
TN = sum(sum (c_matrix))- (sum (c_matrix(ic, :)) + sum (c_matrix(:, ic))) + TP;
TP_v(ic) =[TP];
TN_v(ic) =[TN];
FN_v(ic) =[FN];
FP_v(ic) =[FP];
end 

%% only need overall accuracy score for histogram
acc_overall_perm = ((sum(TP_v) + sum(TN_v))/ (sum (TP_v)+ sum(TN_v) + sum(FP_v) +sum (FN_v)) ) *100
acc_overall_perm_v(ii) = [acc_overall_perm]                                 %permuted accuracy scores

end 

%% histogram plot for classifier performance assessment 

totals = [acc_overall_perm_v  acc_overall]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

%%%%% get p-value
difference = acc_overall - acc_overall_perm_v                            %%%% difference normal vs. permutation 
                                                                           
s=sign(difference)
i_pos=sum(s(:)==1)
i_neg=sum(s(:)==-1)

p_value = (1 + i_neg) /(1 + nPerms)                                 %%% p-value for classifier permutation 
correct_p_value_threshold = 0.05 * (1+ nPerms)                      %%% significance threshold (nth largest = boundery)

clf('reset')                                %clear figure, if previous

% Add title and axis labels
A = acc_overall_perm_v;                    % distribution (permutations)
B = acc_overall;                          % our classifier accuracy
h1 = histogram(A);
hold on
h2 = histogram(B);        

XL = get(gca, 'XLim');
YL = get(gca, 'YLim');
YL = YL(2)
% pvalue cap border (line)        
BC = max(totals)
BB = BC - correct_p_value_threshold      %max - corrected threshold
   
line([BB, BB],[0, 2*YL], 'Color', 'green') 
h = text(BB-1, YL, 'p value threshold');
set(h, 'rotation', 90)
% cperm_hance accuracy margin 
c_total = 100/nclasses
line([c_total, c_total],[0, 2*YL],'Color', 'red') 
h = text(c_total-1, YL, 'chance level/  luck');
set(h, 'rotation', 90)
%real classifier p value
DD = B
line([DD, DD],[0, 2*YL], 'Color', 'blue') 
pval= num2str(p_value)
h = text(DD-1, YL, sprintf('real classifier (p= %s)', pval));
set(h, 'rotation', 90)

xlim([0 100]) %since accuracy scores from 0 to 100
hold on
title({'Classifier performance (permutation distribution)'; ''})
xlabel('Accuracy score')
ylabel('Frequency')


end

%% ROC and AUC 
function ROC_plot (bal_sens_v, bal_spec_v, classNames)
%%% for the plot (user needs to select binary comparison) 
%%% ie class 1 vs class 2 etc. for n cases (this should be a select options
%%% in the results viewer when ROC plot is visible 
%%% NOTE> since only 1 score (overall accuracy) not necassary for SVM???
%%% NOTE> (user selection): plot multiple class at the same time? 
% at the moment just 1 datapoint... should we use across k fold metric?
%% NOTE> could use ROC to evaluate how each FEATURE separates classes?
% TPR, FPR for every classification threshold 
%classSelected = UI input(1 class at time) OR all at once? 

clf('reset')     
TPR = bal_sens_v/100
FPR = (100- bal_spec_v)/100

for i= 1:nclasses 
x = [0 FPR(i) 1] 
y = [0 TPR(i) 1] 
plot(x, y, '-o')
hold on 

xlim([0 1])
ylim([0 1])
xlabel({'False Positive Rate'; ''; ''})
ylabel({'True Positive Rate'; ''})
title({'Receiver operating characteristic (ROC)'; ''})
AUC(i) = [trapz(x, y)]

end
%legend
AUCC = cellstr(num2str(AUC))
str = strjoin(classNames)
str2 = strjoin(AUCC)
lgd  = legend (str, str2)
title(lgd,'AUC per class')

hold on 

end

