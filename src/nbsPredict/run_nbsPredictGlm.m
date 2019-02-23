function [glm] = run_nbsPredictGlm(glm)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   RUN_NBSPREDICTGLM performs a simple version of GLM used in NBS toolbox.
%   (Zalesky et.al., 2010)
%   Input:
%       glm.y: data (dependent variables.)
%       glm.X: design matrix (independent variables).
%       glm.contrast: contrast values.
%       glm.test: 'ttest' or 'ftest'
%   Output:
%       glm structure in which test statistics locate
%
%    TODO: Implement better nuisance control method!.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if nuisance variable
nuisance = find(~glm.contrast);

% Define some parameters and calcualte betas and residuals.
glm.nSub = size(glm.y,1); % number of subjects/observations
glm.nPred = size(glm.X,2); % number of predictors
glm.betas = glm.X\glm.y; % Least squares (alt. pinv(X)*y)
glm.resid = glm.y-glm.X*glm.betas; % residuals (i.e. error)

if strcmpi(glm.test,'t-test')
    % Run t-test.
    glm.mse = sum(glm.resid.^2)/(glm.nSub-glm.nPred); % mean squared error
    glm.se = sqrt(glm.mse*(glm.contrast*inv(glm.X'*glm.X)*glm.contrast')); % standard error
    glm.Stats = (glm.contrast*glm.betas)./glm.se; % t-values.
else
    % Run f-test.
    glm.sse = sum(glm.resid.^2); % SSE - sum of squares error
    glm.ssr = sum((glm.X*glm.betas-repmat(mean(glm.y),glm.nSub,1)).^2); % SSR - sum of squares regression
    if isempty(nuisance)
        % If no nuisance variable.
        glm.Stats = (glm.ssr/(glm.nPred-1))./(glm.sse/(glm.nSub-glm.nPred)); % f-values
    else
        %Get reduced model
        %Column of ones will be added to the reduced model unless the
        %resulting matrix is rank deficient
        newX=[ones(glm.nSub,1),glm.X(:,nuisance)];
        %Number of remaining variables
        varLeft=length(find(glm.contrast))-1;
        [n,ncolx]=size(newX);
        [~,R,~]=qr(newX,0);
        rankx = sum(abs(diag(R)) > abs(R(1))*max(n,ncolx)*eps(class(R)));
        if rankx < ncolx
            %Rank deficient, remove column of ones
            newX=glm.X(:,nuisance);
            varLeft=length(find(glm.contrast));
        end
        glm.betas=newX\glm.y;
        newSSR=sum((newX*glm.betas-repmat(mean(glm.y),n,1)).^2);
        glm.Stats=((glm.ssr-newSSR)/varLeft)./(glm.sse/(n-glm.nPred));
    end
end
end


