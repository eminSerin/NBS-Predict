function [CPM_results] = test_CPM(NBSPredict)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
% Last Edited by Emin Serin - 27.08.2022.
%
% See also: test_NBSPredict, sim_testNBSPredict
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Organize data.
data.X = NBSPredict.data.X;
data.y = NBSPredict.data.y(:,2);
if isfield(NBSPredict.data, 'confounds')
   data.confounds = NBSPredict.data.confounds; 
end

MLmodel = NBSPredict.parameter.MLmodels{:};

CPM = run_CPM(data,'thresh',NBSPredict.parameter.pVal,...
    'verbose',NBSPredict.parameter.verbose,...
    'learner',MLmodel,'repCViter',NBSPredict.parameter.repCViter,...
    'randSeed',NBSPredict.parameter.randSeed,...
    'metric',NBSPredict.parameter.metric,...
    'kFold',NBSPredict.parameter.kFold,...
    'ifPerm',NBSPredict.parameter.ifPerm,...
    'permIter', NBSPredict.parameter.permIter,...
    'numCores', NBSPredict.parameter.numCores);

% Save parameters
CPM_results.parameter = CPM.parameter;
CPM_results.parameter.ifModelOpt = 0;
CPM_results.parameter.MLmodels = {CPM.parameter.learner};

% Save data
CPM_results.data.X = data.X;
CPM_results.data.y = NBSPredict.data.y;
CPM_results.data.edgeIdx = NBSPredict.data.edgeIdx;

if isfield(NBSPredict.data, 'contrastedEdges')
    CPM_results.data.contrastedEdges = NBSPredict.data.contrastedEdges;
end

% Scaled mean edge weight
totalFold = NBSPredict.parameter.repCViter * NBSPredict.parameter.kFold;

% Save results
CPM_results.results.(MLmodel) = CPM.results; 
CPM_results.results.(MLmodel).posScaledWeights = ...
    scale_edgeWeights(CPM.results.posWeights, totalFold);
CPM_results.results.(MLmodel).negScaledWeights = ...
    scale_edgeWeights(CPM.results.negWeights, totalFold);
end

function [scaledWeights] = scale_edgeWeights(weights, totalFold)
% scales edge weights such that they distribute between 0 and 1. 
scaler = MinMaxScaler([0,max(weights)]);
scaledWeights = scaler.fit_transform(weights); % Min-max scaled mean weights
scaledWeights = round(scaledWeights,round(log10(totalFold))+1); % Tolarate minor difference. 
end
