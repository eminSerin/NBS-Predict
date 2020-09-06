function [activationPattern] = transform_toActivationPattern(X,beta)
% Transform weights derived from linear models to activation patterns using
% algorithm shown by Haufe et.al., 2014. 
% 
% Input: 
%   X:    Feature matrix (sample x features) 
%   beta: Coefficients derived from linear models (e.g., Linear Regression,
%       Logistic Regression, Lienar SVM)
% Output: 
%   activationPattern: Activation pattern. 
% Usage: 
%   activationPattern = transform_toActivationPattern(X,beta)
%
% Reference: 
%   Haufe, S., Meinecke, F., Görgen, K., Dähne, S., Haynes, J. D.,
%   Blankertz, B., & Bießmann, F. (2014). On the interpretation of weight
%   vectors of linear models in multivariate neuroimaging. Neuroimage, 87,
%   96-110.
%
% Emin Serin - 21.06.2020
%
nFeatures = size(X,2);
covMat = cov(X*beta);
normCovMat = (beta/covMat)./(nFeatures-1); % Normalized Covariance Matrix. 
activationPattern = X'*(X*normCovMat);
end
