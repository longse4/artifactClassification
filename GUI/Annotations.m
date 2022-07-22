function varargout = Annotations(varargin)
% ANNOTATIONS MATLAB code for Annotations.fig
%      ANNOTATIONS, by itself, creates a new ANNOTATIONS or raises the existing
%      singleton*.
%
%      H = ANNOTATIONS returns the handle to a new ANNOTATIONS or the handle to
%      the existing singleton*.
%
%      ANNOTATIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANNOTATIONS.M with the given input arguments.
%
%      ANNOTATIONS('Property','Value',...) creates a new ANNOTATIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Annotations_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Annotations_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Annotations

% Last Modified by GUIDE v2.5 12-Jan-2021 11:13:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Annotations_OpeningFcn, ...
                   'gui_OutputFcn',  @Annotations_OutputFcn, ...
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


% --- Executes just before Annotations is made visible.
function Annotations_OpeningFcn(hObject, eventdata, handles, varargin)
handles.spikeClass = 0;
handles.comments = 'NA';
handles.output = hObject;

handles.SpikeTimes = getappdata(0,'Times');
handles.CurrChannel = getappdata(0,'CurrChannel');
handles.NumContacts = getappdata(0,'NumContacts');

chan = strcat('chSelection',string(handles.CurrChannel));
%handles.(char(chan)).Value = 1;
handles.selectedChannels = zeros(handles.NumContacts,1);
%handles.selectedChannels(handles.CurrChannel,1) = 1;

for ch = 1:16
    chan = strcat('chSelection',string(ch));
    if ch > handles.NumContacts
        handles.(char(chan)).Visible = 'off';
    else
        handles.(char(chan)).Visible = 'on';
    end
end

guidata(hObject, handles);

% UIWAIT makes Annotations wait for user response (see UIRESUME)
% uiwait(handles.Annotations);


% --- Outputs from this function are returned to the command line.
function varargout = Annotations_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function timeDisplay_CreateFcn(hObject, eventdata, handles)
spikeTimes = getappdata(0,'Times');
hObject.String = string(round(diff(spikeTimes)*1000));


function commentBox_Callback(hObject, eventdata, handles)
handles.comments = get(hObject,'String');
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function commentBox_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pathButton.
function pathButton_Callback(hObject, eventdata, handles)
if get(hObject,'Value') ==1
    handles.spikeClass = 2;
end
guidata(hObject, handles);


% --- Executes on button press in artifactButton.
function artifactButton_Callback(hObject, eventdata, handles)
if get(hObject,'Value') ==1
    handles.spikeClass = 1;
end
guidata(hObject, handles);

% --- Executes on button press in doneButton.
function doneButton_Callback(hObject, eventdata, handles)
setappdata(0,'spikeClass',handles.spikeClass);
setappdata(0,'comments',handles.comments);
setappdata(0,'selectedChannels',handles.selectedChannels);
guidata(hObject,handles)
closereq


% --- Executes on button press in chSelection1.
function chSelection1_Callback(hObject, eventdata, handles)
% hObject    handle to chSelection1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chSelection1

handles.selectedChannels(1,1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in chSelection2.
function chSelection2_Callback(hObject, eventdata, handles)
% hObject    handle to chSelection2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chSelection2
handles.selectedChannels(2,1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in chSelection3.
function chSelection3_Callback(hObject, eventdata, handles)
% hObject    handle to chSelection3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chSelection3
handles.selectedChannels(3,1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in chSelection4.
function chSelection4_Callback(hObject, eventdata, handles)
% hObject    handle to chSelection4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chSelection4
handles.selectedChannels(4,1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in chSelection5.
function chSelection5_Callback(hObject, eventdata, handles)
% hObject    handle to chSelection5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chSelection5
handles.selectedChannels(5,1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in chSelection6.
function chSelection6_Callback(hObject, eventdata, handles)
% hObject    handle to chSelection6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chSelection6
handles.selectedChannels(6,1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in chSelection7.
function chSelection7_Callback(hObject, eventdata, handles)
% hObject    handle to chSelection7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chSelection7
handles.selectedChannels(7,1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in chSelection8.
function chSelection8_Callback(hObject, eventdata, handles)
% hObject    handle to chSelection8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chSelection8
handles.selectedChannels(8,1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in chSelection9.
function chSelection9_Callback(hObject, eventdata, handles)
% hObject    handle to chSelection9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chSelection9
handles.selectedChannels(9,1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in chSelection10.
function chSelection10_Callback(hObject, eventdata, handles)
% hObject    handle to chSelection10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chSelection10
handles.selectedChannels(10,1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in chSelection11.
function chSelection11_Callback(hObject, eventdata, handles)
% hObject    handle to chSelection11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chSelection11
handles.selectedChannels(11,1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in chSelection12.
function chSelection12_Callback(hObject, eventdata, handles)
% hObject    handle to chSelection12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chSelection12
handles.selectedChannels(12,1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in channel13.
function channel13_Callback(hObject, eventdata, handles)
% hObject    handle to channel13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of channel13
handles.selectedChannels(13,1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in chSelection14.
function chSelection14_Callback(hObject, eventdata, handles)
% hObject    handle to chSelection14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chSelection14
handles.selectedChannels(14,1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in chSelection15.
function chSelection15_Callback(hObject, eventdata, handles)
% hObject    handle to chSelection15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chSelection15
handles.selectedChannels(15,1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in chSelection16.
function chSelection16_Callback(hObject, eventdata, handles)
% hObject    handle to chSelection16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chSelection16
handles.selectedChannels(16,1) = get(hObject,'Value');
guidata(hObject, handles);
