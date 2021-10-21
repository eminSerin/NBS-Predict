function [edgeMat,nodes,edgeIdx] = shrinkMat(data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% shrinkMat extracts values of each edge in a correlation matrix and store
% in a array.
%
% Arguments:
%   data = Data matrix where correlation matrix from each participant
%   stored in. (nodes x nodes x subject)
%
% Output:
%   edgeMat = 2D matrix where each row is subjects given and each column is
%       edge values.
%   nodes = Number of nodes. 
%   edgeIdx = List of indices of edges in a correlation matrix. 
%
% Emin Serin - 29.07.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Check data size. 
dataShape = size(data); 
dataDim = length(dataShape);
assert(ismember(dataDim,[2,3]),'Data provided is not a 2D or 3D matrix!')
assert(dataShape(1) == dataShape(2),'Please provide correct form of data matrix. See help!')
if dataDim == 2
    subjects = 1;
else
    subjects = dataShape(3);
end
nodes = dataShape(1); 

edgeIdx = single(find(triu(ones(nodes,nodes),1))); % finds edge indices.
edgeMat = zeros(subjects,length(edgeIdx)); % pre-allocate.

if dataDim == 2
    edgeMat(1,:)=data(edgeIdx); % extract edge values.
else
    for i = 1:subjects
        cMat = data(:,:,i); % Select current matrix.
        edgeMat(i,:)=cMat(edgeIdx); % extract edge values.
    end
end

% Remove features where nonzero features are 10% or less.
ifAdjMat = (numel(unique(edgeMat))==2)& all(ismember(edgeMat,[0,1]));
if ~ifAdjMat
    SMR = 0.1; % Signal to missing value ratio (default = 0.1, at least %10 of nonzero)
    logicalEdgeMat = edgeMat;
    logicalEdgeMat((logicalEdgeMat ~= 0)&(~isnan(logicalEdgeMat))) = 1;
    SMRmask = mean(logicalEdgeMat,1) > SMR;
    edgeMat = edgeMat(:,SMRmask); % EdgeMat with non-zero edges.
    edgeIdx = edgeIdx(SMRmask);
end
end