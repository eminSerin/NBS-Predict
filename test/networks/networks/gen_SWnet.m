function [g] = gen_SWnet(n,k,beta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gen_SWnet generates small-world network using Watts-Strogatz model.
% Ring lattice of n nodes with k-nearest neighbor is first created, and
% then nodes are rewired depending on rewiring probability. 
%
% Arguments: 
%     n: Number of nodes in the network (default = 100). 
%     k: k-nearest neightbors each node is connected. (default = 5)
%     beta: rewiring probability. (default = .05)
%
% Output:
%     g: The adjacency matrix constructed. 
%
% Example: 
%     g = gen_SWnet();
%     g = gen_SWnet(1000);
%     g = gen_SWnet(500,5);
%     g = gen_SWnet(250,5,.1);
%   
% For more information on Barabasi - Albert model, please read:
%     Watts, D. J., & Strogatz, S. H. (1998). Collective dynamics of
%         'Small-World' networks. Nature, 393(6684), 440.
%
% This code adapted SW algorithm written by Mathworks (The MathWorks Inc, 2015)
% published on
% https://www.mathworks.com/help/matlab/examples/build-watts-strogatz-small-world-graph-model.html
%
% Emin Serin - Berlin School of Mind and Brain
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inputs
if nargin < 3 beta = .05; end % Default beta value.
if nargin < 2 k = 5; end % Default k value. 
if nargin < 1 n = 100; end % Default n value. 
assert(k*2~=n,"k*2 must be lower than n");
%% Ring Lattice. 
% Each node is connected with k-nearest neighbour nodes which constructs
% a ring lattice. 
kNode = repelem((1:n)',1,k); % k-nodes. 
rL = mod(kNode + repmat(1:k,n,1)-1,n)+1; % nodes each node connected with. 

%% Rewiring. 
% Rewire each node with respect to rewiring probability. 
for i = 1: n
    ifRewire = rand(k, 1) < beta; % Rewire edges if rand value is lower than 
        %   beta (maximum k number of rewired edges.). 
    targetRandVals = rand(n, 1); % Assign uniform random values to each target nodes.  

    % Avoid self-wiring and wiring with nodes already wired.
    targetRandVals(vertcat(i , kNode(rL==i),rL(i, ~ifRewire)')) = 0;
    [~, idx] = sort(targetRandVals, 'descend'); % sort node values. 
    rL(i, ifRewire) = idx(1:nnz(ifRewire)); % rewire nodes if necessary.
end

g = graph(kNode,rL); % construct graph. 
g = full(g.adjacency);

end
