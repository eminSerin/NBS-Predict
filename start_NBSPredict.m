function [] = start_NBSPredict(varargin)
% start_NBSPredict shows welcome message to user and run NBSPredict
% toolbox. It bypasses and immediately starts analyzing the data if a
% configuration file is provided (please check MANUAL to see how to create
% a configuration file). If any configuration file provided,
% start_NBSPredict opens graphical user interface to deliver user inputs to
% run analysis.
%
% Arguments: 
%   NBSPredict - Structure including configurations for NBSPredict to run
%       (please check MANUAL for correct structure).
% 
% Example:
%   start_NBSPredict();
%   start_NBSPredict(NBSPredict);
%
%   Copyright (C) 2019
% 
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
% 
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License
%   along with this program. If not, see <http://www.gnu.org/licenses/>.
%
%   Release : 1.0.0-beta1
%   Mail to Author: eminserinn@gmail.com
%
% See also: run_NBSPredictGUI, run_NBSPredict, test_NBSPredict

verNBSPredict = '1.0.0-beta2';

welcomeMsg = ['\n\n\nWelcome to NBSPredict\n',...
    'Release: <strong>%s</strong> \n',...
    'NBS-Predict was designed by Emin Serin, Andrew Zalesky, Johann Kruschwitz and Henrik Walter, and developed by Emin Serin\n',...
    'Berlin School of Mind and Brain, Humboldt Universtaet zu Berlin, Germany\n',...
    'Melbourne Neuropsychiatry Centre and Department of Biomedical Engineering, University of Melbourne, Australia\n',...
    'Division of Mind and Brain Research, Department for Psychiatry, Charite Berlin, Germany\n\n',...
    'Sample data is available at: <a href="https://www.nitrc.org/docman/view.php/1517/179438/">NITRC</a>\n',...
    'Mail to Author: <a href="emin.serin@charite.de">Emin Serin</a>\n\n',...
    'Reference:\n',...
    '\tSerin, E., Zalesky, A., Matory, A., Walter, H., & Kruschwitz, J. D. (2021).\n',...
    '\tNBS-Predict: A Prediction-based Extension of the Network-based Statistic. NeuroImage, 118625.\n\n'];

fprintf(welcomeMsg,verNBSPredict);

% Check if a configuration file provided. 
if ~isempty(varargin)
    assert(~(nargin > 1), 'Too much input provided! Please check help section!');
    fprintf('\nConfiguration file is provided. Configuration file is being checked...\n\n')
    run_NBSPredict(varargin{:});
else
    fprintf('\nNBS-Predict GUI is starting...\n\n')
    run_NBSPredictGUI();
end

end

