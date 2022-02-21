function varargout = run_NBSPredictWorkspace(varargin)
% RUN_NBSPREDICTWORKSPACE MATLAB code for run_NBSPredictWorkspace.fig
%      RUN_NBSPREDICTWORKSPACE, by itself, creates a new RUN_NBSPREDICTWORKSPACE or raises the existing
%      singleton*.
%
%      H = RUN_NBSPREDICTWORKSPACE returns the handle to a new RUN_NBSPREDICTWORKSPACE or the handle to
%      the existing singleton*.
%
%      RUN_NBSPREDICTWORKSPACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUN_NBSPREDICTWORKSPACE.M with the given input arguments.
%
%      RUN_NBSPREDICTWORKSPACE('Property','Value',...) creates a new RUN_NBSPREDICTWORKSPACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before run_NBSPredictWorkspace_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to run_NBSPredictWorkspace_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help run_NBSPredictWorkspace

% Last Modified by GUIDE v2.5 30-Oct-2021 20:12:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @run_NBSPredictWorkspace_OpeningFcn, ...
                   'gui_OutputFcn',  @run_NBSPredictWorkspace_OutputFcn, ...
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


% --- Executes just before run_NBSPredictWorkspace is made visible.
function run_NBSPredictWorkspace_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to run_NBSPredictWorkspace (see VARARGIN)

% Choose default command line output for run_NBSPredictWorkspace
handles.output = hObject;

refDir = fileparts(which('start_NBSPredict'));
workspaceDatabaseDir = [refDir,filesep, 'workspaces.mat'];
handles.workspaceDatabaseDir = workspaceDatabaseDir;
if exist(workspaceDatabaseDir, 'file') == 2
    load(workspaceDatabaseDir);
    if ~isempty(workspaces)
        existIdx = [];
        for w = 1: numel(workspaces)
           if exist(workspaces{w}, 'dir')
              existIdx = [existIdx(:); w]; 
           else
               warning('The following directory cannot be found; thus, will be removed from the database: \n\n%s\n',...
                   workspaces{w})
           end
        end
        workspaces = workspaces(existIdx);
        save(workspaceDatabaseDir, 'workspaces');
        if ~isempty(workspaces)
            handles.workspaces = workspaces; 
            set(handles.workspaceList, 'String', workspaces);
            handles.cWorkspace = handles.workspaces{1};
        else
            msg = ['None of saved workspaces is found! ',...
                'Please check your directory and load the workspaces again!'];
            warning(msg)
%             errordlg('None of saved workspaces is found! Please check your directory!')
        end
    end
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes run_NBSPredictWorkspace wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = run_NBSPredictWorkspace_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function workspaceList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to workspaceList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function workspaceNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to workspaceNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of workspaceNameEdit as text
%        str2double(get(hObject,'String')) returns contents of workspaceNameEdit as a double
workspaceName = get(hObject,'String');
selectDir = uigetdir(pwd, 'Select directory for the workspace!');
if selectDir ~= 0
    workspaceDir = [selectDir,filesep, workspaceName,filesep];
    set(hObject, 'String', workspaceDir);
    handles.workspaceName = workspaceName;
    handles.workspaceDir = workspaceDir;
else
    set(hObject, 'String', '');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function workspaceNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to workspaceNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in createPush.
function createPush_Callback(hObject, eventdata, handles)
% hObject    handle to createPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles, 'workspaceDir')
    if ~exist(handles.workspaceDir, 'dir')
        status = mkdir(handles.workspaceDir);
        if status == 1
            set(hObject, 'ForegroundColor','green');
            if isfield(handles, 'workspaces')
                handles.workspaces = {handles.workspaceDir, handles.workspaces{:}};
            else
                handles.workspaces = {handles.workspaceDir};
            end
            
            try
                save_workspace(handles);
            catch
                error('Workspace database cannot be saved! Check permissions!')
            end
            handles = update_workspace(handles);
        else
            set(hObject, 'ForegroundColor','red');
            errordlg('The workspace cannot be created! Please check permissions!')
        end
    else
        set(hObject, 'ForegroundColor','red');
        errordlg('The workspace already exists!')
    end
    guidata(hObject, handles);
end


% --- Executes on selection change in workspaceList.
function workspaceList_Callback(hObject, eventdata, handles)
% hObject    handle to workspaceList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns workspaceList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from workspaceList
workspaceIdx = get(hObject, 'Value');
handles.cWorkspace = handles.workspaces{workspaceIdx};
guidata(hObject, handles);


% --- Executes on button press in loadPush.
function loadPush_Callback(hObject, eventdata, handles)
% hObject    handle to loadPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
workspaceDir = uigetdir(pwd, 'Select workspace!');
if workspaceDir ~= 0
    if isfield(handles, 'workspaces')
        handles.workspaces = {workspaceDir, handles.workspaces{:}};
    else
        handles.workspaces = {workspaceDir};
    end
    handles = update_workspace(handles);
    save_workspace(handles);
    guidata(hObject, handles);
end


% --- Executes on button press in removeButton.
function removeButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'workspaces')
    handles.workspaces(handles.workspaceList.Value) = [];
    if ~isempty(handles.workspaces)
        handles = update_workspace(handles);
    else
        set(handles.workspaceList, 'String', handles.workspaces);
        handles = rmfield(handles,'cWorkspace');
    end
    save_workspace(handles);
end
guidata(hObject, handles);


% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles, 'cWorkspace')
    if exist(handles.cWorkspace, 'dir')
        handles.workspaces(handles.workspaceList.Value) = [];
        handles.workspaces = {handles.cWorkspace, handles.workspaces{:}};
        save_workspace(handles);
        cd(handles.cWorkspace);
        closereq;
        run_NBSPredictGUI();
    else
        errordlg('The workspace cannot be found! Please check your directory!')
        set(hObject, 'ForegroundColor','red');
    end
end


function save_workspace(handles)
% Saves workspace database into main NBS-Predict directory.
workspaces = handles.workspaces;
save(handles.workspaceDatabaseDir, 'workspaces')


function handles = update_workspace(handles)
% Updates list box with the current workspaces. 
% Set current workspace to the first workspace on the workspace list.
set(handles.workspaceList, 'String', handles.workspaces);
handles.cWorkspace = handles.workspaces{1};
set(handles.workspaceList, 'Value', 1);
