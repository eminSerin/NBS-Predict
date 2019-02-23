
%%% input => 2 label vectors (actual, predicted) (input to system) 
% kfold => k predicted labels (ie. 5, 10 etc) => output sum(metrics)/kfolds
% ie take nth column (#kfold) of predicted labels 
% case permutation: if perm. case (from permuation testing... for p values classifier)
% #width predicted labels/perm labels = #accuracy scores need to return

actual =    [1; 1; 1; 1; 1; 1; 1; 1; 2; 2; 2; 2; 2; 2; 2; 2; 3; 3; 3; 3; 3; 3; 3; 4; 4; 4; 4; 5; 5; 5; 5; 5; 5; 5];

a1 = [1; 2; 1; 2; 2; 1; 1; 1; 2; 3; 3; 3; 2; 2; 2; 2; 4; 4; 4; 3; 1; 3; 3; 4; 4; 4; 4; 5; 5; 5; 5; 5; 5; 5];
a2 = [1; 1; 1; 2; 2; 1; 1; 1; 2; 3; 3; 3; 2; 2; 2; 2; 4; 4; 4; 3; 3; 3; 3; 4; 4; 4; 4; 5; 5; 5; 5; 2; 5; 5];
a3 = [1; 1; 1; 2; 2; 1; 1; 1; 2; 3; 3; 3; 2; 2; 2; 2; 4; 4; 4; 3; 1; 3; 3; 4; 4; 4; 4; 5; 5; 2; 5; 5; 1; 5];
a4 = [1; 1; 2; 2; 2; 1; 1; 1; 2; 3; 3; 3; 2; 2; 2; 2; 4; 4; 4; 3; 3; 3; 2; 4; 4; 4; 4; 5; 5; 5; 5; 2; 5; 5];
a5 = [1; 1; 2; 2; 2; 1; 1; 1; 2; 3; 3; 3; 2; 2; 2; 1; 4; 4; 4; 3; 3; 3; 3; 4; 4; 4; 4; 5; 5; 5; 4; 5; 5; 5];
a6 = [1; 2; 1; 2; 2; 1; 1; 1; 2; 3; 3; 3; 2; 2; 2; 2; 4; 4; 4; 3; 3; 3; 3; 4; 4; 4; 4; 5; 5; 5; 5; 5; 5; 5];
a7 = [1; 1; 1; 2; 2; 3; 1; 4; 2; 3; 3; 3; 2; 2; 2; 2; 4; 4; 4; 3; 3; 3; 3; 4; 4; 4; 4; 5; 5; 5; 5; 5; 5; 5];
a8 = [1; 1; 1; 2; 2; 1; 1; 1; 2; 4; 3; 3; 2; 2; 2; 2; 4; 4; 4; 3; 3; 3; 3; 4; 4; 4; 4; 5; 5; 5; 5; 5; 5; 5];
a9 = [1; 1; 1; 2; 2; 1; 1; 1; 2; 3; 3; 3; 2; 2; 2; 2; 4; 4; 4; 3; 3; 3; 3; 4; 4; 4; 4; 5; 5; 3; 5; 3; 5; 5]
predicted = [a1 a2 a3 a4 a5 a6 a7 a8 a9];

% assuming imported labels (for k fold outer) are length x kfold double
% k fold = as many predicted labels as k folds, take TOTAL 

pred2 = actual(randperm(size(actual,1)),:)   
%for testing (ie whether its permutation predicted label 
%if permuted, permute 100 times, dimension = 100x k fold x length 

nclasses= numel(unique(actual));                                            %%determine class problem
length = numel(actual)
[a itrs] = size(predicted)

%% code from Er.Abbas Manthiri S confusionmat (File Exchange) 
%%%% as many c_matrices as k folds #
[c_matrix]= confusionmat(actual, predicted(:,1))
CC = c_matrix
for i = 1:itrs
[c_matrix]= confusionmat(actual, predicted(:,i))
CC = c_matrix + CC
end 


%permuted for nperms 

%% from c-matrix ()                 
%%%% per class calculations
for i= 1: nclasses                                                %ie. 3
TP = c_matrix(i,i)  ;   
FP = sum (c_matrix(:, i)) - TP;
FN = sum (c_matrix(i, :)) - TP;
TN = sum(sum (c_matrix))- (sum (c_matrix(i, :)) + sum (c_matrix(:, i))) + TP;
TP_v(i) =[TP];
TN_v(i) =[TN];
FN_v(i) =[FN];
FP_v(i) =[FP];
end 

%% balanced (ie per class metrics calculated)    %can be made into function
%%%% accuracy
for i= 1: nclasses;
acc = (TP_v(i)+TN_v(i))/(TP_v(i)+TN_v(i)+FP_v(i)+FN_v(i)) *100;
bal_acc_v(i) = [acc]                                                            
end
%%%%% error 
bal_err_v = 100 - bal_acc_v
%%%% sensitivity
for i= 1: nclasses;
sens = TP_v(i)/(TP_v(i)+ FN_v(i)) *100;
bal_sens_v(i) = [sens]                                                            
end
%%%% specificity
for i= 1: nclasses;
spec = TN_v(i)/(FP_v(i)+ TN_v(i)) *100;
bal_spec_v(i) = [spec]                                                            
end
%%%% positive predictive value
for i= 1: nclasses;
ppv = TP_v(i)/(TP_v(i)+ FP_v(i)) *100;
bal_ppv_v(i) = [ppv]                                                            
end
%%%% negative predictive value
for i= 1: nclasses;
nvp = TN_v(i)/(TN_v(i)+ FN_v(i)) *100;
bal_nvp_v(i) = [nvp]                                                            
end

%% from c-matrix (overall metrics)                          
acc_overall = ((sum(TP_v) + sum(TN_v))/ (sum (TP_v)+ sum(TN_v) + sum(FP_v) +sum (FN_v)) ) *100
err_overall = 100 - acc_overall

%% means across k folds (for main classifier stats)
%%% because k folds, take MEAN at each fold (assumption: take mean AFTER metrics calculated for each fold
%%% as # instances can differ at each fold (and we want to be as correct as we can) 
% => no, this is not done, confusion matrix expressed in sums not means 


%%% AUC ROC, Confidence interval for these measures? (how?) 
(if binary) => OR make ROC curve with option of binary comparison (menu)

%%in results window => if user wants to look (per 2 classes... delete labels other classes, keep data only picked
%%would this be right (isnt it easier to select classes we want first?) 

%%%% feature selection 
%%do simple feature ranking first, then go from there... 
%%find a solid solution for feature ranking, but how? sci kit learn 
