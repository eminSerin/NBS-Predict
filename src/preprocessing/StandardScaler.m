classdef StandardScaler < baseScaler
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % StandardScaler standardizes features by removing the mean and scaling
    %   to variance of 1 (i.e., z-transformation).
    %   
    % Parameters:
    %   data: Input data to be scaled.
    %
    % Attributes:
    %   means: Mean.
    %   std: Standard deviation.
    %
    % Example: 
    %   scaler = StandardScaler();
    %   scaler.fit(data);
    %   transformedData = scaler.transform(data);
    %
    % Reference: 
    %   https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.StandardScaler.html
    %
    % Emin Serin
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

