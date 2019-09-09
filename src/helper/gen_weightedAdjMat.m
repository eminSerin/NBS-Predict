function [wAdjMat] = gen_weightedAdjMat(lenNodes,edgeIdx,edgeWeight)
% gen_weightedAdjMat generates n x n weighted sparse adjacency matrix
% consisting a number of edges are weighted. 
% Input: 
%   lenNodes    = Number of nodes. 
%   edgeIdx     = Indices of edges found in matrix. 
%   edgeWeight  = Weight of each edges in matrix. 
% Output:
%   wAdjMat     = Weighted sparse adjacency matrix. 
% Example: 
%   [wAdjMat] = gen_weightedAdjMat(NBSPredict.data.nodes,NBSPredict.data.edgeIdx,NBSPredict.results.svmC.meanEdgeWeight)
%
% Last edited by Emin Serin - 01.09.2019
%

%%
cEdgesIdx = find(edgeWeight);
weights = edgeWeight(cEdgesIdx);
wAdjMat = spalloc(lenNodes,lenNodes,numel(cEdgesIdx)*2);
wAdjMat(edgeIdx(cEdgesIdx)) = weights;
wAdjMat = wAdjMat + wAdjMat';
end