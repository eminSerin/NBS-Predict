function [varargout] = run_nbsPredictGlm(X,y,contrast,test)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   run_nbsPredictGlm performs a simple version of GLM used in NBS toolbox.
%   (Zalesky et.al., 2010)
%   Input:
%       X: design matrix (independent variables).
%       y: data (dependent variables.)
%       contrast: contrast values.
%       test: 't-test' or 'f-test'
%   Output:
%       stats = test statistics. 
%       p = p-values. 
%       betas = Coeffiecients. 
%
%   Example:
%       stats = run_nbsPredictGlm(X,y,contrast,test)
%       [stats, p] = run_nbsPredictGlm(X,y,contrast,test)
%
%   TODO: Implement better nuisance control method!.
%
%   Last edited by Emin Serin, 03.06.2020
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check if nuisance variable
nuisance = find(~contrast);

% Define some parameters and calcualte betas and residuals.
nSub = size(y,1); % number of subjects/observations
nPred = size(X,2); % number of predictors
betas = linsolve(X,y); % Least squares (alt. X\y)
resid = y-X*betas; % residuals (i.e. error)

if strcmpi(test,'t-test')
    % Run t-test.
    mse = sum(resid.^2)/(nSub-nPred); % mean squared error
    se = sqrt(mse*(contrast*inv(X'*X)*contrast')); % standard error
    stats = (contrast*betas)./se; % t-values.
    p = tcdf(stats,nSub-2,'upper');
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
    p = fcdf(1./stats,size(X,1)-2,size(sse,1));
else
    error('Wrong test parameter provided! Please check help section!')
end
varargout{1} = stats;
varargout{2} = p;
varargout{3} = betas; 
end


