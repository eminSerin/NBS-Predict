function isSymmetric = is_symmetric(matrix, tolerance)
% IS_SYMMETRIC Checks if a matrix is symmetric within a given tolerance.
%
% Syntax:
%   isSymmetric = is_symmetric(matrix)
%   isSymmetric = is_symmetric(matrix, tolerance)
%
% Input Arguments:
%   matrix    - A numeric matrix to be checked for symmetry.
%   tolerance - Non-negative scalar tolerance (default: scaled by matrix
%               magnitude and size, similar to MATLAB's issymmetric).
%               Use 0 for exact symmetry (equivalent to issymmetric(matrix)).
%
% Output:
%   isSymmetric - Logical scalar; true if symmetric within tolerance.
%
% Notes:
%   - Non-square matrices always return false.
%   - Matrices containing NaN are always reported as non-symmetric since
%     NaN comparisons return false.
%   - For exact symmetry with no tolerance, prefer the built-in issymmetric().
%
% Example:
%   is_symmetric([1 2; 2 1])         % true
%   is_symmetric([1 2; 2+1e-12 1])   % true (within default tolerance)
%   is_symmetric([1 2; 3 1])         % false

if nargin < 2 || isempty(tolerance)
    % Scale tolerance by matrix magnitude and size (robust to large values).
    tolerance = eps(max(abs(matrix(:)))) * size(matrix, 1);
end

assert(isscalar(tolerance) && isnumeric(tolerance) && tolerance >= 0, ...
    'is_symmetric:invalidTolerance', ...
    'Tolerance must be a non-negative numeric scalar.');

% Non-square matrices cannot be symmetric.
if size(matrix, 1) ~= size(matrix, 2)
    isSymmetric = false;
    return;
end

isSymmetric = all(abs(matrix - matrix') <= tolerance, 'all');
end
