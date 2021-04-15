function [CPM_results] = test_CPM(NBSPredict)
% test_CPM gets structure from the test function originally written for
% NBSPredict and convert to a structure that can be used by CPM. This
% structure is then used by CPM and the outcome structure derived from CPM
% is converted back to one that can be used by simulation function
% originally written for NBSPredict.
%
% Arguments:
%   NBSPredict - Structure including data and parameters. NBSPredict
%       structure is prepared by NBSPredict GUI. However it could also be
%       provided by user to bypass the GUI (see MANUAL for details).
%
% Output:
%   CPM_results - Structure similar to NBSPredict and can be used by
%       simulation function.
%
% Last Edited by Emin Serin - 08.04.2021.
%
% See also: test_NBSPredict, sim_testNBSPredict
% 
%%
data.X = NBSPredict.data.X;
data.y = NBSPredict.data.y(:,2);

MLmodel = NBSPredict.parameter.MLmodels{:};

CPM = run_CPM(data,'thresh',NBSPredict.parameter.pVal,...
    'verbose',NBSPredict.parameter.verbose,...
    'learner',MLmodel,'repCVIter',NBSPredict.parameter.repCVIter,...
    'randomState',NBSPredict.parameter.randomState,...
    'metric',NBSPredict.parameter.metric,...
    'kFold',NBSPredict.parameter.kFold);
weights = CPM.results.negSelectedEdges + CPM.results.posSelectedEdges;
meanCVscore = mean([CPM.results.posMeanCVScore,CPM.results.negMeanCVScore]);

% Save parameters
CPM_results.parameter = CPM.parameter;
CPM_results.parameter.ifModelOpt = 0;
CPM_results.parameter.MLmodels = {CPM.parameter.learner};

% Save data
CPM_results.data.X = data.X;
CPM_results.data.y = NBSPredict.data.y;
CPM_results.data.edgeIdx = NBSPredict.data.edgeIdx;
CPM_results.data.contrastedEdges = NBSPredict.data.contrastedEdges;

% Scaled mean edge weight
totalFold = NBSPredict.parameter.repCVIter*NBSPredict.parameter.kFold;
scaler = MinMaxScaler([0,max(weights)]);
scaledMeanEdgeWeight = scaler.fit_transform(weights); % Min-max scaled mean weights
scaledMeanEdgeWeight = round(scaledMeanEdgeWeight,round(log10(totalFold))+1); % Tolarate minor difference. 

% Save results
CPM_results.results.(MLmodel).meanEdgeWeight = weights;
CPM_results.results.(MLmodel).scaledMeanEdgeWeight = scaledMeanEdgeWeight;
CPM_results.results.(MLmodel).meanRepCVscore = [CPM.results.posMeanCVScore,CPM.results.negMeanCVScore];
CPM_results.results.(MLmodel).overalCVscore = meanCVscore;
CPM_results.results.(MLmodel).posMeanCVScore = CPM.results.posMeanCVScore; 
CPM_results.results.(MLmodel).negMeanCVScore = CPM.results.negMeanCVScore;

end

