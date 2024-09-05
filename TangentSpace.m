classdef TangentSpace < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TangentSpace Transforms positive definite covariance matrices
    %   into tangent space. Transforming covariance matrices 
    %   (or positive definite correlation matrices) into tangent space 
    %   has been shown to provide significantly higher 
    %   prediction performance (Dadi et al., 2019; Pervaiz et al., 2020).
    % 
    % 
    %
    % Example:
    %   vectorizer = TangentSpace;
    %   edgeMatrix = vectorizer.transform(data);
    %
    % References:
    %   Dadi, Kamalaker, et al. "Benchmarking functional connectome-based
    %       predictive models for resting-state fMRI." 
    %       NeuroImage 192 (2019): 115-134. 
    %   Pervaiz, Usama, et al. "Optimising network modelling
    %       methods for fMRI." Neuroimage 211 (2020): 116604.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties (Access = private)
        dims % dimensions of the data
        whitening  % whitening matrix
        ref_matrix % reference matrix
    end

    properties (Access = public)
        ref
    end

    methods (Access = private)
        function [] = check_positive_definite(~, X)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Checks whether input matrices are positive definite.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            x_dim = size(X);
            n_dims = numel(x_dim);
            assert(ismember(n_dims, [2,3], 'Input matrix must be 2D or 3D!'));
            if numel(x_dim) == 3
                for s = 1: x_dim(3)
                   assert(is_positive_definite(X(:,:,s)),...
                       'Input matrix is not positive definite!') 
                end
            elseif numel(x_dim) == 2
                assert(is_positive_definite(X),...
                       'Input matrix is not positive definite!')                
            end
        end

        function [] = map_shrinkage(obj, X)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Applies shrinkage each covariance matrix in X dataset.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            switch obj.ref
                case 'euclidian'
                    % Takes euclidian mean of input matrix.
                    obj.ref_matrix = squeeze(mean(X, 3));
                case 'log_euclidian'
                    % Computes log euclidian mean of input matrix.
                    obj.ref_matrix = exp(mean(log(X), 3));
            end
        end

        function symMat = form_symmetric_matrix(~, X, func)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   Constructs a symmetric matrix from a given X matrix
            %   using eigenvalues and eigenvectors computed from the input
            %   matrix. While constructing, it also applies a custom 
            %   function to eigenvalues to transform the matrix space.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if nargin < 2
               func = @(x) 1./x;
            end
            
            % Eigendecomposition
            [EV,DV] = eig(X);
            DV = func(DV); % transform eigenvalues using given function.
            DV(isinf(DV)) = 0;
            
            % form matrix again.
            symMat = EV*DV*EV';
        end
    end

    methods
        function obj = TangentSpace(varargin)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Initializes class.
            %
            % Args:
            %   ref: Method to compute mean reference matrix
            %        (default = 'euclidian').
            %       
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Default parameters.
            defaultVals.ref = 'euclidian';
            refOptions = {'euclidian', 'log_euclidian'};
            
            % Input Parser
            validationRef = @(x) any(validatestring(x,refOptions));
            p = inputParser(); p.PartialMatching = 0; % deactivate partial matching.
            addParameter(p,'ref',defaultVals.ref,validationRef);
            
            % Parse inputs and store into the object.
            parse(p,varargin{:});
            obj.ref = p.Results.ref;
            obj.dims = [];
        end

        function obj = fit(obj,X)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Fits the tangent space transformer to the given X matrix.
            %
            % Args:
            %   X: 3D (nodes x nodes x subject) input matrix.
            %       
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.check_positive_definite(X);
            obj.ref_matrix = map_shrinkage(X); % compute reference matrix.
            obj.whitening = form_symmetric_matrix(obj, X);  
        end

        function trans_mat = transform(obj,X)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Projects the input covariance matrices into tangent space
            %   using computed reference mean matrix.
            %
            % Args:
            %   X: 3D (nodes x nodes x subject) or 2D (nodes x nodes)
            %       input matrix.
            %   
            % Output:
            %   trans_mat: Transformed matrix.
            %       
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.check_positive_definite(X);
            x_dim = size(X);
            n_dims = numel(x_dim);
            assert(ismember(n_dims, [2,3], 'Input matrix must be 2D or 3D!'));
            if n_dims == 3
                nSub = x_dim(3);
                trans_mat = zeros(x_dim);
            elseif n_dims == 2
                nSub = 1;
                trans_mat = zeros([1; x_dim(:)]');
            end
            
            for s = 1: nSub
                trans_mat(s,:,:) = obj.form_symmetric_matrix(...
                    obj.whitening * X(s,:,:) * obj.whitening, log);
            end
            trans_mat = squeeze(trans_mat);
        end

        function untrans_mat = inverse_transform(obj, X)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Inverse transform from tangent space to covariance matrix 
            %   (Riemannian space).
            %
            % Args:
            %   X: Tangent transformed input matrix.
            %   
            % Output:
            %   untrans_mat: Inverse transformed, covariance matrices.
            %       
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            sqrt_whitening = obj.form_symmetric_matrix(obj.refMat, sqrt);
            x_dim = size(X);
            n_dims = numel(x_dim);
            assert(ismember(n_dims, [2,3], 'Input matrix must be 2D or 3D!'));
            if n_dims == 3
                nSub = x_dim(3);
                untrans_mat = zeros(x_dim);
            elseif n_dims == 2
                nSub = 1;
                untrans_mat = zeros([1; x_dim(:)]');
            end
            
            for s = 1: nSub
               untrans_mat(:,:,1) =...
                   sqrt_whitening * obj.form_symmetric_matrix(X(:,:,s), exp) *...
                   sqrt_whitening;
            end
            untrans_mat = squeeze(untrans_mat);
        end

    end
end



