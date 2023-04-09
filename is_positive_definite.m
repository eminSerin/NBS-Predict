function [isPosDef] = is_positive_definite(X)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% is_positive_definite Checks if given matrix is positive definite.
%
% Arguments:
%   X = 2D (nodes x nodes) matrix.
%
% Output:
%   isPosDef = Whether given matrices are positive definite.
%
% Emin Serin - 28.02.2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try chol(X)
    isPosDef = 1;
catch
    isPosDef = 0;
end
end

