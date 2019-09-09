function varargout = view_NBSPredict(varargin)
% VIEW_NBSPREDICT MATLAB code for view_NBSPredict.fig
%      VIEW_NBSPREDICT, by itself, creates a new VIEW_NBSPREDICT or raises the existing
%      singleton*.
%
%      H = VIEW_NBSPREDICT returns the handle to a new VIEW_NBSPREDICT or the handle to
%      the existing singleton*.
%
%      VIEW_NBSPREDICT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW_NBSPREDICT.M with the given input arguments.
%
%      VIEW_NBSPREDICT('Property','Value',...) creates a new VIEW_NBSPREDICT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before view_NBSPredict_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to view_NBSPredict_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help view_NBSPredict

% Last Modified by GUIDE v2.5 08-Sep-2019 20:25:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @view_NBSPredict_OpeningFcn, ...
    'gui_OutputFcn',  @view_NBSPredict_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before view_NBSPredict is made visible.
function view_NBSPredict_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to view_NBSPredict (see VARARGIN)
% Choose default command line output for view_NBSPredict

welcomeMsg = ['\nWelcome to NBS-Predict GUI!\n',...
    'NBS-Predict GUI is graphical user interface to deliver user input and run NBS-Predict.\n',...
    'Please check MANUAL by clicking Help button!\n\n'];

fprintf(welcomeMsg);

handles.output = hObject;
if isempty(varargin)
    % Ask to load NBSPredict file if no provided. 
    [NBSPredictFile, path] = uigetfile('*.mat',...
        'Please select NBSPredict structure saved by NBS-Predict toolbox at the end of the analysis.');
    NBSPredict = load([path NBSPredictFile]);
    NBSPredict = NBSPredict.NBSPredict;
else
    NBSPredict = varargin{1};
end
handles.plotData = NBSPredict.results;
handles.plotData.MLmodels = NBSPredict.parameter.MLmodels;
handles.plotData.brainRegions = NBSPredict.data.brainRegions;
handles.plotData.nodes = NBSPredict.data.nodes;
handles.plotData.edgeIdx = NBSPredict.data.edgeIdx;
handles.plotData.ifPlotScaled = 0;
handles.ifShowLabel = 0;

if isfield(NBSPredict.results,'bestEstimator')
    handles.cModel = handles.plotData.bestEstimator;
else
    handles.cModel = handles.plotData.MLmodels{1};
end

% Set MLmodelPop handle.
set(handles.MLmodelsPop,'String',handles.plotData.MLmodels);

% Update handles structure
handles.plotResults.wThresh = 0;
handles.cFig = 'adj';
set(0, 'CurrentFigure', handles.viewNBSPredictFig);
handles = plotUpdatedData(handles);
guidata(hObject, handles);


% UIWAIT makes view_NBSPredict wait for user response (see UIRESUME)
% uiwait(handles.viewNBSPredictFig);


% --- Outputs from this function are returned to the command line.
function varargout = view_NBSPredict_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function thresholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresholdEdit as text
%        str2double(get(hObject,'String')) returns contents of thresholdEdit as a double
handles.plotResults.wThresh = str2double(get(hObject,'String'));
[handles] = plotUpdatedData(handles); % Update and plot. 
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function thresholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.plotResults.wThresh = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes on button press in adjacencyPush.
function adjacencyPush_Callback(hObject, eventdata, handles)
% hObject    handle to adjacencyPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.labelButton.Visible = 'off';
handles.cFig = 'adj';
imagesc(handles.plotResults.adj);
colormap(parula);
colorbar;
caxis([0,1])
set(gca,'XTick',[],'YTick',[]);
title(sprintf('Score: %.3f',handles.plotData.(handles.cModel).meanRepCVscore))
dcm_obj = datacursormode(gcf);
set(dcm_obj,'Enable','on','UpdateFcn',{@dataCursorUpdateFun,handles});
guidata(hObject,handles)

% --- Executes on button press in networkPush.
function networkPush_Callback(hObject, eventdata, handles)
% hObject    handle to networkPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.labelButton.Visible = 'on';
if handles.ifShowLabel
    labels = handles.plotResults.labels;
else
    labels = [];
end
plot(handles.plotResults.G,'EdgeCData',handles.plotResults.G.Edges.Weight,...
    'MarkerSize',degree(handles.plotResults.G),'LineWidth',3,...
    'NodeLabel',labels);
title(sprintf('Score: %.3f',handles.plotData.(handles.cModel).meanRepCVscore))
set(gca,'XTick',[],'YTick',[]);
colorbar;
caxis([0,1])
handles.cFig = 'net';
dcm_obj = datacursormode(gcf);
set(dcm_obj,'Enable','on','UpdateFcn',{@dataCursorUpdateFun,handles});
guidata(hObject,handles)

