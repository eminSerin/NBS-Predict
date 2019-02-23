function varargout = start_NBSPredict(varargin)
% START_NBSPREDICT MATLAB code for start_NBSPredict.fig
%      START_NBSPREDICT, by itself, creates a new START_NBSPREDICT or raises the existing
%      singleton*.
%
%      H = START_NBSPREDICT returns the handle to a new START_NBSPREDICT or the handle to
%      the existing singleton*.
%
%      START_NBSPREDICT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in START_NBSPREDICT.M with the given input arguments.
%
%      START_NBSPREDICT('Property','Value',...) creates a new START_NBSPREDICT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before start_NBSPredict_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to start_NBSPredict_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help start_NBSPredict

% Last Modified by GUIDE v2.5 20-Feb-2019 13:23:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @start_NBSPredict_OpeningFcn, ...
                   'gui_OutputFcn',  @start_NBSPredict_OutputFcn, ...
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

% --- Executes just before start_NBSPredict is made visible.
function start_NBSPredict_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to start_NBSPredict (see VARARGIN)

% Choose default command line output for start_NBSPredict
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes start_NBSPredict wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = start_NBSPredict_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function corrMatEdit_Callback(hObject, eventdata, handles)
% hObject    handle to corrMatEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of corrMatEdit as text
%        str2double(get(hObject,'String')) returns contents of corrMatEdit as a double



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
[handles.NBSPredict.files,handles.NBSPredict.path] = uigetfile({'*.mat','MAT-files';...
    '*.txt','Text-files'},'Please select connectivity matrices',...
    'MultiSelect','on');
set(handles.corrMatEdit,'String',handles.NBSPredict.path);
guidata(hObject,handles)




function brainRegionsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to brainRegionsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of brainRegionsEdit as text
%        str2double(get(hObject,'String')) returns contents of brainRegionsEdit as a double



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
set(handles.brainRegionsEdit,'String',path);
fileID = fopen([path,file],'r');
tmp = textscan(fileID,'%f%f%f%s','Delimiter',',');
fclose(fileID);
brainRegions = table;
brainRegions.X = tmp{1};
brainRegions.Y = tmp{2};
brainRegions.Z = tmp{3};
brainRegions.labels = tmp{4};
handles.NBSPredict.brainRegions = brainRegions;
guidata(hObject,handles)


function designMatEdit_Callback(hObject, eventdata, handles)
% hObject    handle to designMatEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of designMatEdit as text
%        str2double(get(hObject,'String')) returns contents of designMatEdit as a double


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
% Load design matrix.
[design, path] = uigetfile({'*.mat','MAT-files';...
    '*.txt','Text-files'},'Please select design matrix.');
set(handles.designMatEdit,'String',path);
handles.NBSPredict.designMat = load([path design]);
if strcmpi(design(end-2:end),'mat')
    % if mat file.
    fname = fieldnames(handles.NBSPredict.designMat);
    handles.NBSPredict.designMat = handles.NBSPredict.designMat.(fname{:});
end
if numel(unique(handles.NBSPredict.designMat(:,2))) < length(handles.NBSPredict.designMat(:,2))/2
    mlOptions = {'Auto (optimize models)','Decision Tree','SVM Classification'};
    handles.NBSPredict.MLtype = 'classification';
    set(handles.testpop,'String',{'t-test','F-test'})
    set(handles.metricpop,'String',{'Accuracy','Sensitivity','Specificity',...
        'Precision','Recall','F1','Matthews_CC','Cohens_Kappa','AUC'})
    set(handles.mlModelpop,'String',mlOptions);
else
    mlOptions = {'Auto (optimize models)','Linear Regression',...
        'SVM Regression','Decision Tree Regression'};
    handles.NBSPredict.MLtype = 'regression';
    set(handles.testpop,'String',{'F-test'})
    set(handles.metricpop,'String',{'R-squared','RMSE','Explained_Variance','MAD'})
    set(handles.mlModelpop,'String',mlOptions);
end
guidata(hObject,handles)


