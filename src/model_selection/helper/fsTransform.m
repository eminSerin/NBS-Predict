function [X_transformed,transformMask] = fsTransform(data,NBSPredict,bestParam)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fsTransform transforms given data according to best parameter provided.
%
% Arguements:
%   data = Data structure were current features and labels are stored.
%   NBSPredict = NBSPredict structure where data and parameters stored.
%   bestParam = Best parameter.
%
% Output:
%   X_transformed = Transformed data.
%   transformMask = Binary mask used to transform data.
%
% Emin Serin - 02.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if enough input is provided.
assert(nargin == 3, 'Please provide data and NBSPredict structures as well as the best parameter');

% Run GLM and get test statistics
[testStats,pVals] = run_nbsPredictGlm(data.y,data.X,NBSPredict.parameter.contrast,...
    NBSPredict.parameter.test);
sigIdx = find(pVals < NBSPredict.parameter.pVal);
%         sigIdx = find(pVals < NBSPredict.parameter.pVal);
[~,I] = sort(testStats,'descend'); % Rank features based on their test statistics.
I = I(ismember(I,sigIdx));
kBest = round(bestParam*numel(I));
if kBest == 0
    kBest = 1;
end

[extIdx] = extractComponentIdx(NBSPredict.data.nodes,NBSPredict.data.edgeIdx,...
    I(1:kBest));
transformMask = false(size(data.X,2),1);
transformMask(extIdx) = true;
X_transformed = data.X(:,transformMask);
end