% --- Executes on button press in distPush.
function distPush_Callback(hObject, ~, handles)
% hObject    handle to distPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.labelButton.Visible = 'off';
ifScaled = handles.plotData.ifPlotScaled; 
cModel = handles.cModel;
if ifScaled
    histData = handles.plotData.(cModel).scaledMeanEdgeWeight;
else
    histData = handles.plotData.(cModel).meanEdgeWeight;
end
histData(histData == 0) = [];
minHistData = min(histData);
hist(histData,50);
xlabel('Weight')
handles.distYlabel = ylabel('Number of Edges');
xlim([minHistData,1])
title(sprintf('Score: %.3f',handles.plotData.(handles.cModel).meanRepCVscore))
handles.cFig = 'dist';
dcm_obj = datacursormode(gcf);
set(dcm_obj,'Enable','on','UpdateFcn',{@dataCursorUpdateFun,handles});
guidata(hObject,handles)

% --- Executes on button press in brainNetPush.
function brainNetPush_Callback(hObject, eventdata, handles)
% hObject    handle to brainNetPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.labelButton.Visible = 'on';
configFile = 'brainNetViewerConfig.mat';
tmpDir = which(configFile);
tmpDir = tmpDir(1:end-numel(configFile));
brainRegions = handles.plotData.brainRegions;
brainRegions(:,4) = []; brainRegions(:,4) = table(1);
brainRegions(:,5) = table(0);
brainRegions(~handles.plotResults.mask,5) = table(handles.plotResults.G.degree);
if handles.ifShowLabel
    brainRegions(:,6) = handles.plotData.brainRegions.labels;
end
dlmcell([tmpDir,'tmp.node'],table2cell(brainRegions),'\t');
dlmcell([tmpDir,'tmp.edge'],num2cell(handles.plotResults.adj),'\t');
handles.brainNetFig = BrainNet_MapCfg('BrainMesh_ICBM152_smoothed.nv',[tmpDir,'tmp.node'],[tmpDir,'tmp.edge'],'brainNetViewerConfig.mat');
guidata(hObject,handles)

% --- Executes during object deletion, before destroying properties.
function figureAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figureAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object deletion, before destroying properties.
function figureAxes_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figureAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveFigurePush.
function saveFigurePush_Callback(hObject, eventdata, handles)
% hObject    handle to saveFigurePush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
formatFiltes = {'*.pdf','PDF';'*.fig','Matlab Figure';'*.jpeg','JPEG 24-bit';...
    '*.png','PNG 24-bit';'*.tiff','TIFF 24-bit';'*.tiff','TIFF 24-bit UNCOMPRESSED';...
    '*.eps','EPS Level 3 color';'*.svg','SVG'};
[figFileName, figFilePath, filterIdx] = uiputfile(formatFiltes);

if ~(figFilePath==0)
    fullFileName = [figFilePath,figFileName];
    saveFigH = figure('Visible','off','PaperUnits','centimeters','Units','centimeters');
    copyobj(handles.figureAxes,saveFigH);
    pos=get(saveFigH,'Position');
    if strcmpi(handles.cFig,'dist')
        % Specific configs for distribution figure. 
        yLabelH = ylabel(handles.distYlabel);
        yLabelPos = yLabelH.Position;
        yLabelH.Position = [yLabelPos(1)*.7, yLabelPos(2), yLabelPos(3)];
        set(saveFigH,'PaperSize', [pos(3)*.80 pos(4)*1.02],...
            'PaperPositionMode', 'manual','PaperPosition',[0.4 0.5 pos(3) pos(4)]);
    else
        % Configs for other figures.
        set(saveFigH,'PaperSize', [pos(3)*.75 pos(4)],...
            'PaperPositionMode', 'manual','PaperPosition',[0 0 pos(3) pos(4)]);
    end
    if ismember(handles.cFig,{'adj','net'})
        % Add colorbar if adjacency or network plots are to be printed.
        colorbar; 
    end
    if filterIdx == 2
        % Save as figure.
        set(saveFigH,'Visible','on');
        saveas(saveFigH,fullFileName,'fig');
    else
        if filterIdx == 6
            fileFormat = 'tiffn';
        elseif filterIdx == 7
            fileFormat = 'epsc';
        else    
            fileFormat = formatFiltes{filterIdx,1};
            fileFormat = fileFormat(3:end);
        end
        fileFormat = ['-d',fileFormat];
        print(saveFigH,fullFileName,fileFormat,'-r0');
    end
    close(saveFigH)
    clear saveFigH
end


% --- Executes on button press in saveTablePush.
function saveTablePush_Callback(hObject, eventdata, handles)
% hObject    handle to saveTablePush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
formatFiltes = {'*.mat','Matlab File (.mat)';'*.csv','CSV (.csv)';...
    '*.xlsx','Excel file (.xlsx)';'*.txt','Text file (.txt)'};
[tableFileName, tableFilePath, filterIdx] = uiputfile(formatFiltes,...
    'Save Degree Table Name',...
    ['degreeTable_',num2str(handles.plotResults.wThresh)]);
