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

% Last Modified by GUIDE v2.5 21-Jan-2020 17:02:29

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
    if isstring(varargin{1}) || ischar(varargin{1})
        assert(exist(varargin{1}, 'file') == 2, 'The input file is not found!')
        load(varargin{1})
    else
        NBSPredict = varargin{1};
    end
end
handles.plotData = NBSPredict.results;
handles.plotData.MLmodels = NBSPredict.parameter.MLmodels;
handles.plotData.brainRegions = NBSPredict.data.brainRegions;
handles.plotData.X = NBSPredict.data.X;
handles.plotData.y = NBSPredict.data.y;
handles.plotData.nodes = NBSPredict.data.nodes;
handles.plotData.edgeIdx = NBSPredict.data.edgeIdx;
handles.plotData.ifPlotScaled = 1;
handles.ifShowLabel = 0;
handles.plotData.confounds = NBSPredict.data.confounds;
handles.plotData.scalingMethod = NBSPredict.parameter.scalingMethod;
if isfield(NBSPredict.results,'bestEstimator')
    cModel = handles.plotData.bestEstimator;
else
    cModel = handles.plotData.MLmodels{1};
end
handles.cModel = cModel;
y = NBSPredict.data.y;

ifClass = check_classification(y);
handles.ifClass = ifClass;
metric = NBSPredict.parameter.metric;
handles.plotData.metric = metric;
handles.plotResults.metric = metric;
handles.plotResults.truePredLabels = handles.plotData.(cModel).truePredLabels;
if ifClass
    handles.confMatPush.Visible = 'on';
    handles =  updateConfMat(handles);
    metrics = {'Accuracy','Balanced_Accuracy','Sensitivity','Specificity',...
        'Precision','Recall','F1','Matthews_CC','Cohens_Kappa','AUC'};
    set(handles.metricPopUp,'String',metrics);
else
    metrics = {'MSE','RMSE','Correlation','R_squared','Explained_Variance','MAD'};
    set(handles.metricPopUp,'String',metrics);
end
[~,metricLoc] = ismember(handles.plotData.metric,lower(metrics));
if metricLoc
    set(handles.metricPopUp,'Value',metricLoc);
end


% figureTitle = sprintf('%s: %.3f (%.3f, %.3f)',...
%     [upper(metric(1)),metric(2:end)],...
%     handles.plotData.(handles.cModel).meanRepCVscore,...
%     handles.plotData.(handles.cModel).meanCVscoreCI);
% 
% if isfield(handles.plotData.(handles.cModel), 'permScore')
%     permScore = handles.plotData.(handles.cModel).permScore;
%     figureTitle = sprintf([figureTitle, ' Permutation: %.3f, p = %.3f'],...
%         permScore(1), permScore(2));
% end
% handles.figureTitle = figureTitle;

% Set MLmodelPop handle.
set(handles.MLmodelsPop,'String',handles.plotData.MLmodels);
MLmodelLoc = find(strcmpi(cModel, handles.plotData.MLmodels));
set(handles.MLmodelsPop,'Value',MLmodelLoc);

% Update handles structure
handles.plotResults.wThresh = 0;
handles.cFig = 'adj';
set(0, 'CurrentFigure', handles.viewNBSPredictFig);
handles = updateTitle(handles);
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
wBar = waitbar(0, 'Opening...');
set(0, 'CurrentFigure', handles.viewNBSPredictFig);
handles.labelButton.Visible = 'off';
handles.cFig = 'adj';
imagesc(handles.figureAxes,handles.plotResults.adj);
colormap(parula);
colorbar;
caxis([0,1])
set(gca,'XTick',[],'YTick',[]);
title(handles.figureTitle,'Interpreter','none');
% set(gca, 'FontSize',10,'FontName','default');
dcm_obj = datacursormode(gcf);
set(dcm_obj,'Enable','on','UpdateFcn',{@dataCursorUpdateFun,handles});
if ~verLessThan('matlab', '9.5')
    % Turn off the text interpreter if MATLAB version is or newer than
    % R2018b.
    set(dcm_obj, 'Interpreter','none'); 
end
[handles] = pcFontSize(handles);
guidata(hObject,handles)
waitbar(1, wBar, 'Done!');
close(wBar);

