function [] = create_parallelPool(numCores)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create_parallelPool creates a parallel processing pool using given number
% of CPU cores.
%
% Arguments:
%   numCores = Number of CPU cores to use
%
% Last edited by Emin Serin, 26.02.2022
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check maximum number of physical cores.
maxCores = feature('numCores');

% Init paralel pool.
if license('test','Distrib_Computing_Toolbox')
    if numCores <= maxCores
        if numCores > 1
            pool = gcp('nocreate');
            if isempty(pool)
                parpool(numCores, "IdleTimeout", 360);
            elseif pool.NumWorkers ~= numCores
                delete(pool);
                parpool(numCores, "IdleTimeout", 360);
            end
        elseif numCores < 1
            error('The number of parallel workers cannot less than 1!')
        end
    else
        error('The number of parallel cores cannot be more than %d\n', maxCores);
    end
else
    error('Parallel Computing Toolbox is not found!');
end

end


