classdef MatrixVectorizer < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MatrixVectorizer vectorizes a symmetric matrix.
    %
    % Provides fit/transform separation for ML pipelines: fit() learns the
    % edge indices and SMR mask from training data, and transform() applies
    % the same mask to new data without recomputing it.
    %
    % Example:
    %   vectorizer = MatrixVectorizer;
    %   vectorizer = vectorizer.fit(trainData);
    %   trainEdges = vectorizer.transform(trainData);
    %   testEdges  = vectorizer.transform(testData);
    %
    %   % Legacy one-step usage (fit + transform combined):
    %   edgeMatrix = vectorizer.fit_transform(data);
    %
    % Last edited by Emin Serin, 14.05.2026.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties (Access = private)
        smrMask         % Logical mask from SMR filtering.
        originalEdgeIdx % Edge indices before SMR filtering.
        isFitted        % Flag indicating whether fit() has been called.
    end
    
    properties
        triangle    % 'upper' or 'lower' triangle.
        smr         % Signal to missing value ratio threshold.
        nodes       % Number of nodes.
        edgeIdx     % Edge indices (after SMR filtering, if applied).
    end
    
    methods
        function obj = MatrixVectorizer(varargin)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Initializes class.
            %
            % Args:
            %   triangle: Triangular to extract edges from
            %       ('upper' or 'lower'; default = 'upper').
            %   smr = Signal to missing value ratio. Removes features
            %       where the percent of nonzero elements are below the
            %       given threshold (default = 0.1, meaning 10%).
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Default parameters.
            defaultVals.triangle = 'upper'; defaultVals.smr = 0.1;
            triangleOptions = {'upper', 'lower'};
            
            % Input Parser
            validationNumeric = @(x) isnumeric(x);
            validationTriangle = @(x) any(validatestring(x,triangleOptions));
            p = inputParser(); p.PartialMatching = 0; % deactivate partial matching.
            addParameter(p,'triangle',defaultVals.triangle,validationTriangle);
            addParameter(p,'smr',defaultVals.smr,validationNumeric);
            
            % Parse inputs and store into the object.
            parse(p,varargin{:});
            obj.triangle = p.Results.triangle;
            obj.smr = p.Results.smr;
            obj.nodes = [];
            obj.edgeIdx = [];
            obj.originalEdgeIdx = [];
            obj.smrMask = [];
            obj.isFitted = false;
        end
        
        function obj = fit(obj, data)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Learns edge indices and SMR mask from training data.
            %
            % Args:
            %   data: 3D (nodes x nodes x subject) or 2D (nodes x nodes)
            %       data matrix wherein correlation matrix from each 
            %       participant stored.
            %
            % Output:
            %   obj: Fitted MatrixVectorizer object.
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Extract raw edges (without filtering).
            [edgeMat, obj.nodes, obj.edgeIdx] = obj.extract_edges(data);
            obj.originalEdgeIdx = obj.edgeIdx;
            
            % Determine SMR mask from training data.
            ifAdjMat = (numel(unique(edgeMat)) == 2) && ...
                all(ismember(edgeMat(:), [0, 1]));
            
            if ~ifAdjMat
                obj.smrMask = mean(edgeMat ~= 0 & ~isnan(edgeMat), 1) > obj.smr;
                obj.edgeIdx = obj.edgeIdx(obj.smrMask);
            else
                obj.smrMask = true(1, numel(obj.edgeIdx));
            end
            
            obj.isFitted = true;
        end
        
        function edgeMat = transform(obj, data)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Vectorizes input matrix using previously fitted parameters.
            %
            % Must call fit() first to learn the edge indices and SMR mask.
            %
            % Args:
            %   data: 3D (nodes x nodes x subject) or 2D (nodes x nodes)
            %       data matrix wherein correlation matrix from each 
            %       participant stored.
            %
            % Output:
            %   edgeMat = 2D (subject x edge) matrix where each row 
            %       is subjects given and each column is edge values.
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            assert(obj.isFitted, ...
                'MatrixVectorizer:notFitted', ...
                'Must call fit() before transform(). Use fit_transform() for one-step usage.')
            
            % Extract edges using the fitted (post-SMR) edge indices.
            [edgeMat, ~, ~] = obj.extract_edges(data, obj.edgeIdx);
        end
        
        function edgeMat = fit_transform(obj, data)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Fits the vectorizer and transforms data in one step.
            % Convenience method equivalent to fit() followed by transform().
            %
            % Args:
            %   data: 3D (nodes x nodes x subject) or 2D (nodes x nodes)
            %       data matrix.
            %
            % Output:
            %   edgeMat = 2D (subject x edge) matrix where each row 
            %       is subjects given and each column is edge values.
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.fit(data);
            edgeMat = obj.transform(data);
        end
        
        function symMat = inverse_transform(obj, edgeMat)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Converts vectorized matrix back to a symmetric matrix.
            %
            % Args:
            %   edgeMat: Edge matrix comprising vectorized matrices.
            %
            % Output:
            %   symMat = 2D (nodes x nodes) or 3D (nodes x nodes x subject)
            %       symmetric matrices.
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            assert(obj.isFitted, ...
                'MatrixVectorizer:notFitted', ...
                'Must call fit() before inverse_transform().')
            
            dims = size(edgeMat); 
            nSub = dims(1);
            assert(dims(2) == numel(obj.edgeIdx), ...
                'Number of edges (%d) and indices (%d) do not match!', ...
                dims(2), numel(obj.edgeIdx))
            
            symMat = zeros(obj.nodes, obj.nodes, nSub); % preallocate.
            for s = 1:nSub
                cMat = symMat(:,:,s); % current matrix.
                cMat(obj.edgeIdx) = edgeMat(s,:);
                cMat = cMat + cMat'; % make it symmetric.
                symMat(:,:,s) = cMat; 
            end 
        end
        
        function matIdx = find_mat_idx(obj, idx)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Finds linear indices in the symmetric matrix for the given
            %   logical mask or numeric indices into the edge vector.
            %
            % Args:
            %   idx: Logical mask or numeric indices into the edge vector.
            %       If logical, must have the same length as edgeIdx.
            %
            % Output:
            %   matIdx = Linear indices into the symmetric matrix.
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            assert(obj.isFitted, ...
                'MatrixVectorizer:notFitted', ...
                'Must call fit() before find_mat_idx().')
            
            if islogical(idx)
                assert(numel(idx) == numel(obj.edgeIdx), ...
                    'Logical mask length (%d) must match number of edges (%d).', ...
                    numel(idx), numel(obj.edgeIdx))
            end
            
            matIdx = obj.edgeIdx(idx);
        end
        
    end
    
    methods (Access = private)
        function [edgeMat, nodes, edgeIdx] = extract_edges(obj, data, preEdgeIdx)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Internal method: extracts edge values from correlation matrices.
            %
            % Args:
            %   data: 2D or 3D data matrix.
            %   preEdgeIdx: Pre-existing edge indices (optional).
            %
            % Output:
            %   edgeMat: Extracted edge values.
            %   nodes: Number of nodes.
            %   edgeIdx: Edge indices used.
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Validate input dimensions.
            dataShape = size(data);
            dataDim = ndims(data);
            assert(ismember(dataDim, [2, 3]), ...
                'Data provided is not a 2D or 3D matrix!')
            assert(dataShape(1) == dataShape(2), ...
                'First two dimensions must be equal (nodes x nodes). See help!')
            nodes = dataShape(1);
            
            if dataDim == 2
                subjects = 1;
            else
                subjects = dataShape(3);
            end
            
            % Determine edge indices.
            if nargin < 3 || isempty(preEdgeIdx)
                if strcmpi(obj.triangle, 'upper')
                    edgeIdx = find(triu(true(nodes), 1));
                else
                    edgeIdx = find(tril(true(nodes), -1));
                end
            else
                edgeIdx = preEdgeIdx;
            end
            
            % Extract edges.
            edgeMat = zeros(subjects, numel(edgeIdx));
            if dataDim == 2
                edgeMat(1, :) = data(edgeIdx);
            else
                for i = 1:subjects
                    cMat = data(:, :, i);
                    if ~is_symmetric(cMat)
                        warning('Given matrix is not symmetric! Data index: %d', i)
                    end
                    edgeMat(i, :) = cMat(edgeIdx);
                end
            end
        end
    end
end