% --- Executes on button press in networkPush.
function networkPush_Callback(hObject, eventdata, handles)
% hObject    handle to networkPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wBar = waitbar(0, 'Opening...');
set(0, 'CurrentFigure', handles.viewNBSPredictFig);
handles.labelButton.Visible = 'on';
cla reset;
set(gca,'DefaultTextInterpreter','none');
title(handles.figureAxes,handles.figureTitle);
axes(handles.figureAxes);
nWeight = numel(unique(handles.plotData.(handles.cModel).scaledMeanEdgeWeight));
if handles.ifShowLabel
    labels = handles.plotData.brainRegions.labels;
    cG = circularGraph(handles.plotResults.adj,'Label',labels,'nUniqueWeight',nWeight);
else
    cG = circularGraph(handles.plotResults.adj);
end
handles.cFig = 'net';
dcm_obj = datacursormode(gcf);
set(dcm_obj,'Enable','on','UpdateFcn',{@dataCursorUpdateFun,handles});
if ~verLessThan('matlab', '9.5')
    % Turn off the text interpreter if MATLAB version is or newer than
    % R2018b.
    set(dcm_obj, 'Interpreter','none'); 
end
[handles] = pcFontSize(handles);
setappdata(handles.uipanel1,'cG',cG);
guidata(hObject,handles)
waitbar(1, wBar, 'Done!');
close(wBar);

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
handles.brainNetFig = BrainNet_MapCfg('BrainMesh_ICBM152_smoothed.nv',...
    [tmpDir,'tmp.node'],[tmpDir,'tmp.edge'],'brainNetViewerConfig.mat');
[handles] = pcFontSize(handles);
guidata(hObject,handles)


% --- Executes on button press in confMatPush.
function confMatPush_Callback(hObject, eventdata, handles)
% hObject    handle to confMatPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% https://stackoverflow.com/questions/33451812/plot-confusion-matrix
handles.cFig = 'confMat';
datacursormode off;
truePredLabels = handles.plotResults.truePredLabels;
confmat = handles.plotResults.confMat;
labels = unique(truePredLabels);
numlabels = size(confmat, 1); % number of labels
% calculate the percentage accuracies
confpercent = 100*confmat./repmat(sum(confmat, 1),numlabels,1);
% plotting the colors
imagesc(confpercent);
ylabel('Predicted'); xlabel('Actual');
% set the colormap
colormap(flipud(gray));
% Create strings from the matrix values and remove spaces
textStrings = num2str([confpercent(:), confmat(:)], '%.1f%%\n%d\n');
textStrings = strtrim(cellstr(textStrings));
% Create x and y coordinates for the strings and plot them
[x,y] = meshgrid(1:numlabels);
hStrings = text(x(:),y(:),textStrings(:), ...
    'HorizontalAlignment','center');
% Get the middle value of the color range
midValue = mean(get(gca,'CLim'));
% Choose white or black for the text color of the strings so
% they can be easily seen over the background color
textColors = repmat(confpercent(:) > midValue,1,3);
set(hStrings,{'Color'},num2cell(textColors,2));
% Setting the axis labels
set(gca,'XTick',1:numlabels,...
    'XTickLabel',labels,...
    'YTick',1:numlabels,...
    'YTickLabel',labels,...
    'TickLength',[0 0]);
title(handles.figureTitle,'Interpreter','none'); ;
[handles] = pcFontSize(handles);
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
formatFiltes = {'*.pdf','PDF';'*.fig','Matlab Figure';...
    '*.jpeg','JPEG 24-bit';'*.jpeg','JPEG 24-bit 1000 dpi';...
    '*.png','PNG 24-bit';'*.tiff','TIFF 24-bit';};
[figFileName, figFilePath, filterIdx] = uiputfile(formatFiltes);