if ~(tableFilePath==0)
    fullFileName = [tableFilePath,tableFileName];
    T = table;
    T.Regions = handles.uitable1.Data(:,1);
    T.Degree = handles.uitable1.Data(:,2);
    if filterIdx == 1
        save(fullFileName,'T');
    else
        writetable(T,fullFileName);
    end
end

% --- Executes on selection change in MLmodelsPop.
function MLmodelsPop_Callback(hObject, eventdata, handles)
% hObject    handle to MLmodelsPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MLmodelsPop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MLmodelsPop
cModelIdx = get(hObject,'Value');
handles.cModel= handles.plotData.MLmodels{cModelIdx};

% Update handles structure and plot
handles = plotUpdatedData(handles);

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function MLmodelsPop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MLmodelsPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in minMaxButton.
function minMaxButton_Callback(hObject, eventdata, handles)
% hObject    handle to minMaxButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of minMaxButton
ifPlotScaled = get(hObject,'Value');
handles.plotData.ifPlotScaled = ifPlotScaled;

% Update data and plot.
handles = plotUpdatedData(handles);

guidata(hObject,handles)

% --- Executes on button press in labelButton.
function labelButton_Callback(hObject, eventdata, handles)
% hObject    handle to labelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of labelButton
ifShowLabel = get(hObject,'Value');
handles.ifShowLabel = ifShowLabel;
if strcmpi(handles.cFig,'net')
    networkPush_Callback(handles.networkPush,[],handles);
end
if isfield(handles,'brainNetFig') && isgraphics(handles.brainNetFig)
    pause(0.1)
    brainNetPush_Callback(handles.brainNetPush, [], handles);
end
guidata(hObject,handles)


%% Helper functions
function [adjDataCursorTxt] = dataCursorUpdateFun(~,event_obj,handles)
% dataCursorUpdateFun returns information for given data cursor position. 
pos = get(event_obj,'Position');
switch handles.cFig
    case 'adj'
        weightTable = handles.plotResults.weightTable;
        cWeight = weightTable.Weight(find(weightTable.X == pos(1) & weightTable.Y == pos(2)));
        if isempty(cWeight)
            cWeight = 0;
        end
        adjDataCursorTxt = {sprintf('Regions: [%s, %s]',...
            handles.plotData.brainRegions.labels{pos(1)},...
            handles.plotData.brainRegions.labels{pos(2)}),...
            ['Weight: ',num2str(cWeight,4)]};
    case 'net'
        graphHandle = get(event_obj,'Target');
        nodeIdx = find(graphHandle.XData == pos(1) & graphHandle.YData == pos(2), 1);
        cDegree = handles.plotResults.G.degree(nodeIdx);
        nodeName = handles.plotResults.labels(nodeIdx);
        adjDataCursorTxt = {['Region: ',nodeName{:}],...
            ['Nodal degree: ',num2str(cDegree)]};
    case 'dist'
        nodeCount = pos(2);
        adjDataCursorTxt = {['Edge Count: ',num2str(nodeCount)]};
end

function [handles] = plotUpdatedData(handles)
% plotUpdateData updates data with regards to parameter in handles given
% and plots it into current figure axis.
if handles.plotData.ifPlotScaled
    [handles.plotResults.adj,handles.plotResults.G,handles.plotResults.labels,handles.plotResults.mask] =...
        update_NBSPredictFigure(handles.plotData.(handles.cModel).scaledWAdjMat,...
        handles.plotData.brainRegions.labels,handles.plotResults.wThresh);
else
    [handles.plotResults.adj,handles.plotResults.G,handles.plotResults.labels,handles.plotResults.mask] =...
        update_NBSPredictFigure(handles.plotData.(handles.cModel).wAdjMat,...
        handles.plotData.brainRegions.labels,handles.plotResults.wThresh);
end
% Create weight table to access edge weights easily. 
weightTable = table; 
[weightTable.X,weightTable.Y,weightTable.Weight] = find(handles.plotResults.adj);
handles.plotResults.weightTable = weightTable;
% Plots thresholded data.
switch handles.cFig
    case 'adj'
        adjacencyPush_Callback(handles.adjacencyPush,[],handles);
    case 'net'
        networkPush_Callback(handles.networkPush,[],handles);
    case 'dist'
        distPush_Callback(handles.distPush,[],handles);
        
end
if isfield(handles,'brainNetFig') && isgraphics(handles.brainNetFig)
    pause(0.1)
    brainNetPush_Callback(handles.brainNetPush, [], handles);
end
handles.uitable1.Data = table2cell(table(handles.plotResults.labels,...
    degree(handles.plotResults.G)));



% --- Executes during object deletion, before destroying properties.
function viewNBSPredictFig_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to viewNBSPredictFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
goodbyeMsg = ['\nThank you for using NBS-Predict!\n',...
    'Please contact to eminserinn@gmail.com for any questions, suggestions or bug reports.\n'];
fprintf(goodbyeMsg);


