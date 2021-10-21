function [S] = rm_emptyField(S)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rm_emptyField removes empty field in a given structure. 
% 
% Argument: 
%   S = Structure in which empty field will be removed. 
%
% Output:
%   S = Structure with no empty fields. 
%
% Example: 
%   [S] = rm_emptyField(S)
%
% Emin Serin - 30.08.2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
paramNames = fieldnames(S);
ifEmpty = structfun(@isempty,S);
if any(ifEmpty)
    S = rmfield(S,{paramNames{ifEmpty}}); % Remove empty field.
end
end