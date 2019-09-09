function varargout = run_NBSPredictGUI(varargin)
%RUN_NBSPREDICTGUI MATLAB code file for run_NBSPredictGUI.fig
%      RUN_NBSPREDICTGUI, by itself, creates a new RUN_NBSPREDICTGUI or raises the existing
%      singleton*.
%
%      H = RUN_NBSPREDICTGUI returns the handle to a new RUN_NBSPREDICTGUI or the handle to
%      the existing singleton*.
%
%      RUN_NBSPREDICTGUI('Property','Value',...) creates a new RUN_NBSPREDICTGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to run_NBSPredictGUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      RUN_NBSPREDICTGUI('CALLBACK') and RUN_NBSPREDICTGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in RUN_NBSPREDICTGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to manualPush run_NBSPredictGUI

% Last Modified by GUIDE v2.5 05-Sep-2019 22:37:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @run_NBSPredictGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @run_NBSPredictGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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

% --- Executes just before run_NBSPredictGUI is made visible.
function run_NBSPredictGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)
% Choose default command line output for run_NBSPredictGUI
handles.output = hObject;
handles.NBSPredict.parameter.ifView = 1;
handles = loadHistory(handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes run_NBSPredictGUI wait for user response (see UIRESUME)
% uiwait(handles.startNBSPredictFig);
% --- Outputs from this function are returned to the command line.
function varargout = run_NBSPredictGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in HyperOptCheck.
function HyperOptCheck_Callback(hObject, eventdata, handles)
% hObject    handle to HyperOptCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of HyperOptCheck
ifHyperOpt = get(hObject,'Value');
handles.NBSPredict.parameter.ifHyperOpt = ifHyperOpt;
handles.guiHistory.UI.Value.HyperOptCheck = ifHyperOpt;
guidata(hObject,handles)

function hyperOptStepsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to hyperOptStepsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hyperOptStepsEdit as text
%        str2double(get(hObject,'String')) returns contents of hyperOptStepsEdit as a double
hyperOptSteps = get(hObject,'String');
handles.NBSPredict.parameter.hyperOptSteps = str2double(hyperOptSteps);
handles.guiHistory.UI.String.hyperOptSteps = hyperOptSteps;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function hyperOptStepsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hyperOptStepsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function kFoldEdit_Callback(hObject, eventdata, handles)
% hObject    handle to kFoldEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kFoldEdit as text
%        str2double(get(hObject,'String')) returns contents of kFoldEdit as a double
kFold = get(hObject,'String');
handles.NBSPredict.parameter.kFold = str2double(kFold);
handles.guiHistory.UI.String.kFoldEdit = kFold;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function kFoldEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kFoldEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in metricpop.
function metricpop_Callback(hObject, eventdata, handles)
% hObject    handle to metricpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns metricpop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from metricpop
tmp = get(hObject,'String');
tmpIdx = get(hObject,'Value');
handles.NBSPredict.parameter.metric = lower(tmp{tmpIdx});
handles.guiHistory.UI.Value.metricpop = tmpIdx;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function metricpop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to metricpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
metricOpt = {'Accuracy','Sensitivity','Specificity','Precision',...
    'Recall',...
    'F1',...
    'Matthews_CC',...
    'Cohens_Kappa',...
    'AUC',...
    'R-squared',...
    'RMSE',...
    'Explained_Variance',...
    'MAD'};
set(hObject,'String',metricOpt);

function repCViterEdit_Callback(hObject, eventdata, handles)
% hObject    handle to repCViterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of repCViterEdit as text
%        str2double(get(hObject,'String')) returns contents of repCViterEdit as a double
repCViter = get(hObject,'String');
handles.NBSPredict.parameter.repCViter = str2double(repCViter);
handles.guiHistory.UI.String.repCViter = repCViter;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function repCViterEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to repCViterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in ifParallelCheck.
function ifParallelCheck_Callback(hObject, eventdata, handles)
% hObject    handle to ifParallelCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ifParallelCheck
ifParallel = get(hObject,'Value');
handles.NBSPredict.parameter.ifParallel = ifParallel;
handles.guiHistory.UI.Value.ifParallelCheck = ifParallel;
guidata(hObject,handles)



function contrastEdit_Callback(hObject, eventdata, handles)
% hObject    handle to contrastEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of contrastEdit as text
%        str2double(get(hObject,'String')) returns contents of contrastEdit as a double
tmp = get(hObject,'String');
handles.guiHistory.UI.String.contrastEdit = tmp;
tmp = strsplit(tmp(2:end-1),',');
tmp = cellfun(@(x) str2double(x),tmp);
handles.NBSPredict.parameter.contrast = tmp;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function contrastEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrastEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
tmp = get(hObject,'String');
tmp = strsplit(tmp(2:end-1),',');
tmp = cellfun(@(x) str2double(x),tmp);
handles.NBSPredict.parameter.contrast = tmp;
guidata(hObject,handles)

% --- Executes on selection change in testpop.
function testpop_Callback(hObject, eventdata, handles)
% hObject    handle to testpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns testpop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from testpop
tmp = get(hObject,'String');
tmpIdx = get(hObject,'Value');
handles.NBSPredict.parameter.test = tmp{tmpIdx};
handles.guiHistory.UI.Value.testpop = tmpIdx;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function testpop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to testpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
testOpt = {'t-test','F-test'};
set(hObject,'String',testOpt);

% --- Executes on selection change in mlModelpop.
function mlModelpop_Callback(hObject, eventdata, handles)
% hObject    handle to mlModelpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns mlModelpop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mlModelpop
MLoptions = get(hObject,'String');
MLmodelNames = handles.MLfunNames;
MLidx = get(hObject,'Value');
if strcmpi(MLoptions{MLidx},'Auto (optimize models)')
    handles.NBSPredict.parameter.ifModelOpt = 1;
    if isfield(handles.NBSPredict.parameter,'MLmodels')
        handles.NBSPredict.parameter =...
            rmfield(handles.NBSPredict.parameter,'MLmodels');
    end
else
    handles.NBSPredict.parameter.ifModelOpt = 0;
    handles.NBSPredict.parameter.MLmodels = MLmodelNames(MLidx);
end
handles.guiHistory.UI.Value.mlModelpop = MLidx;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function mlModelpop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mlModelpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
mlOptions = {'Auto (optimize models)','Decision Tree Classification','SVM Classification'};
set(hObject,'String',mlOptions);
handles.NBSPredict.parameter.ifModelOpt = 1;
guidata(hObject,handles)


function designMatEdit_Callback(hObject, eventdata, handles)
% hObject    handle to designMatEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of designMatEdit as text
%        str2double(get(hObject,'String')) returns contents of designMatEdit as a double
fileName = get(hObject,'String');
if exist(fileName, 'file') == 2
    y = loadData(fileName);
    handles.NBSPredict.data.y = y;
    if numel(unique(y(:,2))) < length(y(:,2))/2
        mlOptions = {'Auto (optimize models)','Decision Tree Classification','SVM Classification'};
        mlFunNames = {'','decisionTreeC','svmC'};
        set(handles.testpop,'String',{'t-test','F-test'})
        set(handles.metricpop,'String',{'Accuracy','Sensitivity','Specificity',...
            'Precision','Recall','F1','Matthews_CC','Cohens_Kappa','AUC'})
        set(handles.mlModelpop,'String',mlOptions);
    else
        mlOptions = {'Auto (optimize models)','SVM Regression','Decision Tree Regression'};
        mlFunNames = {'','svmR','decisionTreeR'};
        set(handles.testpop,'String',{'F-test'})
        set(handles.metricpop,'String',{'RMSE','R-squared','Explained_Variance','MAD'})
        set(handles.mlModelpop,'String',mlOptions);
    end
    handles.MLfunNames = mlFunNames;
    handles.guiHistory.UI.String.designMatEdit = fileName;
    set(handles.designMatPush,'ForegroundColor',[0,0.7,0]);
    guidata(hObject,handles)
else
    set(handles.designMatPush,'ForegroundColor','red');
end
    
% --- Executes during object creation, after setting all properties.
function designMatEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to designMatEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in designMatPush.
function designMatPush_Callback(hObject, eventdata, handles)
% hObject    handle to designMatPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uigetfile({'*.mat','MAT-files';...
    '*.csv','CSV'},'Please select design matrix.');
if path ~= 0
    set(handles.designMatEdit,'String',[path,file]);
    designMatEdit_Callback(handles.designMatEdit,[],handles);
end

function corrMatEdit_Callback(hObject, eventdata, handles)
% hObject    handle to corrMatEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of corrMatEdit as text
%        str2double(get(hObject,'String')) returns contents of corrMatEdit as a double
path = get(hObject,'String');
if exist(path, 'dir') == 7
    handles.NBSPredict.data.path = path;
    handles.guiHistory.UI.String.corrMatEdit = path;
    set(handles.corrMatPush,'ForegroundColor',[0,0.7,0]);
    guidata(hObject,handles)
else
    set(handles.designMatPush,'ForegroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function corrMatEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to corrMatEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in corrMatPush.
function corrMatPush_Callback(hObject, eventdata, handles)
% hObject    handle to corrMatPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = uigetdir('Please select a directory containing connectivity matrices.');
if path ~= 0
    set(handles.corrMatEdit,'String',path);
    corrMatEdit_Callback(handles.corrMatEdit,[],handles);
end

function brainRegionsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to brainRegionsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of brainRegionsEdit as text
%        str2double(get(hObject,'String')) returns contents of brainRegionsEdit as a double
fileName = get(hObject,'String');
if exist(fileName, 'file') == 2
    brainRegions = loadData(fileName);
    brainRegions.Properties.VariableNames = {'X','Y','Z','labels'};
    handles.NBSPredict.data.brainRegions = brainRegions;
    handles.guiHistory.UI.String.brainRegionsEdit = fileName;
    set(handles.corrMatEdit,'String',path);
    set(handles.brainRegionsPush,'ForegroundColor',[0,0.7,0]);
    guidata(hObject,handles)
else
    set(handles.brainRegionsPush,'ForegroundColor','red');
end

% --- Executes during object creation, after setting all properties.
function brainRegionsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brainRegionsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in brainRegionsPush.
function brainRegionsPush_Callback(hObject, eventdata, handles)
% hObject    handle to brainRegionsPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile({'*.csv','CSV-file'},'Please select brain regions file');
if path ~= 0
    set(handles.brainRegionsEdit,'String',[path,file]);
    brainRegionsEdit_Callback(handles.brainRegionsEdit,[],handles);
end

function maxPercentEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxPercentEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxPercentEdit as text
%        str2double(get(hObject,'String')) returns contents of maxPercentEdit as a double
maxPercent = get(hObject,'String');
handles.NBSPredict.parameter.maxPercent = str2double(maxPercent);
handles.guiHistory.UI.String.maxPercentEdit = maxPercent;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function maxPercentEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxPercentEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in featureSelPopUp.
function featureSelPopUp_Callback(hObject, eventdata, handles)
% hObject    handle to featureSelPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns featureSelPopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from featureSelPopUp
featMethod = get(hObject,'String');
featMetIdx = get(hObject,'Value');
featMethod = featMethod{featMetIdx};
switch featMethod
    case 'Divide and Select'
        handles.NBSPredict.parameter.selMethod = 'divSelect';
        handles.divSelectPanel.Visible = 'on';
        handles.randomSearchPanel.Visible = 'off';
        handles.simulatedAnnealingPanel.Visible = 'off';
    case 'Random Search'
        handles.NBSPredict.parameter.selMethod = 'randomSearch';
        handles.divSelectPanel.Visible = 'off';
        handles.randomSearchPanel.Visible = 'on';
        handles.simulatedAnnealingPanel.Visible = 'off';
    case 'Simulated Annealing'
        handles.NBSPredict.parameter.selMethod = 'simulatedAnnealing';
        handles.divSelectPanel.Visible = 'off';
        handles.randomSearchPanel.Visible = 'off';
        handles.simulatedAnnealingPanel.Visible = 'on';
end
handles.guiHistory.UI.Value.featureSelPopUp = featMetIdx;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function featureSelPopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to featureSelPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
featureSelOptions = {'Divide and Select','Random Search','Simulated Annealing'};
set(hObject,'String',featureSelOptions);
handles.NBSPredict.parameter.selMethod = 'divSelect';
guidata(hObject,handles)

function nIterEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nIterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nIterEdit as text
%        str2double(get(hObject,'String')) returns contents of nIterEdit as a double
nIter = get(hObject,'String');
handles.NBSPredict.parameter.nIter = str2double(nIter);
handles.guiHistory.UI.String.nIterEdit = nIter;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function nIterEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nIterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tempEdit_Callback(hObject, eventdata, handles)
% hObject    handle to tempEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tempEdit as text
%        str2double(get(hObject,'String')) returns contents of tempEdit as a double
T = get(hObject,'String');
handles.NBSPredict.parameter.T = str2double(T);
handles.guiHistory.UI.String.tempEdit = T;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function tempEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tempEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function alphaEdit_Callback(hObject, eventdata, handles)
% hObject    handle to alphaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alphaEdit as text
%        str2double(get(hObject,'String')) returns contents of Edit as a double
alpha = get(hObject,'String');
handles.NBSPredict.parameter.alpha = str2double(alpha);
handles.guiHistory.UI.String.alphaEdit = alpha;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function alphaEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alphaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function selRoundEdit_Callback(hObject, eventdata, handles)
% hObject    handle to selRoundEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of selRoundEdit as text
%        str2double(get(hObject,'String')) returns contents of selRoundEdit as a double
selRound = get(hObject,'String');
handles.NBSPredict.parameter.selRound = str2double(selRound);
handles.guiHistory.UI.String.selRoundEdit = selRound;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function selRoundEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selRoundEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function nDivEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nDivEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nDivEdit as text
%        str2double(get(hObject,'String')) returns contents of nDivEdit as a double
nDiv = get(hObject,'String');
handles.NBSPredict.parameter.nDiv = str2double(nDiv);
handles.guiHistory.UI.String.nDivEdit = nDiv;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function nDivEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nDivEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function nIter_Callback(hObject, eventdata, handles)
% hObject    handle to nIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nIter as text
%        str2double(get(hObject,'String')) returns contents of nIter as a double
nIter = get(hObject,'String');
handles.NBSPredict.parameter.nIter = str2double(nIter);
handles.guiHistory.UI.String.nIter = nIter;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function nIter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% About & manualpush & Run
% --- Executes on button press in aboutPush.
function aboutPush_Callback(hObject, eventdata, handles)
% hObject    handle to aboutPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
verNBSPredict = '\bf1.0.0-alpha1';
msg = {'NBS-Predict';['Version: ',verNBSPredict];...
    '\rmAuthor: Emin Serin';...
    'Contact: eminserinn@gmail.com'};
CreateStruct.Interpreter = 'tex';
CreateStruct.WindowStyle = 'modal';
mb = msgbox(msg,'About','Value',CreateStruct);
msgboxhanles = findall(mb, 'Type', 'Text'); 
set(msgboxhanles, 'FontSize', 10);


% --- Executes on button press in manualPush.
function manualPush_Callback(hObject, eventdata, handles)
% hObject    handle to manualPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if exist('BrainNet_Manual.pdf','file')==2
%     open('NBS-Predict_Manual.pdf');
% else
%     msgbox('Cannot find the manual file!','Error','error');
% end

% --- Executes on button press in runNBSPredict.
function runNBSPredict_Callback(hObject, eventdata, handles)
% hObject    handle to runNBSPredict (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.guiHistory.data = handles.NBSPredict.data;
handles.guiHistory.parameter = handles.NBSPredict.parameter;
guiHistory = handles.guiHistory;
referenceFile = 'start_NBSPredict.m';
saveDir = fileparts(which(referenceFile));
save([saveDir,filesep,'history.mat'],'guiHistory');
set(handles.runNBSPredict,'ForegroundColor',[0,0.7,0]);
run_NBSPredict(handles.NBSPredict);

%% Helper
function [handles] = loadHistory(handles)
try 
    load('history')
    UI = guiHistory.UI;
    UIproperty = fieldnames(UI);
    for i = 1:numel(UIproperty)
        callbacks = fieldnames(UI.(UIproperty{i}));
        for j = 1: numel(callbacks)
            val = UI.(UIproperty{i}).(callbacks{j});
            handles.(callbacks{j}).(UIproperty{i}) = val;
            fun = str2func([callbacks{j},'_Callback']);
            fun(handles.(callbacks{j}),[],handles);
        end
    end
    handles.guiHistory = guiHistory;
    handles.NBSPredict.parameter = guiHistory.parameter;
    handles.NBSPredict.data = guiHistory.data;
end
