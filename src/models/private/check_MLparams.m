function [readyParams] = check_MLparams(params,defaultParams)
%   check_MLparams checks parameters provided and returns default parameter
%   for an ML algorithm using a structure including default parameters. It
%   also throws warning messages if a user provide parameter structure to
%   ML function, but an appropriate parameter is not found in that
%   parameter structure. 
%
%   Arguement: 
%       params = Structure including user defined parameters. 
%       defaultParams = Structure including default parameters required for
%           an ML algorithm. 
%
%   Output: 
%       readyParams = Structure including parameters which are ready to be
%           used by an ML algorithm.
%
%   Example:
%       [readyParams] = check_MLparams(params,defaultParams);
%
%   Emin Serin - 15.08.2019

%% 
if ~(nargin==2)
    % Throw error if enough parameters are provided.
    help check_MLparams
    error('Wrong parameters are provided. Please check help section!');
end

% Throw warning if no required parameter found in params structure
% provided. 
paramNames = fieldnames(params);
defaultParamNames = fieldnames(defaultParams);
lParamNames = lower(paramNames); 
lDefaultParamNames = lower(defaultParamNames);
paramMask = ismember(lDefaultParamNames,lParamNames);
if ~isempty(paramNames)
    try
        assert(any(paramMask),'noExistentParam');
    catch ME
        switch ME.message
            case 'noExistentParam'
                warning(['No parameters found in params structure!',...
                    ' Please check help for proper parameter structure!',...
                    ' All parameters are set to default values!'])
        end
    end
end

% Set default values to parameters that are not provided. 
nonexistentParamsIdx = find(~paramMask);
for i = 1: numel(nonexistentParamsIdx)
    cNonexistentParamIdx = nonexistentParamsIdx(i);
    params.(defaultParamNames{cNonexistentParamIdx})...
        = defaultParams.(defaultParamNames{cNonexistentParamIdx});
end
readyParams = params;
end

