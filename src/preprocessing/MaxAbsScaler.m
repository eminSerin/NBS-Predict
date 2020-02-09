classdef MaxAbsScaler < baseScaler
    %MAXABSSCALER Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function obj = fit(obj,data)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.fitParams.maxAbs = max(abs(data));
        end
        
        function transformedData = transform(obj,data)
            transformedData = data ./ obj.fitParams.maxAbs;
        end
        
        function originalData = inverse_transform(obj,transformedData)
            originalData = transformedData.*obj.fitParams.maxAbs;
        end
    end
end

