function varargout = update_NBSPredictFigure(NBSPredict,wThresh)
%   UPDATE_NBSPREDICTFIGURE 
%   
%
%
%
%
%   Emin Serin - Berlin School of Mind and Brain
%
%% Update network with regards to chosen weight threshold. 
tmp = NBSPredict.Results.weightAdj >= wThresh;
tmp = tmp .* NBSPredict.Results.weightAdj;
[comp,compSz]=get_components(tmp); % components and their sizes.
[~, mCompIdx] = max(compSz); % value and index of biggest component.
mask = ~(mCompIdx == comp);

% Weighted Adjacency matrix.
tmp(mask,:) = 0;
tmp(:,mask) = 0;
varargout{1} = tmp; % Weighted adjacency matrix of connected component.

% Weighted connected graph.
tmp(mask,:) = [];
tmp(:,mask) = [];
varargout{2} = graph(tmp); % Weighted component. 

% Labels.
varargout{3} = NBSPredict.brainRegions.labels(~mask); % labels. 

end