function contrastEdit_Callback(hObject, eventdata, handles)
% hObject    handle to contrastEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of contrastEdit as text
%        str2double(get(hObject,'String')) returns contents of contrastEdit as a double
tmp = get(hObject,'String');
tmp = strsplit(tmp(2:end-1),',');
tmp = cellfun(@(x) str2double(x),tmp);
handles.NBSPredict.contrast = tmp;
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
handles.NBSPredict.contrast = tmp;
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
handles.NBSPredict.test = tmp{tmpIdx};
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
tmp = get(hObject,'String');
tmpIdx = get(hObject,'Value');
tmp = tmp{tmpIdx};
if strcmpi(tmp,'Auto (optimize models)')
    handles.NBSPredict.ifModelOpt = 1;
else
    handles.NBSPredict.ifModelOpt = 0;
    handles.NBSPredict.mlModel = tmp;
end
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
mlOptions = {'Auto (optimize models)','Decision Tree','SVM Classification'};
set(hObject,'String',mlOptions);
handles.NBSPredict.ifModelOpt = 1;
guidata(hObject,handles)


% --- Executes on button press in help.
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function featureOptRoundEdit_Callback(hObject, eventdata, handles)
% hObject    handle to featureOptRoundEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of featureOptRoundEdit as text
%        str2double(get(hObject,'String')) returns contents of featureOptRoundEdit as a double
handles.NBSPredict.optSteps = str2double(get(hObject,'String'));
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function featureOptRoundEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to featureOptRoundEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.NBSPredict.optSteps = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes on button press in HyperOptCheck.
function HyperOptCheck_Callback(hObject, eventdata, handles)
% hObject    handle to HyperOptCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of HyperOptCheck
handles.NBSPredict.ifHyperOpt = get(hObject,'Value');
guidata(hObject,handles)


function hyperOptEdit_Callback(hObject, eventdata, handles)
% hObject    handle to hyperOptEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hyperOptEdit as text
%        str2double(get(hObject,'String')) returns contents of hyperOptEdit as a double
handles.NBSPredict.hyperOptSteps = str2double(get(hObject,'String'));
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function hyperOptEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hyperOptEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.NBSPredict.hyperOptSteps = str2double(get(hObject,'String'));
guidata(hObject,handles)


% --- Executes on button press in runNBSPredict.
function runNBSPredict_Callback(hObject, eventdata, handles)
% hObject    handle to runNBSPredict (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Check matrices!
[handles,nIdx] = val_nbsPredictGUI(handles);

if nIdx == 0 
    if ~isfield(handles.NBSPredict,'test') || ~ismember(handles.NBSPredict.test,handles.testpop.String)
        handles.NBSPredict.test = handles.testpop.String{1};
    end
    if ~isfield(handles.NBSPredict,'metric') || ~ismember(handles.NBSPredict.metric,handles.metricpop.String)
        handles.NBSPredict.metric = lower(handles.metricpop.String{1});
    end
    run_nbsPredict(handles.NBSPredict);
end

function featureOptSelectNumEdit_Callback(hObject, eventdata, handles)
% hObject    handle to featureOptSelectNumEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of featureOptSelectNumEdit as text
%        str2double(get(hObject,'String')) returns contents of featureOptSelectNumEdit as a double
handles.NBSPredict.optSelNum = str2double(get(hObject,'String'));
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function featureOptSelectNumEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to featureOptSelectNumEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.NBSPredict.optSelNum = str2double(get(hObject,'String'));
guidata(hObject,handles)


function kFoldEdit_Callback(hObject, eventdata, handles)
% hObject    handle to kFoldEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kFoldEdit as text
%        str2double(get(hObject,'String')) returns contents of kFoldEdit as a double
tmp = str2double(get(hObject,'String'));
if tmp == 0
    handles.NBSPredict.ifLOOCV = 1;
else
    handles.NBSPredict.ifLOOCV = 0;
    handles.NBSPredict.kFold = str2double(get(hObject,'String'));
end
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
handles.NBSPredict.ifLOOCV = 0;
handles.NBSPredict.kFold = str2double(get(hObject,'String'));
guidata(hObject,handles)


% --- Executes on selection change in metricpop.
function metricpop_Callback(hObject, eventdata, handles)
% hObject    handle to metricpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns metricpop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from metricpop
tmp = get(hObject,'String');
tmpIdx = get(hObject,'Value');
handles.NBSPredict.metric = lower(tmp{tmpIdx});
guidata(hObject,handles)


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
