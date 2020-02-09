classdef StandardScaler < baseScaler
    %STANDARDSCALER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = fit(obj,data)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.fitParams.means = mean(data,1);
            obj.fitParams.std = std(data);
        end
        
        function transformedData = transform(obj,data)
            removeMean = data - obj.fitParams.means; 
            transformedData = removeMean./ obj.fitParams.std; 
        end
        
        function originalData = inverse_transform(obj,transformedData)
           originalData = (transformedData.*obj.fitParams.std)+obj.fitParams.means; 
        end
        
    end
end

