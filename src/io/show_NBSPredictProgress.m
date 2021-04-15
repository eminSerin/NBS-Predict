function [] = show_NBSPredictProgress(NBSPredict,iter,scores)
% show_NBSPredictProgress prints progress of NBS-Predict algorithm on
% MATLAB console.
% Input: 
%   NBSPredict: NBSPredict structure in which parameters found. 
%   iter = The current iteration number.
%       0   = It returns header. 
%       > 0 = It returns current CV score. 
%       -1  = It returns footer.     
%   scores: A score value (for parallel loop) or score matrix 
%       (for sequantial loop). 
%
% Example: 
%   totalRepCViter = 10;
%   parfor repCViter = 1: totalRepCViter
%       [outerCVscore,edgeWeight(:,repCViter)] = outerFold(NBSPredict);
%       repCVscore(repCViter) = outerCVscore;
%       show_NBSPredictProgress(NBSPredict,repCViter,outerCVscore)
%   end
%
% Last edited by Emin Serin, 05.09.2019
%

%%
verbose = NBSPredict.parameter.verbose;
ifParallel = NBSPredict.parameter.ifParallel;

if verbose == 1
    % Define dash.
    if iter == 0
        if NBSPredict.parameter.ifHyperOpt
            msg = ['\n\nESTIMATOR: %s\n','Searching Algorithm: %s\n',...
            'METRIC: %s\n','Number of Folds: %d\n',...
            'Number of Repetitions: %d\n'];
            fprintf(msg,...
                NBSPredict.parameter.model, NBSPredict.parameter.selMethod,...
                NBSPredict.parameter.metric, NBSPredict.parameter.kFold,...
                NBSPredict.parameter.repCViter);
        else
            msg = ['\n\nESTIMATOR: %s\n', 'METRIC: %s\n', ...
                'Number of Folds: %d\n', 'Number of Repetitions: %d\n'];
            fprintf(msg,...
                NBSPredict.parameter.model, NBSPredict.parameter.metric,...
                NBSPredict.parameter.kFold,NBSPredict.parameter.repCViter);
        end
    end
    
    % Prepare print function handles.
    if ifParallel
        dash = '-------------';
        printHeader = @() fprintf([dash,'\n','|   Score   |\n',dash,'\n']);
        printIter = @(scores) fprintf('|   %.3f   |\n',scores);
    else
        dash = '------------------------------------------------------';
        printHeader = @() fprintf([dash,'\n',...
            '| Repeated CV Iteration |   Score   | Moving Average |\n',dash,'\n']);
        printIter = @(scores) fprintf('|          %s           |   %.3f   |      %.3f     |\n',...
            num2str(iter,'%02d'),scores(iter),mean(scores(1:iter)));
    end
    
    % Print!.
    if iter > 0
        printIter(scores);
    elseif iter == 0
        printHeader();
    elseif iter == -1
        fprintf([dash,'\nMean CV score of %dx%d repeated nested CV: %.2f\n'],...
            NBSPredict.parameter.repCViter,NBSPredict.parameter.kFold,mean(scores));
    end
end