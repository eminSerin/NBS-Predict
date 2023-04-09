function [varargout] = check_classification(y)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check_classification checks the target variable and returns if it is
% classification or not. It returns true if the number of unique values is
% below 3, false otherwise.
%
% Arguments:
%   y: Target variable.
%
% Output:
%   ifClass: True if the number of unique values is lower than 3,
%       false otherwise.
%   nClasses: Number of unique classes found in the target variable.
%
% Emin Serin - 19.10.2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

if length(size(y)) == 1 || size(y, 2) == 1
    % If y is 1D.
    nClasses = numel(unique(y));
else
    nClasses = numel(unique(y(:,2)));
end
ifClass = nClasses < 3;
varargout{1} = ifClass;
varargout{2} = nClasses;
end

