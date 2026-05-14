function cData = loadData(file, path)
% LOADDATA Loads data for NBSPredict. Supports .csv, .txt, and .mat files.
%
% Arguments:
%   file - File name (with extension).
%   path - File path (optional). If omitted, 'file' is treated as the full
%          path.
%
% Output:
%   cData - Loaded data as a numeric matrix (double).
%
% Example:
%   cData = loadData('connectome.mat', '/data/subject01/');
%   cData = loadData('/data/subject01/connectome.mat');
%
% Notes:
%   - .mat files must contain exactly one variable.
%   - .csv and .txt files are expected to contain purely numeric data.
%
% Last edited by Emin Serin, 14.05.2026.
%
% See also: load_corrMatFiles

if nargin < 2
    fileName = file;
else
    fileName = fullfile(path, file);
end

% Validate file exists before any further processing.
assert(exist(fileName, 'file') == 2, ...
    'loadData:fileNotFound', 'File does not exist: %s', fileName);

[~, ~, ext] = fileparts(fileName);

switch lower(ext)
    case '.mat'
        tmp = load(fileName);
        fields = fieldnames(tmp);
        assert(numel(fields) == 1, ...
            'loadData:multipleVars', ...
            ['MAT file "%s" contains %d variables; expected exactly 1. ' ...
             'Variables found: %s'], ...
            fileName, numel(fields), strjoin(fields, ', '));
        cData = tmp.(fields{1});

    case {'.csv', '.txt'}
        % readmatrix returns a plain double array for numeric files.
        cData = readmatrix(fileName);

    otherwise
        error('loadData:unsupportedFormat', ...
            ['Unrecognized file extension "%s". ' ...
             'Supported formats: .mat, .csv, .txt'], ext);
end
end