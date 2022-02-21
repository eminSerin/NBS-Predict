function [varargout] = gen_synthData(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gen_synthData generates synthetic network data and embed contrast of
% interest in a given number of edges. Using this function scale-free,
% small-world and random networks can be generated. It returns a
% structure including network matrices, design matrix and list of indices
% of contrasted edges. 
%
% Arguments: 
%     nNodes: Number of nodes in the network. (default = 100)
%     nEdges: Number of edges with ground truth. (default = 10)
%     formNetwork: Whether the edges with ground truth form network
%         (default = True).
%     cnr: Contrast-to-noise ratio. (default = 0.5)
%     n: The number of control-contrast network couples generated.
%         (default = 25, i.e. sample size of 50 observations).
%     ifRegression: Generates data for regression problem. (default = 0)
%     noise: Noise level in the target variable. Only available in 
%         regression problems (default = 0.0). 
%     ifSave: Whether save the data to .mat file or not 
%         (default = 0).
%     network: Type of network (default = 'scalefree')
%         Scale-free network:
%             m: Number of edges through which a new node connects to
%                existing nodes (default = 2).
%             m0: Initial number of nodes in the network. (default = 5)
%         Small-world network:
%             k: k-nearest neightbors each node is connected (default = 2). 
%             beta: rewiring probability. (default = .05)
%         Random network. 
%     randomState: Controls the randomness. Pass an integer value for
%         reproducible results or 'shuffle' to randomize (default = 42).  
%       
% Output:
%     synthData: A data structure which includes control and contrast
%         data, design matrix and indices of contrast links
%
% Example: 
%     [data] = gen_synthData();
%     [data] = gen_synthData('network','smallworld');
%     [data] = gen_synthData('network','smallworld',...
%         'nNodes',500);
%   
% References:
%     Barabsi,A.-L. and Albert,R. (1999) Emergence of Scaling in Random
%         Networks. Science, 286, 509-512.
%     Watts, D. J., & Strogatz, S. H. (1998). Collective dynamics of
%         'Small-World' networks. Nature, 393(6684), 440.
%     Zalesky, A., Fornito, A., & Bullmore, E. T. (2010). Network-based
%         statistic: identifying differences in brain networks.
%         Neuroimage, 53(4), 1197-1207.
%
% Last edited by Emin Serin, 21.02.2022
%
% See also: test_NBSPredict, gen_BAnet, gen_SWnet, search_BF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set default parameters and parse input

% Default parameters.
defaultVals.nNodes = 100; defaultVals.nEdges= 10; 
defaultVals.formNetwork = true;
defaultVals.cnr = 0.5; defaultVals.network = 'scalefree';
defaultVals.m = 2; defaultVals.m0 = 5;
defaultVals.k = 2; defaultVals.beta = .05;
defaultVals.n = 25; defaultVals.ifSave = 0;
defaultVals.noise = 0.0; defaultVals.ifRegression = 0;
defaultVals.randomState = false;
networkOptions = {'scalefree','smallworld','random'};


% Input Parser
validationNumeric = @(x) isnumeric(x);
validationNetwork = @(x) any(validatestring(x,networkOptions));
p = inputParser();
p.PartialMatching = 0; % deactivate partial matching. 
addParameter(p,'network',defaultVals.network,validationNetwork);
addParameter(p,'nNodes',defaultVals.nNodes,validationNumeric);
addParameter(p,'cnr',defaultVals.cnr,validationNumeric);
addParameter(p,'m',defaultVals.m,validationNumeric);
addParameter(p,'m0',defaultVals.m0,validationNumeric);
addParameter(p,'k',defaultVals.m0,validationNumeric);
addParameter(p,'beta',defaultVals.beta,validationNumeric);
addParameter(p,'nEdges',defaultVals.nEdges,validationNumeric);
addParameter(p,'formNetwork',defaultVals.nEdges);
addParameter(p,'n',defaultVals.n,validationNumeric);
addParameter(p,'ifSave',defaultVals.ifSave,validationNumeric);
addParameter(p,'noise',defaultVals.noise,validationNumeric);
addParameter(p,'ifRegression',defaultVals.ifRegression,validationNumeric);
addParameter(p,'randomState',defaultVals.randomState);


% Parse inputs. 
parse(p,varargin{:});

network = p.Results.network;
ifSave = p.Results.ifSave;
nNodes = p.Results.nNodes;

% Create output directory
if ifSave
    outputDir = [pwd filesep 'SynthData' filesep];
    if ~exist(outputDir,7)
        mkdir(outputDir)
    end
end

if p.Results.randomState
    if p.Results.randomState == -1
        rng('shuffle');
    else
        rng(p.Results.randomState);
    end
end
%% Generate networks.
% Check network generation method.
if strcmpi(network,'scalefree')
    g = gen_BAnet(nNodes,p.Results.m0,p.Results.m); % generate scale-free network.
elseif strcmpi(network,'smallworld')
    g = gen_SWnet(nNodes,p.Results.k,p.Results.beta); % generates small-world network.
elseif strcmpi(network,'random')
    g = normrnd(0,1,nNodes); % generates normally distributed random network. 
end

if ~p.Results.ifRegression
    [data] = make_classification(g,p.Results.n,p.Results.cnr,...
        p.Results.nEdges,nNodes,p.Results.formNetwork);
else
    [data] = make_regression(g,p.Results.n,p.Results.noise,...
        p.Results.nEdges,nNodes,p.Results.formNetwork);
end

if ifSave
    % Save design matrix.
    save([outputDir 'SynthData_',date,'.mat'],'data');
end

varargout{:} = data;
end

function [data] = make_classification(g,n,cnr,nEdges,nNodes,formNetwork)
% make_classification synthetic generates network data for classification 
% problems using given graph network. 
% Arguments: 
%       g = graph structure.  
%   Please check help section of the main function for other arguements. 
%
%   Output:
%       data: A data structure which includes control and contrast
%           data, design matrix and indices of contrast links
%       contIdxAdj = Vector containing indices of contrasted edges. 
%

% Find indices for contrasted edges. 
edgeIdx = find(triu(g));
nTotalEdges = numel(edgeIdx);
if formNetwork
    [~,~,contrastEdgeIdx] = find_contrastEdges(g,nEdges,nNodes);
    [~,cEdgeLoc] = ismember(contrastEdgeIdx,edgeIdx);
else
    cEdgeLoc = randperm(nTotalEdges,nEdges);
    contrastEdgeIdx = edgeIdx(cEdgeLoc);
end

% Embed contrast-of-interest. 
edgeWeight = randn(nTotalEdges,n*2); % Edges. 
contrast = randn(nEdges,n) + cnr; % generate contrast.
edgeWeight(cEdgeLoc,n+1:end) = contrast;   

% Embed data to networks. 
[synthNet] = embed_dataToNetwork(g,n,edgeWeight,edgeIdx);

% Prepare design matrix for classification problem. 
designMat = (1:n*2) ./ (n*2);
designMat = designMat' > 0.5;
designMat(:,2) = ~designMat(:,1);

% Save networks and design matrix into data structure. 
data.subData = synthNet;
data.contrastEdgeIdx = contrastEdgeIdx;
data.designMat = double(designMat);
end

function [data] = make_regression(g,n,noise,nEdges,nNodes,formNetwork)
% make_regression synthetic generates network data for regression 
% problems using given graph network. 
% Arguments: 
%       g = graph structure.  
%       Please check help section of the main function for other arguements. 
%
%   Output:
%       data: A data structure which includes control and contrast
%           data, design matrix and indices of contrast links
%
% Find indices for contrasted edges. 
edgeIdx = find(triu(g));
nTotalEdges = numel(edgeIdx);
if formNetwork
    [~,~,contrastEdgeIdx] = find_contrastEdges(g,nEdges,nNodes);
    [~,cEdgeLoc] = ismember(contrastEdgeIdx,edgeIdx);
else
    cEdgeLoc = randperm(nTotalEdges,nEdges);
    contrastEdgeIdx = edgeIdx(cEdgeLoc);
end

% Generate normally distributed random data. 
X = randn(nTotalEdges,n*2); % Edges. 
groundTruth = zeros(nTotalEdges,1);
groundTruth(cEdgeLoc,:) = rand(nEdges,1); 
y = X'*groundTruth;
if noise > 0.0
    % Add noise to target variable.
    y = randn(size(y)).*noise + y;
end

% Embed data to networks. 
[synthNet] = embed_dataToNetwork(g,n,X,edgeIdx);

% Save networks and design matrix into data structure. 
data.subData = synthNet;
data.designMat = [ones(numel(y),1),y]; % design matrix.
data.contrastEdgeIdx = contrastEdgeIdx;
data.groundTruth = groundTruth; 
end

%% Helper Functions
function [path,prev,contrastEdgeIdx] = find_contrastEdges(g,nEdges,nNodes)
% find_contrastEdges find edges embedded with contrast of interest using
% breadth-first search algorithm, and return indices of contrasted edges. 
[path,prev] = find_edges(g,nEdges);
% Indices of edges with contrast.
contIdxAdj = spalloc(nNodes,nNodes,nEdges*2);
for i  = 1: nEdges
    contIdxAdj(prev(i),path(i)) = 1;
    contIdxAdj(path(i),prev(i)) = 1;
end
contrastEdgeIdx = find(triu(contIdxAdj));
end

function [path,prev] = find_edges(g,nEdges)
% find_edges finds edges using Breadth-First Search algorithm. 
[path,prev] = search_BF(g,randi(size(g,1),1),nEdges+1); % Find edges.
path = path(~isnan(prev)); % nodes.
prev = prev(~isnan(prev)); % Previous nodes.
end

function [synthNet] = embed_dataToNetwork(g,n,edgeWeight,edgeIdx)
% embed_dataToNetwork embeds to network structure using the indices for
% edges of network. 
gSize = size(g); % size of graph.

% Embed data to networks. 
synthNet = zeros(gSize(1),gSize(2),size(edgeWeight,2));
synthNet = reshape(synthNet,[],n*2);
synthNet(edgeIdx,:) = edgeWeight;
synthNet = reshape(synthNet,[gSize(1),gSize(2),n*2]);
synthNet = synthNet + permute(synthNet,[2,1,3]); % synthetic network.
end