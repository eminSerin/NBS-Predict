
%% Core SVM classifier script 
%%%%% to be run after data pre-processing for cases 1-7...

%function [accuracy, pval] = graphvar_svm(predictors, labels, Fold_num, nCV_logical, nPermutations)

                                           % using fisheriris as sample data for now
load fisheriris 
                                                                             % fetch data from cases 1-7 here
A =  species     ;                                                               %fetch label vector
B =  meas     ;                                                                 %fetch predictors


PM = 1 ;  
nPermutations = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  OUTER LOOP  
%%% uses entire dataset
nCV_logical = 1                              % ie. user selection (nested or not)       
PL = 1 ;                                    % (shift for data collection)



%function [actual_label, predicted_label] main_classifier ()

[~,~,actual_label] = unique(A,'stable')  ;    % convert label to numeric           
X = [actual_label, B]   ;                     % SVM matrix non scaled, labels + predictors
N= size (X,1)         ;                       % number of rows in design matrix 
K= 10  %ie. Fold_num   ;                      % user selected fold #
XX = mod(1:N, K) +1     ;                     % splitting ALL DATA

nCV_logical = 1

for i= 1: K                                  % ie. here run 10 times
 
trainIndex = XX ~= i     ;                   % indexing TRAIN data 
testIndex = XX  == i     ;                   % indexing TEST data 

train_data = B(trainIndex, :)   ;             % TRAIN data using TRAIN index 
test_data = B(testIndex,:)    ;               % TEST data using TEST index 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INNER LOOP 
%%% uses TRAIN data at each "K" fold 

    if nCV_logical == 1 

    [a b]= size(train_data)  ;                       % fetch of rows in train 
    KK = 10             ;                         % # folds inner loop > do we only need 1 run of inner loop (per outer run?)
    XXX = mod(1:a, 5) +1    ;                         % splitting TRAIN data

        for ii= 1:KK        ;                         
        inner_trainIndex = XXX ~= 1    ;              % indexing INNER_TRAIN data 
        validationIndex = XXX  == 1    ;              % indexing VALIDATION data 

        inner_train_data = train_data(inner_trainIndex,:);                
        validation_data =  train_data (validationIndex,:) ; 
       
        INNER_TRAIN_SCALED = zscore(inner_train_data);   % scaling INNER_TRAIN DATA
        AVE_TR2= mean (inner_train_data)  ;              % mean INNER_TRAIN DATA
        STD_TR2= std(inner_train_data)    ;              % std dev. INNER_TRAIN DATA

        BBB = validation_data - AVE_TR2        ;               % scaling VALIDATION DATA
        VALIDATION_SCALED = bsxfun(@rdivide, BBB, STD_TR2);    
                         
        inner_train_label = actual_label(inner_trainIndex, :);    %fetch labels for INNER TRAIN
        validation_label = actual_label(validationIndex, :);      %fetch labels for VALIDATION

        inner_train_Data= sparse(INNER_TRAIN_SCALED);             %convert format 
        validationData= sparse  (VALIDATION_SCALED);
        
        
        %%%%%% Grid Search: 
        %%%%%% confirm we want these parameter ranges 
        C = [100 1000]   ;                        % c value
        G = [0.01 0.1]   ;                        % gamma-value
        
        %C = [0.01 0.1 0.2 1 10 100 1000]   ;                        % c value
        %G = [0.01 0.1 0.2 1 10 100 1000]   ;                        % gamma-value

        CL = length(C);
        GL = length(G);

            pp = 1 ;
            for ci = 1: CL   
                Ca = C(1,  ci)  ;    
                 
                for gi = 1:GL
                    Ga = G(1,  gi);
                
                %CAUTION: renamed "svmtrain" to "svmtrain2" to avoid conflict     
                model = svmtrain(inner_train_label, inner_train_Data, ...
               ['-s 0 -t 2 -c'  ' '  num2str(Ca) ' '  '-g' ' ' num2str(Ga) ' '  '-b 0 -q']) ;
                [predict_label, accuracy, prob_values]   =  ...
                svmpredict(validation_label, validationData, model, '-q') ;   
              
                inner_accuracy_score = accuracy(1);
                M(pp, 1) = [inner_accuracy_score] ;
                L(pp, 1) = [Ga] ;
                N(pp, 1) = [Ca];
                pp = pp + 1;
                
                end
                
            end         
        end          
              MM = [M, L, N] ;    %save best parameters 
              MMax = max(MM)  ;
              G_Best = MMax(2); 
              C_Best = MMax(3); 
       end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTER LOOP CONTINUED ...    

%%%%   alternative scaling (min/max) -----------
%%%  minimums = min(data, [], 1);
%%%  ranges = max(data, [], 1) - minimums;
%%%  data = (data - repmat(minimums, size(data, 1), 1)) ./ repmat(ranges, size(data, 1), 1);
%%%  test_data = (test_data - repmat(minimums, size(test_data, 1), 1)) ./ repmat...
%%% (ranges, size(test_data, 1), 1);

%%% (FURTHER TEST MIN MAX SCALING) 

TRAIN_SCALED = zscore (train_data);
AVE_TR= mean (train_data);
STD_TR= std(train_data);
  
BB = test_data -  AVE_TR;
TEST_SCALED = bsxfun(@rdivide, BB, STD_TR);
                         
%%%NOTE: for LIBSVM class labels must be numeric ie. 1,2,3....N 
train_label =  actual_label(trainIndex, :);
actual_label = actual_label(testIndex, :);

%%%convert FULL TO SPARSE matrix. note: LIBSVM works on sparse matrices only.
%%%do this step after preprocessing to avoid complications
trainData= sparse(TRAIN_SCALED);
testData= sparse(TEST_SCALED);

    if nCV_logical == 1                        % with optimised parameters
    
    model = svmtrain(train_label, trainData, ...
    ['-s 0 -t 0 -c'  ' '  num2str(C_Best) ' '  '-g' ' ' num2str(G_Best) ' '  '-b 1']);
    [predict_label, probability]   =  ...
    svmpredict(actual_label, testData, model) 

    elseif nCV_logical ~= 1                     % without optimised parameters
        
    model = svmtrain(train_label, trainData, '-s 0 -t 0 -b 0 -q') ;
    [predict_label]   =  ... 
    svmpredict(actual_label, testData, model, '-q');   

      
    end
    
end





%% Feature ranking (weights?)
function feat_ranks ()
%%% doesnt work the same  way in SVM as regression (!) 
%%% requires ie. filter method (fisher score) during model selection 
%%% OR determine from support vectors (ie. how well does feature seperate
%%% between 2 classes) _> straightforward for binary, for multiclass not so
%%% much, feature ranking in SVM for multiclass (NEEDS WORK). 
%%% RFE > recursive feature elimination? implement feature "pruning" +
%%% output of feature rank (to overall acc) as next step
%%%% extra plot > Feature weight vs. Ranked Features (decay curve)
end

