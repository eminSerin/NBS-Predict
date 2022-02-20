function [CI] = compute_CI(numVec, zValue)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute_CI computes confidence intervals of given vector of numbers.
% Formula is: µ ± z* σ/√n. 
% Check https://tinyurl.com/54adtnuy for common z-values.
% 
%
% Arguments:
%   numVec = Number vector.
%   z = z-value for the given confidence level 
%       (default = 1.96 for 95% confidence);
%
% Output:
%   CI = Confidence interval values, [lower bound, upper bound]
%
% Emin Serin - 18.02.2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 2
    zValue = 1.96; % 95% default confidence level 
end

% Check if the given vector is 1D
assert(isvector(numVec), 'Given vector is not 1D!!!');

nNums = numel(numVec);
numMean =  mean(numVec);
numSE = std(numVec)/sqrt(nNums);
alphaSE = numSE*zValue; % 95% confidence interval.
lowerBoundNum = numMean - alphaSE; % lower CI
upperBoundNum = numMean + alphaSE; % upper CI
CI = [lowerBoundNum,upperBoundNum];
end

