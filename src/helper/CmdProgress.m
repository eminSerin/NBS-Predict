classdef CmdProgress < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CmdProgress writes progress of a process on the command window.
    %
    % Attributes:
    %   base_msg: Message to be shown on the command window.
    %   total_iter: Total number of iterations.
    %
    % Example: 
    %   msg = 'Iteration is progressing:'
    %   prog = CmdProgress(msg, n_total);
    %   for i = 1 : n_total
    %       pause(0.1);
    %       prog.increment;
    %   end
    %
    % Emin Serin
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties (Access = private)
       reverse_str 
    end
    
    properties
        base_msg
        total_iter
        c_percent
        c_iter
    end
    
    methods
        function obj = CmdProgress(base_msg, total_iter)
            % cmd_progress construct an instance of this class
            % Show progress in percentiles on the command window.
            
            % Check if message type is string. 
            assert(ischar(base_msg), 'Message must be string!')
            
            % Set properties.
            obj.base_msg = base_msg;
            obj.total_iter = total_iter; 
            obj.c_iter = 0;
            obj.c_percent = 0;
            obj.reverse_str = '';
        end
        
        function increment(obj)
            % Increment the percentage done. 
            obj.c_iter = obj.c_iter + 1;
            obj.c_percent = (obj.c_iter/obj.total_iter)*100;
            msg = sprintf([obj.base_msg, ' %.1f percent done.'],...
                obj.c_percent);
            fprintf([obj.reverse_str, msg]);
            obj.reverse_str = repmat(sprintf('\b'), 1, length(msg));
            
            if obj.c_iter == obj.total_iter
               fprintf('\n'); 
            end
        end
    end
end

