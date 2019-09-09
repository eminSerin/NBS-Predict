function [varargout] = gen_synthData(varargin)
%   gen_synthData generates synthetic network data and embed contrast of
%   interest in a given number of edges. Using this function scale-free,
%   small-world and random networks can be generated. It returns a
%   structure including network matrices, design matrix and list of indices
%   of contrasted edges. 
%
%   Arguements: 
%       nNodes: Number of nodes in the network. (default = 100)
%       nEdges: Number of edges with contrast. (default = 10)
%       cnr: Contrast-to-noise ratio. (default = 0.5)
%       n: The number of control-contrast network couples generated.
%           (default = 20, i.e. sample size of 40 observations). 
%       ifSave: Whether save the data to .mat file or not 
%           (default = 0).
%       network: Type of network (default = 'scalefree')
%           Scale-free network:
%               m: Number of edges through which a new node connects to
%                  existing nodes (default = 2).
%               m0: Initial number of nodes in the network. (default = 5)
%           Small-world network:
%               k: k-nearest neightbors each node is connected (default = 2). 
%               beta: rewiring probability. (default = .05)
%           Random network. 
%       
%   Output:
%       synthData: A data structure which includes control and contrast
%           data, design matrix and indices of contrast links
%
%   Example: 
%       [data] = gen_synthData();
%       [data] = gen_synthData('network','smallworld');
%       [data] = gen_synthData('network','smallworld',...
%           'nNodes',500);
%   
%   References:
%       Barabsi,A.-L. and Albert,R. (1999) Emergence of Scaling in Random
%           Networks. Science, 286, 509-512.
%       Watts, D. J., & Strogatz, S. H. (1998). Collective dynamics of
%           'Small-World' networks. Nature, 393(6684), 440.
%       Zalesky, A., Fornito, A., & Bullmore, E. T. (2010). Network-based
%           statistic: identifying differences in brain networks.
%           Neuroimage, 53(4), 1197-1207.
%
%   Last edited by Emin Serin, 03.09.2019
%
%   See also: test_NBSPredict, gen_BAnet, gen_SWnet, search_BF

%% Set default parameters and parse input

% Default parameters.
defaultVals.nNodes = 100; defaultVals.nEdges= 10; 
defaultVals.cnr = 0.5; defaultVals.network = 'smallworld';
defaultVals.m = 2; defaultVals.m0 = 5;
defaultVals.k = 2; defaultVals.beta = .05;
defaultVals.n = 20; defaultVals.ifSave = 0;
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
addParameter(p,'n',defaultVals.n,validationNumeric);
addParameter(p,'ifSave',defaultVals.ifSave,validationNumeric);

% Parse inputs. 
parse(p,varargin{:});

network = p.Results.network;
ifSave = p.Results.ifSave;
nNodes = p.Results.nNodes;
n = p.Results.n;

% Create output directory
if ifSave
    outputDir = [pwd filesep 'SynthData' filesep];
    if ~exist(outputDir)
        mkdir(outputDir)
    end
end

% Create data structure including synthetic data and design matrix. 
data.subData = zeros(nNodes,nNodes,n*2);
designMat = (1:n*2) ./ (n*2);
designMat = designMat' > 0.5;
designMat(:,2) = ~designMat(:,1);
data.designMat = designMat;

%% Create control network.
% Check network generation method.

if strcmpi(network,'scalefree')
    g = gen_BAnet(p.Results.nNodes,p.Results.m0,p.Results.m); % generate scale-free network.
elseif strcmpi(network,'smallworld')
    g = gen_SWnet(nNodes,p.Results.k,p.Results.beta); % generates small-world network.
elseif strcmpi(network,'random')
    g = normrnd(0,1,nNodes); % generates normally distributed random network. 
end

[path,prev] = search_BF(g,randi(size(g,1),1),p.Results.nEdges+1); % Find edges.
path = path(~isnan(prev)); % nodes.
prev = prev(~isnan(prev)); % Previous nodes.
    
for j = 1: p.Results.n % number of networks generated.    
    weightEdge = triu(g).*normrnd(0,1,size(g)); % Weighted edges (0 mean 1 std).
    controlNet = weightEdge + weightEdge'; % control network.
    
    %% Add Contrast
    contrastNet = controlNet;
    contrast = normrnd(p.Results.cnr,1,length(prev),1); % generate contrast.
    for i  = 1: length(contrast)
        % Generate contrast network.
        contrastNet(prev(i),path(i)) = contrast(i);
        contrastNet(path(i),prev(i)) = contrast(i);
    end
    data.subData(:,:,j) = controlNet;
    data.subData(:,:,j+p.Results.n) = contrastNet;
    
end
data.designMat = double(data.designMat); % design matrix. 

% Indices of edges with contrast. 
data.contrastEdgeIdx = find(triu(contrastNet ~= controlNet));

if ifSave
    % Save design matrix.
    save([outputDir 'SynthData_',date,'.mat'],'data');
end

varargout{:} = data;
end


