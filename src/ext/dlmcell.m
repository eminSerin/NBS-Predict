function dlmcell(file,cell_array,varargin)
%% <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> %%
% <><><><><>     dlmcell - Write Cell Array to Text File      <><><><><> %
% <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> %
%                                                                        %
%                                                            Version 1.3 %
%                             (c) Roland Pfister, www.roland-pfister.net %
%                                                                        %
% ...with many thanks to George Papazafeiropoulos, Frederik, Gabriel     %
% Vargas, and Andrew Ferrell for corrections and improvements. Special   %
% thanks to Andrew for putting it all together.                          %
%                                                                        %
% 1. Synopsis                                                            %
%                                                                        %
% A single cell array is written to an output file. Cells may consist of %
% any combination of (a) numbers, (b) letters, or (c) words. The inputs  %
% are as follows:                                                        %
%                                                                        %
%       - file       The output filename (string).                       %
%       - cell_array The cell array to be written.                       %
%       - delimiter  Delimiter symbol, e.g. ',' (optional)               %
%                    default: tab ('\t'}).                               %
%       - append     '-a' for appending the content to the               %
%                    output file (optional).                             %
%                                                                        %
% 2. Example                                                             %
%                                                                        %
%         mycell = {'Numbers', 'Letters', 'Words','More Words'; ...      %
%                    1, 'A', 'Apple', {'Apricot'}; ...                   %
%                    2, 'B', 'Banana', {'Blueberry'}; ...                %
%                    3, 'C', 'Cherry', {'Cranberry'}; };                 %
%         dlmcell('mytext.txt',mycell);                                  %
%                                                                        %
% <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> %
%% Check input arguments
if nargin < 2
    error('Error - Give at least two input arguments!')
elseif nargin > 4
    error('Error - Do not give more than 4 input arguments!')
end
if ~ischar(file)
    error('Error - File input has to be a string (e.g.''output.txt'')!')
end
if ~iscell(cell_array)
    error('Error - Input cell_array not of the type "cell"!')
end
delimiter = '\t';
append = 'w';
if nargin > 2
    for i = 1:size(varargin,2)
        if strcmp('-a',varargin{1,i}) == 1
            append = 'a';
        else
            delimiter = varargin{1,i};
        end
    end
end
%% Open output file and prepare output array.
output_file = fopen(file,append);
output = cell(size(cell_array,1),size(cell_array,2));
%% Evaluate and write input array.
for i = 1:size(cell_array,1)
    for j = 1:size(cell_array,2)
        if numel(cell_array{i,j}) == 0
            output{i,j} = '';
            % Check whether the content of cell i,j is
            % numeric and convert numbers to strings.
        elseif isnumeric(cell_array{i,j}) || islogical(cell_array{i,j})
            output{i,j} = num2str(cell_array{i,j}(1,1));
            % Check whether the content of cell i,j is another cell (e.g. a
            % string of length > 1 that was stored as cell. If cell sizes
            % equal [1,1], convert numbers and char-cells to strings.
            %
            % Note that any other cells-within-the-cell will produce errors
            % or wrong results.
        elseif iscell(cell_array{i,j})
            if size(cell_array{i,j},1) == 1 && size(cell_array{i,j},2) == 1
                if isnumeric(cell_array{i,j}{1,1}) || islogical(cell_array{i,j}{1,1})
                    output{i,j} = num2str(cell_array{i,j}{1,1}(1,1));
                elseif ischar(cell_array{i,j}{1,1}) || isstring(cell_array{i,j}{1,1})
                    output{i,j} = cell_array{i,j}{1,1};
                elseif isdatetime(cell_array{i,j}{1,1})
                    output{i,j} = datestr(cell_array{i,j}{1,1});
                end
            end
        elseif ischar(cell_array{i,j}) || isstring(cell_array{i,j})
            output{i,j} = cell_array{i,j};
        elseif isdatetime(cell_array{i,j})
            output{i,j} = datestr(cell_array{i,j});
        end
        % Cell i,j is written to the output file. A delimiter is appended for
        % all but the last element of each row. At the end of a row, a newline
        % is written to the output file.
        if j < size(cell_array,2)
            fprintf(output_file,['%s',delimiter],output{i,j});
        else
            fprintf(output_file,'%s\r\n',output{i,j});
        end
    end
end
%% Close output file.
fclose(output_file);
end