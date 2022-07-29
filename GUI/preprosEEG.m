function varargout = preproSEEG(varargin)
% PREPROSEEG MATLAB code for preprosEEG.fig
%      PREPROSEEG, by itself, creates a new PREPROSEEG or raises the existing
%      singleton*.
%
%      H = PREPROSEEG returns the handle to a new PREPROSEEG or the handle to
%      the existing singleton*.
%
%      PREPROSEEG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREPROSEEG.M with the given input arguments.
%
%      PREPROSEEG('Property','Value',...) creates a new PREPROSEEG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before preprosEEG_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to preprosEEG_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help preprosEEG

% Last Modified by GUIDE v2.5 22-Jul-2022 13:37:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @preprosEEG_OpeningFcn, ...
                   'gui_OutputFcn',  @preprosEEG_OutputFcn, ...
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


% --- Executes just before preprosEEG is made visible.
function preprosEEG_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to preprosEEG (see VARARGIN)

% Choose default command line output for preprosEEG
clear('global')
global ppsEEG
ppsEEG.preproInfo.SoftStep = 1;
handles.output = hObject;
movegui('center')
axes(handles.axesLogo);
imshow('logo.png')
% Update handles structure
guidata(hObject, handles);
ppsEEG.preproInfo.steps.ReviewData = 1;
ppsEEG.preproInfo.steps.RefData= 1;
ppsEEG.preproInfo.steps.ReviewRefData = 1;
ppsEEG.preproInfo.steps.ClassData = 1;
ppsEEG.preproInfo.RefMethod = 'Bipolar';




% --- Outputs from this function are returned to the command line.
function varargout = preprosEEG_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function editPath_Callback(hObject, eventdata, handles)
% hObject    handle to editPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function editPath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbtnFOpen.
function pushbtnFOpen_Callback(hObject, eventdata, handles)

