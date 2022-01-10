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

% Last Modified by GUIDE v2.5 08-Jan-2022 09:44:33

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
handles.NBSPredict.parameter.ifView = 1; % run NBS_Predict_view after analysis. 
handles.verNBSPredict = '1.0.0-beta.6';
handles.NBSPredict.info.version = handles.verNBSPredict;
handles.NBSPredict.info.workingDir = pwd;
handles.maxCores = feature('numcores');

% History function has been deactivated until the following versions!
handles = loadHistory(handles);
% handles.ifHistory = 0;


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
handles.guiHistory.UI.String.hyperOptStepsEdit = hyperOptSteps;
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
metricOpt = {'Accuracy', 'Balanced_Accuracy','Sensitivity',...
    'Specificity',...
    'Precision',...
    'Recall',...
    'F1',...
    'Matthews_CC',...
    'Cohens_Kappa',...
    'AUC',...
    'MSE',...
    'RMSE',...
    'MAD',...
    'Correlation',...
    'R_squared',...
    'Explained_Variance'};
set(hObject,'String',metricOpt);


% --- Executes on selection change in scalingPopMenu.
function scalingPopMenu_Callback(hObject, eventdata, handles)
% hObject    handle to scalingPopMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scalingPopMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scalingPopMenu
tmp = get(hObject,'String');
tmpIdx = get(hObject,'Value');
scalingMethod = tmp{tmpIdx};
if strcmpi(scalingMethod,'No Scaling')
    scalingMethod = [];
end
handles.NBSPredict.parameter.scalingMethod = scalingMethod;
handles.guiHistory.UI.Value.scalingPopMenu = tmpIdx;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function scalingPopMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scalingPopMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
scalingOpt = {'No Scaling','MinMaxScaler','MaxAbsScaler','StandardScaler'};
set(hObject,'String',scalingOpt);


function repCViterEdit_Callback(hObject, eventdata, handles)
% hObject    handle to repCViterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of repCViterEdit as text
%        str2double(get(hObject,'String')) returns contents of repCViterEdit as a double
repCViter = get(hObject,'String');
handles.NBSPredict.parameter.repCViter = str2double(repCViter);
handles.guiHistory.UI.String.repCViterEdit = repCViter;
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
mlOptions = {'Auto (optimize models)',...
    'Decision Tree Classification',...
    'SVM Classification',...
    'Logistic Regression',...
    'Linear Discriminant Analysis',...
    'SVM Regression',...
    'Decision Tree Regression',...
    'Linear Regression'};
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
    if ~handles.ifHistory
        y = loadData(fileName);
        handles.NBSPredict.data.y = y;
    end
    ifClass = check_classification(handles.NBSPredict.data.y);
    if ifClass
        mlOptions = {'Auto (optimize models)','Decision Tree Classification',...
            'SVM Classification','Logistic Regression','Linear Discriminant Analysis'};
        MLfunNames = {'','decisionTreeC','svmC','LogReg','lda'};
        set(handles.metricpop,'String',{'Accuracy','Balanced_Accuracy',...
            'Sensitivity','Specificity',...
            'Precision','Recall','F1','Matthews_CC','Cohens_Kappa','AUC'})
    else
        mlOptions = {'Auto (optimize models)','SVM Regression','Decision Tree Regression','Linear Regression'};
        MLfunNames = {'','svmR','decisionTreeR','LinReg'};
        set(handles.metricpop,'String',{'RMSE','MSE','MAD','Correlation','Explained_Variance','R_squared'})
        %         handles.NBSPredict.parameter.test = 'F-test';
    end
    set(handles.mlModelpop,'String',mlOptions);
    handles.MLfunNames = MLfunNames;
    handles.guiHistory.MLfunNames = MLfunNames;
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
    handles.NBSPredict.data.corrPath = path;
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
    handles.NBSPredict.data.brainRegionsPath = fileName;
    handles.guiHistory.UI.String.brainRegionsEdit = fileName;
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


function pValEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pValEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pValEdit as text
%        str2double(get(hObject,'String')) returns contents of pValEdit as a double
pVal = get(hObject,'String');
handles.NBSPredict.parameter.pVal = str2double(pVal);
handles.guiHistory.UI.String.pValEdit = pVal;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function pValEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pValEdit (see GCBO)
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
    case 'Grid Search'
        handles.NBSPredict.parameter.selMethod = 'gridSearch';
        handles.randomSearchPanel.Visible = 'off';
    case 'Random Search'
        handles.NBSPredict.parameter.selMethod = 'randomSearch';
        handles.randomSearchPanel.Visible = 'on';
    case 'Bayesian Optimization'
        handles.NBSPredict.parameter.selMethod = 'bayesOpt';
        handles.randomSearchPanel.Visible = 'on';
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
featureSelOptions = {'Grid Search','Random Search','Bayesian Optimization'};
set(hObject,'String',featureSelOptions);
handles.NBSPredict.parameter.selMethod = 'gridSearch';
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


