classdef MaxAbsScaler < baseScaler
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MaxAbsScaler scales data by its maximum value.
    %   
    % Parameters:
    %   data: Input data to be scaled.
    %
    % Attributes:
    %   maxAbs: Absolute maximum value.
    %
    % Example: 
    %   scaler = MaxAbsScaler();
    %   scaler.fit(data);
    %   transformedData = scaler.transform(data);
    %
    % Reference: 
    %   https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.MaxAbsScaler.html
    %
    % Emin Serin
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%
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

