function varargout = update_NBSPredictFigure(weightAdj,labels,wThresh)
% update_NBSPredictFigure returns thresholded adjacency matrix, graph of
% the biggest subgraph, applying weight threshold provided. It also provides
% labes for nodes found in network after thresholding as well as threshold
% mask. Arguements:
%   weightAdj   = Weighted adjacency matrix where edges are weighted. 
%   labels      = Cell array of labels for nodes. 
%   wTresh      = Threshold value.
%
% Output:
%   wAdj       = Thresholded weighted adjacency matrix.
%   G          = Thresholded subgraph graph. 
%   labels     = Labels for nodes found in the subgraph. 
%   mask       = Binary thresholding mask. 
%   
% Example: 
%   [wAdj] = update_NBSPredictFigure(weightAdj,labels,wThresh);
%   [wAdj,G] = update_NBSPredictFigure(weightAdj,labels,wThresh);
%   [wAdj,G,labels] = update_NBSPredictFigure(weightAdj,labels,wThresh);
%   [wAdj,G,labels,mask] = update_NBSPredictFigure(weightAdj,labels,wThresh);
%
% Last modified by Emin Serin, 02.09.2019.
%
% See also: view_NBSPredict

%% Update network with regards to chosen weight threshold. 
twAdj = weightAdj >= wThresh; % apply threshold to weighted matrix. 
twAdj = twAdj .* weightAdj;
[comp,compSz]=get_components(twAdj); % components and their sizes.
[~, mCompIdx] = max(compSz); % value and index of biggest component.
mask = ~(mCompIdx == comp);

% Weighted Adjacency matrix.
twAdj(mask,:) = 0;
twAdj(:,mask) = 0;
varargout{1} = twAdj; % Weighted adjacency matrix of connected component.

% Weighted connected graph.
twAdj(mask,:) = [];
twAdj(:,mask) = [];
varargout{2} = graph(twAdj); % Weighted component. 

% Labels.
varargout{3} = labels(~mask); % labels;

% Mask 
varargout{4} = mask;

end

