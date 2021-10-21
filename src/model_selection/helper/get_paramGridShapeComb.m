function [shapeGrid,nComb] = get_paramGridShapeComb(paramGrid)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_paramGridShapeComb returns shape of parameter grid and total number
% of parameter combinations. 
%
% Arguments
%   paramGrid = Structure including parameters.
%
% Output
%   shapeGrid = Shape of parameter grid. 
%   nComb = Total number of parameter combinations. 
% 
% Emin Serin - 19.08.2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Total number of parameters.
assert(isstruct(paramGrid),['Parameter grid is not a structure!',...
    'Parameter grid must be structure in which each fields are distinct array of candidate parameters']);

% Remove empty fields.
ifEmpty = structfun(@isempty,paramGrid);
if any(ifEmpty)
    paramGrid = rm_emptyField(paramGrid);
end

cellParamGrid = struct2cell(paramGrid);
shapeGrid = cellfun(@numel,cellParamGrid); % shape of parameter grid. 
nComb = prod(shapeGrid); % total number of parameter combinations. 
end

