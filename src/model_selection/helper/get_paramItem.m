function [params] = get_paramItem(paramGrid,ind)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_paramItem get the parameter(or combination of parameters) that is
% in ind'th in the parameter grid.
%
% Arguements: 
%   paramGrid = Parameter grid structure in which each properties are
%       possible parameters.
%   ind = The parameter index 
%
% Output:
%   params = Structure including parameter properties. 
%
% Example:
%   Linear Discriminant analysis
%   parameterGrid.delta = linspace(1,25,5);
%   parameterGrid.gamma = linspace(0,1,10);
%   [params] = get_paramItem(parameterGrid,5); % returns 5th of
%       parameter combination.
%   
% Emin Serin - 12.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove empty fields.
ifEmpty = structfun(@isempty,paramGrid);
if any(ifEmpty)
    paramGrid = rm_emptyField(paramGrid);
end
paramNames = fieldnames(paramGrid);

pGrid = struct2cell(paramGrid); % convert paramater grid structure into cell. 
shapeParam = cellfun(@numel,pGrid); % parameter grid shape. 
nComb = prod(shapeParam); % total number of combination
[maxParam,mIdx] = max(shapeParam);

if isrow(pGrid{mIdx})
    pGrid{mIdx} = pGrid{mIdx}';
end
pGrid{mIdx} = sort(repmat(pGrid{mIdx},[nComb/maxParam,1])); % sort by parameter with highest candidate. 
shapeParamMultiplied = shapeParam;
shapeParamMultiplied(mIdx) = nComb; % parameter grid shape. 

lenParam = numel(paramNames);

for i = 1:lenParam
    idx = mod(ind,shapeParamMultiplied(i));
    if idx == 0
        divs = [ind,shapeParamMultiplied(i)];
        divVal = max(divs)/min(divs);
        if round(divVal) == divVal
            idx = min(divs); 
        else
            idx = 1;
        end
    end
    params.(paramNames{i}) = pGrid{i}(idx);
end

end