function seedEdit_Callback(hObject, eventdata, handles)
% hObject    handle to seedEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of seedEdit as text
%        str2double(get(hObject,'String')) returns contents of seedEdit as a double
randSeed = str2double(get(hObject,'String'));
ifStr = isnan(randSeed);
if ifStr
    warning('Please enter a number!');
else
    handles.guiHistory.UI.String.seedEdit = randSeed;
    handles.NBSPredict.parameter.randSeed = randSeed;
    guidata(hObject,handles);
end


% --- Executes during object creation, after setting all properties.
function seedEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to seedEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in permCheckBox.
function permCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to permCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of permCheckBox
ifPerm = get(hObject,'Value');
handles.NBSPredict.parameter.ifPerm = ifPerm;
handles.guiHistory.UI.Value.permCheckBox = ifPerm;
guidata(hObject,handles)


function permIterEdit_Callback(hObject, eventdata, handles)
% hObject    handle to permIterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of permIterEdit as text
%        str2double(get(hObject,'String')) returns contents of permIterEdit as a double
permIter = str2double(get(hObject,'String'));
ifStr = isnan(permIter);
if ifStr
    warning('Please enter a number!');
else
    handles.guiHistory.UI.String.permIterEdit = permIter;
    handles.NBSPredict.parameter.permIter = permIter;
    guidata(hObject,handles);
end


% --- Executes during object creation, after setting all properties.
function permIterEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to permIterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function cpuCoreEdit_Callback(hObject, eventdata, handles)
% hObject    handle to cpuCoreEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cpuCoreEdit as text
%        str2double(get(hObject,'String')) returns contents of cpuCoreEdit as a double
nCores = str2double(get(hObject, 'String'));
handles.NBSPredict.parameter.numCores = 1; 
if nCores < 1
    errordlg('Number of CPU cores cannot be lower than 1');
elseif nCores > handles.maxCores
    errordlg(sprintf('Number of CPU cores cannot be higher than %d physical cores',...
        handles.maxCores));
else
    handles.NBSPredict.parameter.numCores = nCores; 
    handles.guiHistory.UI.String.cpuCoreEdit = nCores;
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function cpuCoreEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cpuCoreEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in aboutPush.
function aboutPush_Callback(hObject, eventdata, handles)
% hObject    handle to aboutPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[iconData, ~] = imread('NBS-Predict_logo.png');
msg = {'NBS-Predict';['Version: ',handles.verNBSPredict];...
    'Author: Emin Serin';...
    'Contact: emin.serin@charite.de'};
% CreateStruct.Interpreter = 'tex';
% CreateStruct.WindowStyle = 'modal';
mb = msgbox(msg, 'About','custom',iconData);
% mb = msgbox(msg,'About','Value',CreateStruct);
msgboxhanles = findall(mb, 'Type', 'Text'); 
set(msgboxhanles, 'FontSize', 10);


% --- Executes on button press in manualPush.
function manualPush_Callback(hObject, eventdata, handles)
% hObject    handle to manualPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if exist('MANUAL.pdf','file')==2
    open('MANUAL.pdf');
else
    msgbox('Cannot find the manual file!','Error','error');
end



% --- Executes on button press in runNBSPredict.
function runNBSPredict_Callback(hObject, eventdata, handles)
% hObject    handle to runNBSPredict (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.guiHistory.data = handles.NBSPredict.data;
handles.guiHistory.parameter = handles.NBSPredict.parameter;
% if isfield(handles.guiHistory.parameter,'MLmodels') 
%     handles.guiHistory.parameter = rmfield(handles.guiHistory.parameter,{'MLmodels','ifModelOpt'});
% end
% if isfield(handles.guiHistory.parameter,'metric')
%     handles.guiHistory.parameter = rmfield(handles.guiHistory.parameter,'metric');
% end
guiHistory = handles.guiHistory;

% History function has been deactivated until the following versions.
save(handles.historyDir,'guiHistory');

set(handles.runNBSPredict,'ForegroundColor',[0,0.7,0]);
run_NBSPredict(handles.NBSPredict);


%% Helper
function [handles] = loadHistory(handles)
historyDir = [handles.NBSPredict.info.workingDir, filesep, 'history.mat'];
handles.historyDir = historyDir;
ifHistory = exist(historyDir, 'file') == 2;
if ifHistory
    handles.ifHistory = 1;
    try
        load(historyDir)
        UI = guiHistory.UI;
        UIproperty = fieldnames(UI);
        handles.MLfunNames = guiHistory.MLfunNames;
        handles.NBSPredict.data = guiHistory.data;
        handles.NBSPredict.parameter = guiHistory.parameter;
        handles.guiHistory = guiHistory;
        for i = 1:numel(UIproperty)
            callbacks = fieldnames(UI.(UIproperty{i}));
            nCallbacks = numel(callbacks);
            for j = 1: nCallbacks
                val = UI.(UIproperty{i}).(callbacks{j});
                handles.(callbacks{j}).(UIproperty{i}) = val;
                fun = str2func([callbacks{j},'_Callback']);
                fun(handles.(callbacks{j}),[],handles);
            end
        end
    end
else
    handles.ifHistory = 0; 
end
