function [g] = gen_BAnet(n,m0,m)
%   GEN_BANET scale-free network based on Barabasi-Albert model.
%   
%   Required inputs: 
%       n: Number of nodes in the network (default = 100). 
%       m0: Initial number of nodes in the network. (default = 5)
%       m: Number of edges through which a new node connects to existing nodes.
%           (default = 2)
%
%   Output:
%       g: The adjacency matrix constructed. 
%
%   Example usage: 
%       g = gen_SFnet();
%       g = gen_SFnet(1000);
%       g = gen_SFnet(500,5);
%       g = gen_SFnet(250,5,3);
%   
%   For more information on Barabasi - Albert model, please read:
%       Barabsi,A.-L. and Albert,R. (1999) Emergence of Scaling in Random
%           Networks. Science, 286, 509-512.
%
%   Emin Serin - Berlin School of Mind and Brain
%

%% Inputs
if nargin < 3 m = 2; end % Default m value.
if nargin < 2 m0 = 5; end % Default m0 value. 
if nargin < 1 n = 100; end % Default n value. 

% Check if m0 is greater than m (must be!)
if m0 < m
    error('m0 value must be greater than m.')
end

%% Initial network
g = single(zeros(n)); % pre-allocate whole graph.
g(1:m0,1:m0) = single(~eye(m0)); % connect all initial nodes with each other. 

% Edges
iN = 1:m0;
edges = [];
for i = 1: length(iN)
    edges = [edges;iN(i ~= iN)'];
end
edges = [edges; zeros(2*(n-m0)*m,1)];
eIdx = nnz(edges); % edges index. 

%% Preferential Attachment
% Add new nodes to the network. 
for i = m0+1:n
    targets = zeros(m,1);
    nIdx = 1;
    for k = 1:m
        e = edges(randi(eIdx,1));
        while ismember(e,targets)
            e = edges(randi(eIdx,1));
        end
        targets(k,1) = e; % add into target. 
        g(i,e) = 1; g(e,i) = 1; % edge with picked m nodes.
        edges(eIdx+nIdx) = e; edges(eIdx+nIdx+1) = i;  % add into edges vector.
        nIdx = nIdx + 2; 
    end
    eIdx = eIdx + m*2;
end

if ~issymmetric(g)
    error('Network is not symmetric. Please run the function again.');
end

end

