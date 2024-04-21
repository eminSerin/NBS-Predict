function isSymmetric = is_symmetric(matrix, tolerance)
% IS_SYMMETRIC Checks if a given matrix is symmetric within a specified tolerance.
%
% Syntax:
%   isSymmetric = is_symmetric(matrix, tolerance)
%
% Input Arguments:
%   matrix - A square matrix to be checked for symmetry.
%   tolerance - A scalar value specifying the tolerance for the symmetry check. 
%               If not provided, the default value is 1e-15.
%
% Output Argument:
%   isSymmetric - A logical value indicating whether the matrix is symmetric 
%                 within the specified tolerance. Returns true if the matrix 
%                 is symmetric and false otherwise.
%
% Example:
%   matrix = [1, 2; 2, 1];
%   isSymmetric = is_symmetric(matrix, 1e-15);
%
%   This will return true as the matrix is symmetric within the tolerance of 1e-15.
%
% Note:
%   The function first checks if the matrix is square. If not, it returns false. 
%   Then it calculates the absolute difference between the matrix and its transpose. 
%   If all elements in the difference matrix are within the tolerance, it returns true. 
%   Otherwise, it returns false.
%
if nargin < 2
    tolerance = 1e-15;
if size(matrix, 1) ~= size(matrix, 2)
    isSymmetric = false;
    return;
end

% Calculate the difference between the matrix and its transpose
diffMatrix = abs(matrix - matrix');

% Check if all elements in the difference matrix are within the tolerance
isSymmetric = all(all(diffMatrix <= tolerance));
end