if ~(figFilePath==0)
    wBar = waitbar(0, 'Figure is being saved...');
    set(0, 'CurrentFigure', handles.viewNBSPredictFig);
    fullFileName = [figFilePath,figFileName];
    saveFigH = figure('Visible','off','PaperUnits','centimeters','Units','centimeters');
    copyobj(handles.figureAxes,saveFigH);
    pos = get(saveFigH,'Position');
    
    % Remove metric
    figChildren = arrayfun(@(x) class(x),saveFigH.Children,'UniformOutput',false);
    delete(saveFigH.Children(ismember(figChildren,'matlab.graphics.axis.Axes')).Title);
    
    % Configs for other figures.
    set(saveFigH,'PaperSize', [pos(3)*.75 pos(4)],...
        'PaperPositionMode', 'manual','PaperPosition',[0 0 pos(3) pos(4)]);
    if ismember(handles.cFig,{'adj','net'})
        % Add colorbar if adjacency or network plots are to be printed.
        colorbar;
    elseif ismember(handles.cFig,{'confMat'})
        colormap(flipud(gray));
    end
    
    if filterIdx == 2
        % Save as figure.
        set(saveFigH,'Visible','on');
        saveas(saveFigH,fullFileName,'fig');
    else
        dpi = '-r300';
        if filterIdx == 1
            dpi = '-r2000';
        elseif filterIdx == 4
            dpi = '-r1000';
        end
        fileFormat = formatFiltes{filterIdx,1};
        fileFormat = fileFormat(3:end);
        fileFormat = ['-d',fileFormat];
        print(saveFigH,fullFileName,fileFormat,dpi);
    end
    close(saveFigH)
    clear saveFigH
    waitbar(1, wBar, 'Done!');
    pause(0.5);
    close(wBar);
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
handles.plotResults.truePredLabels = handles.plotData.(handles.cModel).truePredLabels;
% Update handles structure and plot
handles = plotUpdatedData(handles);
handles = updateTitle(handles);
if handles.ifClass
    [handles] =  updateConfMat(handles);
    if strcmpi(handles.cFig,'confMat')
        confMatPush_Callback(handles.confMatPush,[],handles);
    end
end
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

% --- Executes on selection change in metricPopUp.
function metricPopUp_Callback(hObject, eventdata, handles)
% hObject    handle to metricPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns metricPopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from metricPopUp
tmp = get(hObject,'String');
tmpIdx = get(hObject,'Value');
metricName = tmp{tmpIdx};
metric = lower(metricName);
handles.plotResults.metric = metric;
wBar = waitbar(0, 'Computing...');
set(0, 'CurrentFigure', handles.viewNBSPredictFig);
handles = updateTitle(handles);
waitbar(1, wBar, 'Done!');
close(wBar);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function metricPopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to metricPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in labelButton.
function labelButton_Callback(hObject, eventdata, handles)
% hObject    handle to labelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of labelButton
ifShowLabel = get(hObject,'Value');
handles.ifShowLabel = ifShowLabel;
guidata(hObject,handles)
if strcmpi(handles.cFig,'net')
    networkPush_Callback(handles.networkPush,[],handles);
end
if isfield(handles,'brainNetFig') && isgraphics(handles.brainNetFig)
    pause(0.1)
    brainNetPush_Callback(handles.brainNetPush, [], handles);
end

% --- Executes on button press in evalButton.
function evalButton_Callback(hObject, eventdata, handles)
% hObject    handle to evalButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ifEval = get(hObject, 'Value');
handles.ifEval = ifEval;
if ifEval
    handles.subNetEvalText.Visible = 'on';
else
    handles.subNetEvalText.Visible = 'off';
end
if ifEval
    meanCVscore = evalSubnet(handles);
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
        if isfield(graphHandle.UserData,'cWeight')
            edgeWeight = graphHandle.UserData.cWeight;
%             adjDataCursorTxt = {['Weight: ',num2str(edgeWeight)]};
            adjDataCursorTxt = {sprintf('Weight: %.3f', edgeWeight)};
        else
            cG = getappdata(handles.uipanel1,'cG');
            cLabel = graphHandle.UserData.Label;
            intLabel = str2double(cLabel);
            if ~isnan(intLabel)
                cLabel = handles.plotData.brainRegions.labels{intLabel};
                nodeIdx = intLabel;
            else
                [~,nodeIdx] = ismember(cLabel,handles.plotData.brainRegions.labels);
            end
              
            cDegree = cG.Degree(nodeIdx);
            adjDataCursorTxt = {['Region: ',cLabel],...
                ['Nodal degree: ',num2str(cDegree)]};
        end
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
end
if isfield(handles,'brainNetFig') && isgraphics(handles.brainNetFig)
    pause(0.1)
    brainNetPush_Callback(handles.brainNetPush, [], handles);
