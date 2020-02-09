classdef (Hidden = true) baseScaler < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fitParams
    end
    
    methods
        function obj = baseScaler()
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        function transformedData = fit_transform(obj,data)
            fit(obj,data);
            transformedData = transform(obj,data);
        end 
    end
end

