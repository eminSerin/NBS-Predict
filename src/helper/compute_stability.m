function [stability] = compute_stability(featureSet)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute_stability computes stability from given matrix of feature sets
% using Pearson Correlation Coefficient. 
%
% Arguments: 
%   featureSet: NxM matrix of feature sets, given each row is a distinct
%       features set derived from feature selection algorithm and.
%       Feature sets must have the same length. They can be weighted or
%       binary. 
%
% Output: 
%   stability: Stability score (i.e., average pairwise correlations). 
%   
% Example: 
%   [stability] = compute_stability(featureSet);
% 
% Reference:
%   Nogueira, S., & Brown, G. (2016, September). Measuring the stability of
%       feature selection. In Joint European conference on machine learning
%       and knowledge discovery in databases (pp. 442-457). Springer, Cham.
%   https://github.com/nogueirs/ECML2016
% 
% Emin Serin - 17.06.2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
nSets=size(featureSet,1);
stability=0;
for i=1:nSets
    for j=1:nSets
        if i~=j
            R = corrcoef(featureSet(i,:),featureSet(j,:));
            if isnan(R(2))
                R(2) = 0;
            end
            stability=stability+R(2);
        end
    end
end
stability=stability/(nSets*(nSets-1));
end






