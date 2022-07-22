function varargout = AddClassification(varargin)
% ADDCLASSIFICATION MATLAB code for AddClassification.fig
%      ADDCLASSIFICATION, by itself, creates a new ADDCLASSIFICATION or raises the existing
%      singleton*.
%
%      H = ADDCLASSIFICATION returns the handle to a new ADDCLASSIFICATION or the handle to
%      the existing singleton*.
%
%      ADDCLASSIFICATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDCLASSIFICATION.M with the given input arguments.
%
%      ADDCLASSIFICATION('Property','Value',...) creates a new ADDCLASSIFICATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddClassification_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddClassification_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AddClassification

% Last Modified by GUIDE v2.5 25-Jun-2021 11:47:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddClassification_OpeningFcn, ...
                   'gui_OutputFcn',  @AddClassification_OutputFcn, ...
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


% --- Executes just before AddClassification is made visible.
function AddClassification_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddClassification (see VARARGIN)

% Choose default command line output for AddClassification
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AddClassification wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AddClassification_OutputFcn(hObject, eventdata, handles) 


% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in artifactButton.
function artifactButton_Callback(hObject, eventdata, handles)

handles.eventClass = 1;
setappdata(1,'eventClass',handles.eventClass);
guidata(hObject,handles)
closereq


% --- Executes on button press in PathologyButton.
function PathologyButton_Callback(hObject, eventdata, handles)

handles.eventClass = 2;
setappdata(1,'eventClass',handles.eventClass);
guidata(hObject,handles)
closereq



% --- Executes on button press in PhysiologyButton.
function PhysiologyButton_Callback(hObject, eventdata, handles)

handles.eventClass = 3;
setappdata(1,'eventClass',handles.eventClass);
guidata(hObject,handles)
closereq
