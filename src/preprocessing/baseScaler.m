classdef (Hidden = true) baseScaler < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % baseScaler is a base classs for scalers.
    %
    % Emin Serin
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%
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

