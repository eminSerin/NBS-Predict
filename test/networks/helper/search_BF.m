function [path,prev] = search_BF(g,startNode,maxIter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEARCH_BF finds connected components utilising the Breadth-First search
% algorithm.
%
% Arguments: 
%     g: Graph or adjacency matrix. 
%     startNode: Index of node with which the BFS starts. (default = 1)
%     maxIter: Maximum size of components. (default = size of network)
%
% Output:
%     path: Path visited by the search. 
%     prev: Previous node of each node in a searching path.   
%
% Example: 
%     [path,prev] = search_BF(g);
%     [path,prev] = search_BF(g,5);
%     [path,prev] = search_BF(g,5,30);
%   
% For more information on Breadth-first search, please read:
%     https://en.wikipedia.org/wiki/Breadth-first_search
%
% Emin Serin - Berlin School of Mind and Brain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inputs
if nargin < 1 help search_BF; end % Return help. 
if strcmpi(class(g),'graph') g = adjacency(g); end % Convert into adjacency matrix if graph. 
if nargin < 3 maxIter = size(g,1); end % Default maxIter number.
if nargin < 2 startNode = 1; end % Default starNode index. 

%%
iter = 1;
Q = startNode; % start queue with starting node. 
path = startNode; % add starting node in visited array. 
prev = zeros(maxIter-1,1); % previous nodes.
k = 1; % previous nodes index. 
while ~isempty(Q) && iter <= maxIter
    cNode = Q(1); Q(1) = []; % dequeue first element. 
    neighbors = find(g(cNode,:)); % find neigbors of current node. 
    for n = 1: length(neighbors) 
        % Loop over each neighbors of the current node. 
        if ~ismember(neighbors(n),Q) && ~ ismember(neighbors(n),path)
            if k <= maxIter-1
                prev(k) = cNode;
                k = k + 1;
            end
            % Enqueue if not already visited or not in queue already.
            Q = vertcat(Q,neighbors(n));
        end
    end
    
    if ~ismember(cNode,path)
        % Add into visited array. 
        path = vertcat(path,cNode);
    end
    iter = iter +1 ; 
end
prev = vertcat(NaN, prev); % Add NaN for the starting node. 


end

