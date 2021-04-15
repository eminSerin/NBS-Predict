classdef ConfoundRegression < baseScaler
    % ConfoundRegression removes variance explained by the confounds from
    % given data. Simply, a linear regression method is fitted on the each
    % feature in a given data using confounds are predictors. Then, it
    % removes variance in the data associated with confounds. 
    %   
    % Parameters: 
    %   data = Data matrix to be corrected. 
    %   confound = Matrix containing confound values 
    %       (Make sure that number of rows is similar to those in data).
    %   
    % Attributes: 
    %   fitParams.weights = Weights for the confounds. 
    %
    % Example: 
    %   correctConfound = ConfoundRegression;
    %   correctConfound.fit(data,confound);
    %   correctedData = correctConfound.transform(data);
    %
    % Reference:
    %   Snoek, L., Mileti, S., & Scholte, H. S. (2019). How to control for
    %   confounds in decoding analyses of neuroimaging data. NeuroImage,
    %   184, 741-760.
    %
    % Implemented on 31 January 2020 by Emin Serin.
    
    properties (Access = private)
       nzMask 
    end
    properties
        confound
    end
    
    methods
        function obj = fit(obj,data,confound)
            %fit fits a linear model to calculate weights . 
            
            % Removes features without any information (i.e., features with
            % all zeros)
            obj.confound = confound;
            obj.nzMask = ~all((data == 0 | isnan(data)));
            nzData = data(:,obj.nzMask);
            
            % Least-squares
            obj.fitParams.weights = linsolve(confound,nzData);
        end
        
        function transformedData = transform(obj,data,confound)
            % transform transforms data using weights. 
            if nargin < 3
                confound = obj.confound;
            end
            nzData = data(:,obj.nzMask);
            corrnzData = nzData-confound*obj.fitParams.weights; % Residuals
            transformedData = data; 
            transformedData(:,obj.nzMask) = corrnzData;
        end
        
        function transformedData = fit_transform(obj,data,confound)
            fit(obj,data,confound);
            transformedData = transform(obj,data);
        end
    end
end

