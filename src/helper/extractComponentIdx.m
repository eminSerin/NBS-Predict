function [extIdx] = extractComponentIdx(lenNodes,edgeIdx,cEdgesIdx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extractComponentIdx returns indices of features found in the biggest component.
% Such process takes place in two steps. First, features selected are used
% to constract a network. Then connected components are found in selected
% edges (i.e., features) using breadth-first search algorithm, and biggest
% component is selected. Finally, indices of edges found in the biggest
% component are returned as a output. Such process is used to make sure
% features are connected each other (please see discussion in Serin et al.,
% 2021)
%
% Arguments: 
%   lenNodes  = Number of nodes in provided adjacency matrices.
%   edgeIdx   = Indices of edges in provided adjacency matrices.     
%   cEdgesIdx = Indices of features selected. 
%
% Output:
%   extIdx = Indices of features (or edges) found in the biggest component.
%
% Reference:
%   https://en.wikipedia.org/wiki/Breadth-first_search
%   Serin, Emin, et al. "NBS-Predict: A Prediction-based Extension of 
%       the Network-based Statistic." NeuroImage (2021): 118625.
%
% Emin Serin - 02.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
assert(nargin==3, 'Incorrect number of input provided! Please check help section!')

% Get components.
% TODO: If two or more component with same size.
adj = spalloc(lenNodes,lenNodes,numel(cEdgesIdx)*2);
adj(edgeIdx(cEdgesIdx)) = 1;
adj = adj + adj';
[comp,compSz]=get_components(adj); % components and their sizes.
[~, mCompIdx] = max(compSz); % value and index of biggest component.

% Extract values of components.
adj(:,~(mCompIdx == comp)) = 0; % set 0 to non-component nodes.
compEdgeIdx = find(triu(adj));
[~,extIdx] = ismember(compEdgeIdx,edgeIdx); % find indexes of edges to be extracted
%     midAdj = reshape(midAdj,nCand,numel(testStats));
%     midAdj(iter,extIdx') = true;
end