function [edgeMat,nodes,edgeIdx] = load_nbsPredictFiles(NBSPredict)
%   LOAD_NBSPREDICTFILES Summary of this function goes here
%   Detailed explanation goes here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   loadFiles loads correlation matrices in .mat or .txt formats. Shrinks
        %       edges into a single matrix used in further steps of analysis.
        %   Input:
        %       Subjects correlation matrices in .txt or .mat format.
        %   Output:
        %       edgeMat: Matrix of edges shrinked from subjects' correlation
        %           matrices.
        %       nodes: number of nodes.
        %       subjects: number of subjects.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Load all data files into a structure.
        nfiles = length(NBSPredict.files);
        for i = 1:nfiles
            cfile = NBSPredict.files{i};
            tmp = load([NBSPredict.path cfile]);
            if strcmpi(cfile(end-2:end),'mat')
                % if mat file.
                fname = fieldnames(tmp);
                data(:,:,i) = tmp.(fname{:});
            else
                % text file.
                data(:,:,i) = tmp;
            end
        end
        
        % Shrinks edges to a single matrix.
        [nodes,~,subjects] = size(data);
        edgeIdx = find(triu(ones(nodes,nodes),1)); % finds edge indices.
        edgeMat = zeros(subjects,length(edgeIdx)); % pre-allocate.
        for i = 1:subjects
            tmp = data(:,:,i);
            edgeMat(i,:)=tmp(edgeIdx);
        end
end

