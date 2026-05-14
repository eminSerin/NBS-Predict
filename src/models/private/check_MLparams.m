function [readyParams] = check_MLparams(params,defaultParams)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check_MLparams checks parameters provided and returns default parameter
% for an ML algorithm using a structure including default parameters. It
% also throws warning messages if a user provide parameter structure to
% ML function, but an appropriate parameter is not found in that
% parameter structure. 
%
% Arguments: 
%     params = Structure including user defined parameters. 
%     defaultParams = Structure including default parameters required for
%         an ML algorithm. 
%
% Output: 
%     readyParams = Structure including parameters which are ready to be
%         used by an ML algorithm.
%
% Example:
%     [readyParams] = check_MLparams(params,defaultParams);
%
% Emin Serin - 14.05.2026
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~(nargin==2)
    % Throw error if enough parameters are provided.
    help check_MLparams
    error('Wrong parameters are provided. Please check help section!');
end

paramNames = fieldnames(params);
defaultParamNames = fieldnames(defaultParams);
lParamNames = lower(paramNames);
lDefaultParamNames = lower(defaultParamNames);
paramMask = ismember(lDefaultParamNames, lParamNames);

% Warn if a non-empty params struct contains no recognised parameters.
if ~isempty(paramNames) && ~any(paramMask)
    warning(['No parameters found in params structure!', ...
        ' Please check help for proper parameter structure!', ...
        ' All parameters are set to default values!'])
end

% Warn about extra / unknown parameters (catches typos).
extraParamsMask = ~ismember(lParamNames, lDefaultParamNames);
if any(extraParamsMask)
    unknownNames = paramNames(extraParamsMask);
    warning('check_MLparams: Unknown parameter(s) provided: %s. These will be ignored.', ...
        strjoin(unknownNames, ', '));
end

% Set default values for parameters that were not provided.
nonexistentParamsIdx = find(~paramMask);
for i = 1:numel(nonexistentParamsIdx)
    cIdx = nonexistentParamsIdx(i);
    params.(defaultParamNames{cIdx}) = defaultParams.(defaultParamNames{cIdx});
end

% Normalize user-supplied field names to canonical (default) casing so
% that downstream code using params.FieldName always works correctly.
existentParamsIdx = find(paramMask);
for i = 1:numel(existentParamsIdx)
    cIdx = existentParamsIdx(i);
    canonicalName = defaultParamNames{cIdx};
    % Find the user's field that matched (case-insensitive).
    userFieldIdx = strcmpi(canonicalName, paramNames);
    userFieldName = paramNames{userFieldIdx};
    if ~strcmp(userFieldName, canonicalName)
        % Rename: copy value under canonical name, then remove old name.
        params.(canonicalName) = params.(userFieldName);
        params = rmfield(params, userFieldName);
    end
end

readyParams = params;
end