global ppsEEG
folder = strcat(handles.editSubFolder.String,'\','*.dat;*.edf');
[files,dir] = uigetfile(folder,'Select the file(s)','multiselect','on');

set(gcf,'pointer','watch')
drawnow;

if(~iscell(files))
    files=cellstr(files);
end

handles.editPath.String = [dir files{1,1}];

if contains(files{1},'.dat')
    [signal,states,params] = load_dat_file(handles.editSubFolder.String,files);
    ppsEEG.data.states = states;
    ppsEEG.data.params = params;
    ppsEEG.preproInfo.samplingRate = params.SamplingRate.NumericValue;
  
else 
    cfg = [];
    cfg.dataset = handles.editPath.String;
    data_eeg    = ft_preprocessing(cfg);
    if size(data_eeg.trial,2)==1
        signal = data_eeg.trial{1,1};
        ppsEEG.preproInfo.samplingRate = data_eeg.sampleinfo;
    else
        errordlg('Data file must be continuous (single trial format)','File Error');
    end
end
    

ppsEEG.preproInfo.subjectFile = files;
ppsEEG.preproInfo.pcUser = getenv('username');

if handles.popupLineNoise.Value ==1
    ppsEEG.preproInfo.lineNoise = 60;
    
elseif handles.popupLineNoise.Value ==2
    ppsEEG.preproInfo.lineNoise = 50;
end

% Add raw data
if handles.chkBoxUnreferenced.Value == 1
    ppsEEG.data.signals.origSignal = signal;
end

ppsEEG.data.signals.signalComb60Hz = comb_filter60Hz(signal,ppsEEG.preproInfo.samplingRate,ppsEEG.preproInfo.lineNoise);
set(gcf,'pointer','arrow')
drawnow;

% --- Executes on button press in pushbtnFolder.
function pushbtnFolder_Callback(hObject, eventdata, handles)
global ppsEEG
pathname = uigetdir('','Open Subject Directory');
if ~isequal(pathname,0)
    handles.editSubFolder.String = pathname;
    ppsEEG.preproInfo.subjectPath = pathname;
    ppsFileLog = string([pathname '\ppsEEG.mat']);
    if exist(ppsFileLog)
        answer = questdlg('We found previous steps completed. Proceed to last finsihed step?', ...
            'Log File Found','Yes','Start Over','Yes');
        if isequal(answer,'Yes')
            wb = waitbar(0,'Loading data...','windowstyle', 'modal');
            wbch = allchild(wb);
            wbch(1).JavaPeer.setIndeterminate(1);
            ppsFileLog = [ppsEEG.preproInfo.subjectPath '\ppsEEG.mat'];
            ppsEEG = load(ppsFileLog);
            close(wb)
            closereq
            switch ppsEEG.preproInfo.SoftStep                
                case 2 
                    reviewData
                case 3 
                    reviewRefData                   
                case 4 
                    SpikeDetection
            end
        end
    end
end

function signalfilt = comb_filter60Hz(signal,fs,fo)
%Notch Filter 
%fo = 60; %Hz
Q = 50; %quality factor
bw = (fo/(fs/2))/Q;
[b,a] = iircomb(fs/fo,bw,'notch');
signalfilt = filtfilt(b,a,double(signal));

% --- Executes on button press in pushbtnNext.
function pushbtnNext_Callback(hObject, eventdata, handles)

global ppsEEG


if ppsEEG.preproInfo.steps.ReviewData ==1
    ppsEEG.preproInfo.SoftStep = 2;
elseif ppsEEG.preproInfo.steps.RefData == 1
    ppsEEG.preproInfo.SoftStep = 3;
elseif ppsEEG.preproInfo.steps.ReviewRefData ==1
    ppsEEG.preproInfo.SoftStep = 3;
elseif ppsEEG.preproInfo.steps.ClassData ==1
    ppsEEG.preproInfo.SoftStep = 4;    
else
    errordlg('Need to reference data','File Error');
end

answer = questdlg('Do you want to backup this step?', ...
    'Saving Backup','Yes','No','Yes');

if isequal(answer,'Yes')
    wb = waitbar(0,'Backing up data...','windowstyle', 'modal');
    wbch = allchild(wb);
    wbch(1).JavaPeer.setIndeterminate(1);
    ppsFileLog = [ppsEEG.preproInfo.subjectPath '\ppsEEG.mat'];
    save(ppsFileLog,'-struct','ppsEEG','-v7.3')
    close(wb)
end
closereq

switch ppsEEG.preproInfo.SoftStep
    case 2
        reviewData
    case 3 
        reviewRefData
    case 4
        SpikeDetection
end


function editSubFolder_Callback(hObject, eventdata, handles)
% hObject    handle to editSubFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function editSubFolder_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editCsvPath_Callback(hObject, eventdata, handles)
% hObject    handle to editSubFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function editCsvPath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonCSV.
function pushbuttonCSV_Callback(hObject, eventdata, handles)
global ppsEEG
folder = strcat(handles.editSubFolder.String,'\','*.csv');
[filename,pathname] = uigetfile(folder,'Select the Electrode Info');
handles.editCsvPath.String = [pathname filename];
elec_info = readtable([pathname '\' filename]);

% Number of individual probes/leads + mapping of channels to leads
if ~any(strcmp('LeadNum',elec_info.Properties.VariableNames))==1
    errordlg('csv file must contain field "LeadNum"','File Error');
else
    ppsEEG.preproInfo.leadsInfo.numLeads = max(elec_info.LeadNum);
    ppsEEG.preproInfo.leadsInfo.leadNums = elec_info.LeadNum;
end

% Reference channel
if ~any(strcmp('Ref',elec_info.Properties.VariableNames))==1
    errordlg('csv file must contain field "Ref"','File Error');
else 
    ppsEEG.preproInfo.leadsInfo.refChannel = ...
        elec_info.Label(double(cellfun(@(x) ~isempty(x), elec_info.Ref))==1);
end
% SOZ channel(s)
if ~any(strcmp('SOZ_Label',elec_info.Properties.VariableNames))==1 
    errordlg('csv file must contain field "SOZ_Label"','File Error');
else 
    ppsEEG.preproInfo.leadsInfo.sozChannel = ...
        cellfun(@(x) ~isempty(x), elec_info.SOZ_Label);
end

% SOZ channel(s)
if ~any(strcmp('SOZ_Label',elec_info.Properties.VariableNames))==1 
    errordlg('csv file must contain field "SOZ_Label"','File Error');
else 
    ppsEEG.preproInfo.leadsInfo.sozChannel = ...
        cellfun(@(x) ~isempty(x), elec_info.SOZ_Label);
end

% Channel names + anatomical information
if ~any(strcmp('Label',elec_info.Properties.VariableNames))==1
    errordlg('csv file must contain field "Label"','File Error');
elseif ~any(strcmp('Anat_Label',elec_info.Properties.VariableNames))==1 
    errordlg('csv file must contain field "Anat_Label"','File Error');     
else
    for ch = 1:ppsEEG.preproInfo.leadsInfo.numLeads
        ppsEEG.preproInfo.leadsInfo.channelNames{1,ch}=...
            elec_info.Label(elec_info.LeadNum==ch);
%         
%         ppsEEG.preproInfo.leadsInfo.anatGeneral{1,ch}=...
%             elec_info.Anat_mapping(elec_info.LeadNum==ch);     
        
        ppsEEG.preproInfo.leadsInfo.anatSegmentation{1,ch}=...
            elec_info.Anat_Label(elec_info.LeadNum==ch);
    end
end

%elec_info = table2cell(elec_info);
%elec_info(cellfun('isempty',elec_info))={NaN};
ppsEEG.preproInfo.leadsInfo.clinicalInfo = elec_info;
handles.pushbtnNext.Enable = 'on';




% --- Executes on button press in chkBoxUnreferenced.
function chkBoxUnreferenced_Callback(hObject, eventdata, handles)
% hObject    handle to chkBoxUnreferenced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkBoxUnreferenced
global ppsEEG
ppsEEG.preproInfo.flags.SaveUnreferenced = get(hObject,'Value');



% --- Executes on button press in chkBoxReferenced.
function chkBoxReferenced_Callback(hObject, eventdata, handles)
% hObject    handle to chkBoxReferenced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkBoxReferenced
global ppsEEG
ppsEEG.preproInfo.flags.SaveReferenced = get(hObject,'Value');


% --- Executes on button press in chkBoxSpikeDetection.
function chkBoxSpikeDetection_Callback(hObject, eventdata, handles)
% hObject    handle to chkBoxSpikeDetection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkBoxSpikeDetection
global ppsEEG
ppsEEG.preproInfo.flags.SpikeDetection = get(hObject,'Value');


% --- Executes on button press in chkBoxReviewData.
function chkBoxReviewData_Callback(hObject, eventdata, handles)
% hObject    handle to chkBoxReviewData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkBoxReviewData
global ppsEEG
ppsEEG.preproInfo.steps.ReviewData = get(hObject,'Value');



% --- Executes on button press in chkBoxRefData.
function chkBoxRefData_Callback(hObject, eventdata, handles)
% hObject    handle to chkBoxRefData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkBoxRefData
global ppsEEG
ppsEEG.preproInfo.steps.RefData = get(hObject,'Value');



% --- Executes on selection change in popupReferenceMethod.
function popupReferenceMethod_Callback(hObject, eventdata, handles)
% hObject    handle to popupReferenceMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupReferenceMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupReferenceMethod
global ppsEEG
temp = get(hObject,'Value');
switch temp
    case 1 
        ppsEEG.preproInfo.RefMethod = 'CAR';
    case 2
        ppsEEG.preproInfo.RefMethod  = 'Bipolar';
end
        



% --- Executes during object creation, after setting all properties.
function popupReferenceMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupReferenceMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkBoxClassData.
function chkBoxClassData_Callback(hObject, eventdata, handles)
% hObject    handle to chkBoxClassData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkBoxClassData
global ppsEEG
ppsEEG.preproInfo.steps.ClassData = get(hObject,'Value');



% --- Executes on button press in chkBoxReviewRefData.
function chkBoxReviewRefData_Callback(hObject, eventdata, handles)
% hObject    handle to chkBoxReviewRefData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkBoxReviewRefData
global ppsEEG
ppsEEG.preproInfo.steps.ReviewRefData = get(hObject,'Value');



% --- Executes on selection change in popupLineNoise.
function popupLineNoise_Callback(hObject, eventdata, handles)
% hObject    handle to popupLineNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupLineNoise contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupLineNoise



% --- Executes during object creation, after setting all properties.
function popupLineNoise_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupLineNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function chkBoxUnreferenced_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chkBoxUnreferenced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ppsEEG
ppsEEG.preproInfo.flags.SaveUnreferenced = get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function chkBoxReferenced_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chkBoxReferenced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ppsEEG
ppsEEG.preproInfo.flags.SaveReferenced = get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function chkBoxSpikeDetection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chkBoxSpikeDetection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global ppsEEG
ppsEEG.preproInfo.flags.SpikeDetection = get(hObject,'Value');
