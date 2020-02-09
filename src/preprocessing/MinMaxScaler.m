classdef MinMaxScaler < baseScaler
    % MinMaxScaler transforms features by scaling each feature to a range
    % between 0 and 1. 
    
    methods
        function obj = fit(obj,data)
            % Fit transformation object to find parameters required for
            % feature transformation.
            obj.fitParams.minVals = min(data);
            obj.fitParams.maxVals = max(data);
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

