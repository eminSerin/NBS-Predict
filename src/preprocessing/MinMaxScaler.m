classdef MinMaxScaler < baseScaler
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MinMaxScaler transforms features by scaling each feature to a range
    % between 0 and 1. 
    %   
    % Parameters:
    %   data: Data to be scaled.
    %   featureRange: Range into which features will be scaled. 
    %   
    % Attributes:
    %   maxAbs: Absolute maximum value.
    %
    % Example: 
    %   scaler = MinMaxScaler();
    %   scaler.fit(data);
    %   transformedData = scaler.transform(data);
    %
    % Reference: 
    %   https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.MinMaxScaler.html
    %
    % Emin Serin
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function obj = MinMaxScaler(featureRange)
            % featureRange: List of desired range of transformed data. 
            if nargin == 0
            else
                obj.fitParams.minVals = featureRange(1);
                obj.fitParams.maxVals = featureRange(2);
            end
        end
        
        function obj = fit(obj,data)
            % Fit transformation object to find parameters required for
            % feature transformation.
            if ~isfield(obj.fitParams,'minVals')
                obj.fitParams.minVals = min(data);
                obj.fitParams.maxVals = max(data);
            end
        end
        
        function transformedData = transform(obj,data)
            % Transform data using parameters found during fitting. 
            obj.fitParams.range = obj.fitParams.maxVals - obj.fitParams.minVals;
            transformedData = (data-obj.fitParams.minVals)./ obj.fitParams.range;
        end
        
        function originalData = inverse_transform(obj,transformedData)
            % Inverse transformation using parameters. 
            originalData = (transformedData.*obj.fitParams.range)+obj.fitParams.minVals;
        end
        
    end
end

