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
% Created by Emin Serin, 04.09.2019
%
% See also: load_corrMatFiles 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
if nargin == 1
    % Use file if only file provided. 
    fileName = file;
else
    fileName = [path,file]; % create full file name. 
end
[~,~,ext] = fileparts(fileName); % get file format. 

switch ext
    case '.mat'
        % if mat file.
        tmp = load(fileName);
        field = fieldnames(tmp);
        cData = tmp.(field{:});
    case '.csv'
        cData = readtable(fileName);
        try 
            cData = table2array(cData);
        end
end
end