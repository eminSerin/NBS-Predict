function [cData] = loadData(file,path)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loadData loads data for NBSPredict. It only supports .csv or .mat files.
%
% Arguments: 
%   file = File name.  
%   path = File path. 
%
% Output:
%   cData = Data important from structure. 
%
% Example:
%   [cData] = loadData(file,path);
%
% Last edited by Emin Serin, 18.02.2022.
%
% See also: load_corrMatFiles 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
if nargin == 1
    % Use file if only file provided. 
    fileName = file;
else
    fileName = fullfile(path, file); % create full file name. 
end
[~,~,ext] = fileparts(fileName); % get file format. 

assert(exist(fileName, 'file') == 2, 'The file does not exist!');

switch ext
    case '.mat'
        % if mat file.
        tmp = load(fileName);
        field = fieldnames(tmp);
        cData = tmp.(field{:});
    case '.csv'
        cData = readtable(fileName);
    otherwise
        error('Unrecognized file extension! Connectome file must be .csv or .mat!');
end
end