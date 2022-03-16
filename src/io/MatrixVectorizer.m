classdef MatrixVectorizer < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MatrixVectorizer vectorizes a symmetric matrix.
    %
    % Example:
    %   vectorizer = MatrixVectorizer;
    %   edgeMatrix = vectorizer.transform(data);
    %
    % Last edited by Emin Serin, 28.02.2022
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties (Access = private)
        smrMask
        dataShape
    end
    
    properties
        triangle
        smr
        nodes
        edgeIdx
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
            
            % Set default inputs.
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
            obj.dataShape = [];
            obj.smrMask = [];
        end
        
        function edgeMat = transform(obj,data)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Vectorizes input matrix.
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
            % Check data size.
            obj.dataShape = size(data);
            dataDim = length(obj.dataShape);
            assert(ismember(dataDim,[2,3]),...
                'Data provided is not a 2D or 3D matrix!')
            assert(obj.dataShape(1) == obj.dataShape(2),...
                'Please provide correct form of data matrix. See help!')
            obj.nodes = obj.dataShape(1);
            if dataDim == 2
                subjects = 1;
            elseif dataDim == 3
                assert(obj.dataShape(1) == obj.dataShape(2), 'Unrecognized dataset structure!')
                subjects = obj.dataShape(3);
            end
            
            % finds edge indices.
            if strcmpi(obj.triangle, 'upper')
                obj.edgeIdx = single(find(triu(ones(obj.nodes,obj.nodes),1)));
            else
                obj.edgeIdx = single(find(tril(ones(obj.nodes,obj.nodes),1)));
            end
            
            edgeMat = zeros(subjects,length(obj.edgeIdx)); % pre-allocate.
            if dataDim == 2
                edgeMat(1,:) = data(obj.edgeIdx); % extract edge values.
            else
                for i = 1:subjects
                    cMat = data(:,:,i); % Select current matrix.
                    if ~issymmetric(cMat)
                        warning('Given matrix is not symmetric! Data index: %d', i)
                    end
                    edgeMat(i,:)=cMat(obj.edgeIdx); % extract edge values.
                end
            end
            
            % Check if binary matrix.
            ifAdjMat = (numel(unique(edgeMat))==2) & all(ismember(edgeMat,[0,1]));
            
            % Remove features where nonzero features are 10% or less.
            if ~ifAdjMat
                logicalEdgeMat = edgeMat;
                logicalEdgeMat((logicalEdgeMat ~= 0)&(~isnan(logicalEdgeMat))) = 1;
                obj.smrMask = mean(logicalEdgeMat,1) > obj.smr;
                edgeMat = edgeMat(:,obj.smrMask); % EdgeMat with non-zero edges.
                obj.edgeIdx = obj.edgeIdx(obj.smrMask);
            end
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
            dims = size(edgeMat); 
            nSub = dims(1);
            assert(dims(2), numel(obj.edgeIdx),...
                'Number of edges and indices do not match!')
            
            symMat = zeros(obj.nodes, obj.nodes, nSub); % preallocate.
            for s = 1: nSub
                cMat = symMat(:,:,s); % current matrix.
                cMat(obj.edgeIdx) = edgeMat(s,:);
                cMat = cMat + cMat'; % make it symmetric.
                symMat(:,:,s) = cMat; 
            end 
        end
        
        function matIdx = find_mat_idx(obj, idx)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Finds edge indices from a symmetric matrix from given 
            %   vectorized indices.
            %
            % Args:
            %   idx: Indices of edges in a vectorized form.
            %
            % Output:
            %   matIdx = Indices of edges in a symmmetric matrix.
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
            assert(numel(obj.edgeIdx)==numel(idx),...
                'Dimensions do not match!')
            
            matIdx = obj.edgeIdx(idx);
        end
        
    end
end

