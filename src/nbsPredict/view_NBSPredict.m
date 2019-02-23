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

% Last Modified by GUIDE v2.5 21-Feb-2019 17:52:34

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
handles.output = hObject;
handles.NBSPredict = varargin{1};
% Update handles structure
[handles.userData.adj,handles.userData.G,handles.userData.labels] =...
    update_NBSPredictFigure(handles.NBSPredict,0);
handles.uitable1.Data = table2cell(table(handles.userData.labels,...
    degree(handles.userData.G)));
handles.userData.nFigure = 1; 
imagesc(handles.userData.adj);
colormap(parula);
colorbar;
set(gca,'XTick',[],'YTick',[]);
guidata(hObject, handles);

% UIWAIT makes view_NBSPredict wait for user response (see UIRESUME)
% uiwait(handles.figure1);


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
handles.userData.wThresh = str2double(get(hObject,'String'));
[handles.userData.adj,handles.userData.G,handles.userData.labels] =...
    update_NBSPredictFigure(handles.NBSPredict,handles.userData.wThresh);
switch handles.userData.nFigure
    case 1
        imagesc(handles.userData.adj);
        colormap(parula);
        colorbar;
        set(gca,'XTick',[],'YTick',[]);
    case 2
        plot(handles.userData.G,'EdgeCData',handles.userData.G.Edges.Weight,...
            'MarkerSize',degree(handles.userData.G),'LineWidth',3,...
            'NodeLabel',[]);
    case 3
        hist(handles.userData.G.Edges.Weight);
        xlabel('Weight')
        ylabel('# of Nodes')
end
handles.uitable1.Data = table2cell(table(handles.userData.labels,...
    degree(handles.userData.G)));
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
handles.userData.wThresh = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes on button press in networkPush.
function networkPush_Callback(hObject, eventdata, handles)
% hObject    handle to networkPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plot(handles.userData.G,'EdgeCData',handles.userData.G.Edges.Weight,...
    'MarkerSize',degree(handles.userData.G),'LineWidth',3,...
    'NodeLabel',[]);
handles.userData.nFigure = 2;
guidata(hObject,handles)


% --- Executes on button press in adjacencyPush.
function adjacencyPush_Callback(hObject, eventdata, handles)
% hObject    handle to adjacencyPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imagesc(handles.userData.adj);
colormap(parula);
colorbar;
set(gca,'XTick',[],'YTick',[]);
handles.userData.nFigure = 1;
guidata(hObject,handles)


% --- Executes on button press in distPush.
function distPush_Callback(hObject, ~, handles)
% hObject    handle to distPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hist(handles.userData.G.Edges.Weight);
xlabel('Weight')
ylabel('# of Nodes')
handles.userData.nFigure = 3;
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
figure;
copyobj(handles.figureAxes,gcf);
switch handles.userData.nFigure
    case 1
        print(gcf,['weightAdj_',num2str(handles.userData.wThresh),'.pdf'],'-dpdf','-r0'); % Save plot
    case 2
        print(gcf,['weightNet_',num2str(handles.userData.wThresh),'.pdf'],'-dpdf','-r0'); % Save plot
    case 3
        print(gcf,['weightDist_',num2str(handles.userData.wThresh),'.pdf'],'-dpdf','-r0'); % Save plot
end
close(gcf)
