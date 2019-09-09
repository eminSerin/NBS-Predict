function value = getfieldi(S,fieldName)
%   getfieldi is a case-insensitive version of MATLAB's getfield function.
%   It returns value from field from a structure.
%
%   Arguement:
%       S = Structure from which value of field are requested.
%       fieldName = Name of field from which value is needed.
%
%   Output:
%       value = Value from given field.
%
%   Example:
%        value = getfieldi(S,fieldName);
%
%   Emin Serin - 15.08.2019
%

%%
assert(nargin==2,'Not enough inputs! Please check help section!')
fNames   = fieldnames(S);
isField = strcmpi(fieldName,fNames);
value = [];
if any(isField)
    value = S.(fNames{isField});
end
end