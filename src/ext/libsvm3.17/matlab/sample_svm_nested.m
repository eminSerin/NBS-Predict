load fisheriris                              % fetch data from cases 1-7 here

A = species                                  %fetch label vector
B = meas         

[~,~,label_vector] = unique(A,'stable')      % convert label to numeric           

X = [label_vector, B]                        % SVM matrix non scaled, labels + predictors
N= size (X,1)                                % number of rows in design matrix 
K= 10  %ie. K-num                            % user selected fold #
XX = mod(1:N, K) +1                          % splitting ALL DATA

trainIndex = XX ~= 1                         % indexing TRAIN data 
testIndex = XX  == 1                         % indexing TEST data 
                                             
train_data = B(trainIndex, :)                % TRAIN data using TRAIN index 
test_data = B(testIndex,:)   

train_label = label_vector(trainIndex, :)
test_label = label_vector(testIndex, :)

trainData= sparse(train_data)
testData= sparse(test_data)

                          
                model = svmtrain(train_label, trainData, ...
                [' -g -b 1']) 
               [predicted_label, accuracy, prob_estimates] = ...
                   svmpredict(test_label, testData, model, '-b 1')   
              

     
