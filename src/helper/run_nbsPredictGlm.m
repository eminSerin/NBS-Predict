function [stats] = run_nbsPredictGlm(X,y,contrast,test)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   RUN_NBSPREDICTGLM performs a simple version of GLM used in NBS toolbox.
%   (Zalesky et.al., 2010)
%   Input:
%       y: data (dependent variables.)
%       X: design matrix (independent variables).
%       contrast: contrast values.
%       test: 't-test' or 'f-test'
%   Output:
%       stats = test statistics. 
%
%   Example:
%       [stats] = run_nbsPredictGlm(X,y,contrast,test)
%
%   TODO: Implement better nuisance control method!.
%
%   Last edited by Emin Serin, 29.08.2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check if nuisance variable
nuisance = find(~contrast);

% Define some parameters and calcualte betas and residuals.
nSub = size(y,1); % number of subjects/observations
nPred = size(X,2); % number of predictors
betas = X\y; % Least squares (alt. pinv(X)*y)
resid = y-X*betas; % residuals (i.e. error)

if strcmpi(test,'t-test')
    % Run t-test.
    mse = sum(resid.^2)/(nSub-nPred); % mean squared error
    se = sqrt(mse*(contrast*inv(X'*X)*contrast')); % standard error
    stats = (contrast*betas)./se; % t-values.
elseif strcmpi(test,'f-test')
    % Run f-test.
    sse = sum(resid.^2); % SSE - sum of squares error
    ssr = sum((X*betas-repmat(mean(y),nSub,1)).^2); % SSR - sum of squares regression
    if isempty(nuisance)
        % If no nuisance variable.
        stats = (ssr/(nPred-1))./(sse/(nSub-nPred)); % f-values
    else
        %Get reduced model
        %Column of ones will be added to the reduced model unless the
        %resulting matrix is rank deficient
        newX=[ones(nSub,1),X(:,nuisance)];
        %Number of remaining variables
        varLeft=length(find(contrast))-1;
        [n,ncolx]=size(newX);
        [~,R,~]=qr(newX,0);
        rankx = sum(abs(diag(R)) > abs(R(1))*max(n,ncolx)*eps(class(R)));
        if rankx < ncolx
            %Rank deficient, remove column of ones
            newX=X(:,nuisance);
            varLeft=length(find(contrast));
        end
        betas=newX\y;
        newSSR=sum((newX*betas-repmat(mean(y),n,1)).^2);
        stats=((ssr-newSSR)/varLeft)./(sse/(n-nPred));
    end
else
    error('Wrong test parameter provided! Please check help section!')
end
end


