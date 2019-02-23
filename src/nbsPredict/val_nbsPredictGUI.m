function [handles,nIdx] = val_nbsPredictGUI(handles)
%VALIDATE_GUI Summary of this function goes here
%   Detailed explanation goes here

tmp = fieldnames(handles);

% TextEdit objects
editfield = cellfun(@(x) all(ismember('Edit',x)),tmp);
editIdx = find(editfield);
nIdx = 0; 
for ii = 1:length(editIdx)
    cEdit = editIdx(ii);
    if isempty(handles.(tmp{cEdit}).String) || strcmpi(handles.(tmp{cEdit}).String,'EMPTY!')
        handles.(tmp{cEdit}).String = 'EMPTY!';
        nIdx = nIdx +1;
    end
end

end