end
handles.sizeNetworkText.String = sprintf('Nodes : %d\nEdges : %d',...
    numel(handles.plotResults.labels),size(handles.plotResults.G.Edges,1));
sortedTable = sortrows(table(handles.plotResults.labels,...
    degree(handles.plotResults.G)),2,'descend');
if handles.evalButton.Value
    evalSubnet(handles);
end
handles.uitable1.Data = table2cell(sortedTable);

function [handles] =  updateConfMat(handles)
% Generate confusion matrix.
% truePredLabels = handles.
truePredLabels = handles.plotData.(handles.cModel).truePredLabels;
CM = compute_modelMetrics(truePredLabels(:,1),...
    truePredLabels(:,2),'confusionMatrix');
confMat = [CM.TN,CM.FN;CM.FP,CM.TP];
handles.plotResults.truePredLabels = truePredLabels;
handles.plotResults.confMat = confMat;

function [handles] = updateTitle(handles)
% updateTitle updates title with given metric.
metric = handles.plotResults.metric;
metricName = [upper(metric(1)),metric(2:end)];
if strcmpi(handles.plotData.metric,metric)
    figTitle = sprintf('%s: %.3f (%.3f, %.3f)',metricName,...
        handles.plotData.(handles.cModel).meanRepCVscore,...
        handles.plotData.(handles.cModel).meanCVscoreCI);
    
    if isfield(handles.plotData.(handles.cModel), 'permScore')
        % If permutation score exists.
        permScore = handles.plotData.(handles.cModel).permScore;
        figTitle = sprintf([figTitle, ' Permutation: %.3f, p = %.3f'],...
            permScore(1), permScore(2));
    end

else
    truePredLabels = handles.plotResults.truePredLabels;
    score = compute_modelMetrics(truePredLabels(:,1),truePredLabels(:,2),metric);
    figTitle = sprintf('%s: %.3f',metricName,score);
end
handles.figureTitle = figTitle;

function [handles] = pcFontSize(handles)
% Set font and font size if pc.
if ispc || isunix
    set(handles.figureAxes,'FontSize',8,'FontName','default');
end


function [meanCVscore] = evalSubnet(handles)
% TODO: Implement better way to evaluate the suprathreshold subnetwork.
% Evaluates prediction performance of identified subnetwork.
% Set parameters.
wBar = waitbar(0, 'Processing...');
kFold = 10;
repCV = 10; % Run CV n times.

CVscores = zeros(repCV,kFold); % preallocate.

% Extract edge weights from suprathreshold subnetwork.
subnetIdx = find(triu(handles.plotResults.adj));
[~,extIdx] = ismember(subnetIdx,handles.plotData.edgeIdx); % find indexes of edges to be extracted
X = handles.plotData.X(:,extIdx);
y = handles.plotData.y(:,2);
data.X = X;
data.y = y;
if ~isempty(handles.plotData.confounds)
    data.confounds = handles.plotData.confounds;
end

for i = 1: repCV
    waitbar(i/repCV, wBar);
    subnetEvalFun = @(data) subnetEvaluate(data,handles);
    CVscores(i,:) = crossValidation(subnetEvalFun,data,'kfold',kFold); % Run handler in CV.
end

meanCVscore = mean(nanmean(CVscores));
stdCVscore = std(nanmean(CVscores));
seCVscore = stdCVscore/sqrt(repCV);
confScore = seCVscore*1.96; % p < .05
upperCI = meanCVscore + confScore;
lowerCI = meanCVscore - confScore;
strCVscore = sprintf('Score : %.3f\n[%.3f, %.3f]',meanCVscore,lowerCI,upperCI);
set(handles.subNetEvalText,'String',strCVscore);
waitbar(1, wBar, 'Done!');
pause(0.5);
close(wBar);


function score = subnetEvaluate(data,handles)
MLhandle = gen_MLhandles(handles.cModel);
Mdl = MLhandle();
data = preprocess_data(data,handles.plotData.scalingMethod);
score = modelFitScore(Mdl,data,handles.plotResults.metric);


% --- Executes during object deletion, before destroying properties.
function viewNBSPredictFig_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to viewNBSPredictFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
goodbyeMsg = ['\nThank you for using NBS-Predict!\n',...
    'Please contact to emin.serin@charite.de for any questions, suggestions or bug reports.\n\n'];
fprintf(goodbyeMsg);
