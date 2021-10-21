function [edgeMat,nodes,edgeIdx] = load_corrMatFiles(corrMatDir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load_corrMatFiles loads correlation matrices into a data matrix and extract
% values of edges into a single NxF matrix where N is subjects, and F is
% features. Correlation matrices can be .txt or .mat. However, all
% correlation matrices must be same format!
%
% Arguments:
%   corrMatDir: Directory where correlation matrices locate. Make sure that
%   all correlation matrices in the directory given!
%
% Output:
%   edgeMat: Matrix of edges shrinked from subjects' correlation matrices.
%   nodes: number of nodes.
%   edgeIdx: Indices of edges found in participants correlation matrix. 
%
% Example: 
%   corrMatDir = uigetdir('Please locate directory where correlation matrices found!');
%   [edgeMat,nodes,edgeIdx] = load_corrMatFiles(corrMatDir)
%
% Emin Serin - 22.08.2019
%
% See also: loadData, shrinkMat 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter out . dir and '.DS_Store' which might be found in MacOS
% directories.
dataFiles = dir(corrMatDir);
dirFilter = ~logical(strcmpi({dataFiles.name},'.DS_Store') + [dataFiles.isdir]);
dataFiles = dataFiles(dirFilter); 
filePath = [corrMatDir,filesep];
% Load all data files into a structure.
nFiles = length(dataFiles);
% Preallocate 
cData = loadData(dataFiles(1).name,filePath);
data = zeros([size(cData),nFiles],'single');
for i = 1:nFiles
    cData = loadData(dataFiles(i).name,filePath);
    data(:,:,i) = cData;
end

% Shrinks data into edge matrix.
[edgeMat,nodes,edgeIdx] = shrinkMat(data);

end

