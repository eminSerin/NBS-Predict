function [edgeMat, nodes, edgeIdx] = load_corrMatFiles(corrMatDir, verbose)
% LOAD_CORRMATFILES Loads correlation matrices and extracts edge features.
%
% Loads all connectivity matrices from a directory into a single edge
% matrix of size (subjects x features), where features are upper-triangle
% edge values.
%
% Arguments:
%   corrMatDir - Directory containing correlation matrix files. All files
%                must be the same format (.mat, .csv, or .txt) and the same
%                dimensions.
%   verbose    - Logical flag to show loading progress (default: true).
%
% Output:
%   edgeMat - (subjects x features) matrix of edge values.
%   nodes   - Number of nodes.
%   edgeIdx - Linear indices of edges in the correlation matrix.
%
% Example:
%   corrMatDir = uigetdir('Select directory containing correlation matrices');
%   [edgeMat, nodes, edgeIdx] = load_corrMatFiles(corrMatDir);
%
% Last edited by Emin Serin, 14.05.2026.
%
% See also: loadData, shrinkMat

if nargin < 2
    verbose = true;
end

% Collect files and filter out directories and all dot-files (e.g.,
% .DS_Store, ._* resource forks, .gitkeep, Thumbs.db on Windows).
dataFiles = dir(corrMatDir);
names = {dataFiles.name};
isHidden = cellfun(@(n) startsWith(n, '.'), names);
dirFilter = ~[dataFiles.isdir] & ~isHidden;
dataFiles = dataFiles(dirFilter);

% Sort alphabetically to ensure consistent, OS-independent ordering.
[~, sortIdx] = sort({dataFiles.name});
dataFiles = dataFiles(sortIdx);

nFiles = length(dataFiles);

if nFiles == 0
    error('load_corrMatFiles:noFiles', ...
        'No connectivity matrix files found in directory: %s', corrMatDir);
end

if verbose
    prog = CmdProgress('Connectivity matrices are being loaded:', nFiles);
end

if nFiles > 1
    % Load the first file to determine matrix size, then preallocate.
    cData = loadData(dataFiles(1).name, corrMatDir);
    expectedSize = size(cData);
    data = zeros([expectedSize, nFiles], 'like', cData);
    data(:, :, 1) = cData;
    if verbose
        prog.increment;
    end

    % Load remaining files.
    try
        for i = 2:nFiles
            cData = loadData(dataFiles(i).name, corrMatDir);

            % Validate dimensions match across files.
            assert(isequal(size(cData), expectedSize), ...
                'load_corrMatFiles:dimensionMismatch', ...
                ['Matrix in "%s" has size [%s] but expected [%s]. ' ...
                 'All matrices must have the same dimensions.'], ...
                dataFiles(i).name, num2str(size(cData)), num2str(expectedSize));

            data(:, :, i) = cData;
            if verbose
                prog.increment;
            end
        end
    catch ME
        error('load_corrMatFiles:loadError', ...
            ['Error loading correlation matrices.\n' ...
             'File: %s\n' ...
             'Cause: %s\n' ...
             'Please check the sample dataset for the expected data structure.'], ...
            fullfile(corrMatDir, dataFiles(i).name), ME.message);
    end

else
    % Single-file case.
    data = loadData(dataFiles(1).name, corrMatDir);
    if verbose
        prog.increment;
    end
end

if verbose
    fprintf('Loaded matrices are being shrunk into a single edge matrix...\n')
end

% Shrink data into edge matrix.
[edgeMat, nodes, edgeIdx] = shrinkMat(data);
end
