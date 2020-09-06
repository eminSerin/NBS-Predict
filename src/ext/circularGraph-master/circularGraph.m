classdef circularGraph < handle
    % CIRCULARGRAPH Plot an interactive circular graph to illustrate connections in a network.
    %
    %% Syntax
    % circularGraph(X)
    % circularGraph(X,'PropertyName',propertyvalue,...)
    % h = circularGraph(...)
    %
    %% Description
    % A 'circular graph' is a visualization of a network of nodes and their
    % connections. The nodes are laid out along a circle, and the connections
    % are drawn within the circle. Click on a node to make the connections that
    % emanate from it more visible or less visible. Click on the 'Show All'
    % button to make all nodes and their connections visible. Click on the
    % 'Hide All' button to make all nodes and their connections less visible.
    %
    % Required input arguments.
    % X : A symmetric matrix of numeric or logical values.
    %
    % Optional properties.
    % Colormap : A N by 3 matrix of [r g b] triples, where N is the
    %            length(adjacenyMatrix).
    % Label    : A cell array of N strings.
    %%
    % Copyright 2016 The MathWorks, Inc.
    properties
        Node = node(0,0); % Array of nodes
        Label; % Labels; 
        Degree; % Degree
    end
    
    methods
        function this = circularGraph(adjacencyMatrix,varargin)            
            % Input Parser
            p = inputParser;
            nNodes = length(adjacencyMatrix);
            degree = sum(full(adjacencyMatrix) > 0,2);
            defaultColorMap = 'parula';
            defaultLabel = cell(nNodes);
            defaultnWeight = sum(degree);
            for i = 1:length(defaultLabel)
                defaultLabel{i} = num2str(i);
            end
            
            addRequired(p,'adjacencyMatrix',@(x)(isnumeric(x) || islogical(x)));
            addParameter(p,'ColorMap',defaultColorMap);
            addParameter(p,'Label',defaultLabel,@iscell);
            addParameter(p,'nUniqueWeight',defaultnWeight,@isnumeric);
            parse(p,adjacencyMatrix,varargin{:});
            
            % Construct color maps. 
            NodeColorMap = feval(p.Results.ColorMap,max(degree)+1);
            Label    = p.Results.Label;
            EdgeColorMap = feval(p.Results.ColorMap,p.Results.nUniqueWeight);
            this.Label = Label;
            this.Degree = degree;
            
            % Construct 
            % Draw the temporary node.
            delete(this.Node);
            
            t = linspace(-pi,pi,nNodes+1).'; % theta for each node
            extent = zeros(nNodes,1);
            for i = 1:nNodes
                this.Node(i) = node(cos(t(i)),sin(t(i)));
                this.Node(i).Color = NodeColorMap(degree(i)+1,:);
                this.Node(i).Label = Label{i};
            end
            
            ax = gca;
            for i = 1:nNodes
                extent(i) = this.Node(i).Extent;
            end
            extent = max(extent(:));
            fudgeFactor = 3; % Not sure why this is necessary. Eyeballed it.
            ax.XLim = ax.XLim + fudgeFactor*extent*[-1 1];
            ax.YLim = ax.YLim + fudgeFactor*extent*[-1 1];
            set(gca,'XTick',[],'YTick',[],'Xcolor','none','Ycolor','none');
            ax.SortMethod = 'depth';
            colorbar('eastoutside');
            
            % Find non-zero values of s and their indices
            [row,col,weight] = find(adjacencyMatrix);
            
            % Calculate line widths based on values of s (stored in v).
            minLineWidth  = 0.5;
            lineWidthCoef = 2;
            lineWidth = weight./max(weight);
            if sum(lineWidth) == numel(lineWidth) % all lines are the same width.
                lineWidth = repmat(minLineWidth,numel(lineWidth),1);
            else % lines of variable width.
                lineWidth = lineWidthCoef*lineWidth + minLineWidth;
            end
            
            % Draw connections on the Poincare hyperbolic disk.
            weightSpace = linspace(0,1,p.Results.nUniqueWeight);
            [~,weightLoc] = min(abs(weightSpace - weight),[],2);
            for i = 1:numel(weight)
                weightColor = EdgeColorMap(weightLoc(i),:);
                lineData.cWeight = weightSpace(weightLoc(i));
                if row(i) ~= col(i)
                    if abs(row(i) - col(i)) - nNodes/2 == 0
                        % points are diametric, so draw a straight line
                        u = [cos(t(row(i)));sin(t(row(i)))];
                        v = [cos(t(col(i)));sin(t(col(i)))];
                        this.Node(row(i)).Connection(end+1) = line(...
                            [u(1);v(1)],...
                            [u(2);v(2)],...
                            'LineWidth', lineWidth(i),...
                            'Color', weightColor,...
                            'UserData',lineData);
                    else % points are not diametric, so draw an arc
                        u  = [cos(t(row(i)));sin(t(row(i)))];
                        v  = [cos(t(col(i)));sin(t(col(i)))];
                        x0 = -(u(2)-v(2))/(u(1)*v(2)-u(2)*v(1));
                        y0 =  (u(1)-v(1))/(u(1)*v(2)-u(2)*v(1));
                        r  = sqrt(x0^2 + y0^2 - 1);
                        thetaLim(1) = atan2(u(2)-y0,u(1)-x0);
                        thetaLim(2) = atan2(v(2)-y0,v(1)-x0);
                        
                        if u(1) >= 0 && v(1) >= 0
                            % ensure the arc is within the unit disk
                            theta = [linspace(max(thetaLim),pi,50),...
                                linspace(-pi,min(thetaLim),50)].';
                        else
                            theta = linspace(thetaLim(1),thetaLim(2)).';
                        end
                        
                        this.Node(row(i)).Connection(end+1) = line(...
                            r*cos(theta)+x0,...
                            r*sin(theta)+y0,...
                            'LineWidth', lineWidth(i),...
                            'Color', weightColor,...
                            'UserData',lineData);
                    end
                end
            end
            
        end
    end
end