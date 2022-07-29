function varargout = reviewRefData(varargin)
% REVIEWREFDATA MATLAB code for reviewRefData.fig
%      REVIEWREFDATA, by itself, creates a new REVIEWREFDATA or raises the existing
%      singleton*.
%
%      H = REVIEWREFDATA returns the handle to a new REVIEWREFDATA or the handle to
%      the existing singleton*.
%
%      REVIEWREFDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REVIEWREFDATA.M with the given input arguments.
%
%      REVIEWREFDATA('Property','Value',...) creates a new REVIEWREFDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before reviewRefData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to reviewRefData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help reviewRefData

% Last Modified by GUIDE v2.5 18-Mar-2020 15:00:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @reviewRefData_OpeningFcn, ...
                   'gui_OutputFcn',  @reviewRefData_OutputFcn, ...
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


% --- Executes just before reviewRefData is made visible.
function reviewRefData_OpeningFcn(hObject, eventdata, handles, varargin)
global ppsEEG
ppsEEG.preproInfo.SoftStep = 3;
handles.output = hObject;
movegui('center')

% Check if ppsEEG struct exists 
if ~isfield(ppsEEG.data.signals,'signalCAR')
    wb = waitbar(0,'Leadbased CAR...','windowstyle', 'modal');
    wbch = allchild(wb);
    wbch(1).JavaPeer.setIndeterminate(1);
    LeadBasedCAR
    close(wb)
end

handles.leadOn = 1;
handles.ampSpam = 10;

read_checkboxes(handles);
% Update handles structure
guidata(hObject, handles);
show_checkboxes(handles)
read_checkboxes(handles)
plot_sEEG(hObject,handles)

% --- Outputs from this function are returned to the command line.
function varargout = reviewRefData_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% ---
function show_checkboxes(handles)
global ppsEEG
if strcmp(ppsEEG.preproInfo.RefMethod,'CAR')
    namesContacts = ppsEEG.preproInfo.leadsInfo.channelNames{1,handles.leadOn};
elseif strcmp(ppsEEG.preproInfo.RefMethod,'Bipolar')
    namesContacts = ppsEEG.preproInfo.bipolarInfo.channelNames{1,handles.leadOn};
end
numContacts = length(namesContacts);
handles.txtRef.Visible = 'off';
for i=1:16
    chkObj = findobj('Tag',sprintf('chkVal%d',i));
    if i > numContacts
        chkObj.Visible = 'off';
    else
        chkObj.Visible = 'on';
        chkObj.String = sprintf('%d, %s',i,namesContacts{i});
    end
end

% ---
function read_checkboxes(handles)
global ppsEEG
if strcmp(ppsEEG.preproInfo.RefMethod,'CAR')
    rejected = ppsEEG.preproInfo.leadsInfo.rejected{handles.leadOn};
elseif strcmp(ppsEEG.preproInfo.RefMethod,'Bipolar')
    rejected = ppsEEG.preproInfo.bipolarInfo.rejected{handles.leadOn};
end 
for i=1:length(rejected)
    chkObj = findobj('Tag',sprintf('chkVal%d',i));
    chkObj.Value = rejected(i);
end

% ---
function write_checkboxes(handles)
global ppsEEG
if strcmp(ppsEEG.preproInfo.RefMethod,'CAR')
    rejected = ppsEEG.preproInfo.leadsInfo.rejected{handles.leadOn};
elseif strcmp(ppsEEG.preproInfo.RefMethod,'Bipolar')
    rejected = ppsEEG.preproInfo.bipolarInfo.rejected{handles.leadOn};
end 
for i=1:length(rejected)
    chkObj = findobj('Tag',sprintf('chkVal%d',i));
    %rejected(i) = chkObj.Value;
    chkObj.Value = rejected(i);
end
if strcmp(ppsEEG.preproInfo.RefMethod,'CAR')
    ppsEEG.preproInfo.leadsInfo.rejected{handles.leadOn} = rejected;
elseif strcmp(ppsEEG.preproInfo.RefMethod,'Bipolar')
    ppsEEG.preproInfo.bipolarInfo.rejected{handles.leadOn} = rejected;
end 

% --- Plot multiple values ---
function plot_sEEG(hObject,handles)
global ppsEEG
axes(handles.axesSignal);
fs = ppsEEG.preproInfo.samplingRate;
leadName = char(ppsEEG.preproInfo.leadsInfo.channelNames{handles.leadOn}(1));
leadName = leadName(1:end-1);
chIdx = 0; 
if strcmp(ppsEEG.preproInfo.RefMethod,'CAR')
    numContacts = length(ppsEEG.preproInfo.leadsInfo.channelNames{handles.leadOn});
    if handles.leadOn > 1
        len = cellfun('length',ppsEEG.preproInfo.leadsInfo.channelNames);
        chIdx = sum(len(1:handles.leadOn-1));
    end
    data = ppsEEG.data.signals.signalCAR(:,chIdx+1:chIdx+numContacts);
elseif strcmp(ppsEEG.preproInfo.RefMethod,'Bipolar')
    numContacts = length(ppsEEG.preproInfo.bipolarInfo.channelNames{handles.leadOn});
    data = ppsEEG.data.signals.signalBipolar{handles.leadOn};
    handles.leadLength = cellfun(@(x) size(x,2), ppsEEG.preproInfo.bipolarInfo.channelNames);
    reject = ppsEEG.preproInfo.bipolarInfo.rejected{handles.leadOn}; 
end

stdY = std(data(:));
midY = mean(data(:));
maxYax =  midY + handles.ampSpam*stdY;
minYax = midY - handles.ampSpam*stdY;
deltaYax = 2*(maxYax - minYax);
data = 1000*(data/deltaYax);
data = flip(data,2);
[NSamples,~] = size(data);
xAxis = (0:NSamples-1)./fs; 
xAxis = repmat(xAxis',1,numContacts);
idxMin = 1650 - numContacts*100;
offset = repmat(idxMin:100:1600,NSamples,1);

%dummy = zeros(NSamples,16);
%offset = repmat(50:100:1600,NSamples,1);
handles.axesSignal.ColorOrderIndex = 1;
plot(xAxis,data+offset)
hold on
handles.axesSignal.ColorOrderIndex = 1;
%handles.axesSignal
plot([zeros(1,numContacts);ones(1,numContacts)*((NSamples-1)/fs)],[idxMin:100:1600;idxMin:100:1600],'--');
hold off
%imagesc([180 198],[1000 1590],handles.leadImg, 'AlphaData', handles.leadImgAlpha)
xlim([0 50])
ylim([0 1600])
set(gca,'YTickLabel',[])
ylabel(sprintf('Amplitude [%d uV/div]',round(deltaYax/2)))
xlabel('Time (sec)')
numLeads = ppsEEG.preproInfo.leadsInfo.numLeads;
title(sprintf('Lead %s [%d/%d], %d contacts',leadName,handles.leadOn,numLeads,numContacts))
grid on
grid minor

% --- Executes on button press in pushbtnNext.
function pushbtnNext_Callback(hObject, eventdata, handles)
global ppsEEG
numLeads = ppsEEG.preproInfo.leadsInfo.numLeads;
if handles.leadOn < numLeads
    handles.leadOn = handles.leadOn + 1; 
    %write_checkboxes(handles);
    show_checkboxes(handles);
    read_checkboxes(handles);
    plot_sEEG(hObject,handles)
    chkVal_updateaxes(handles)
    handles.pushbuttonBack.Enable = 'on';
    if handles.leadOn == numLeads
        handles.pushbtnNext.String = 'Save & Next >>';
    end
    guidata(hObject, handles);
elseif handles.leadOn == numLeads
    %write_checkboxes(handles);
    answer = questdlg('Do you want to backup this step?', ...
            'Saving Backup','Yes','No','Yes');
    if isequal(answer,'Yes') 
        wb = waitbar(0,'Backing up data...','windowstyle', 'modal');
        wbch = allchild(wb);
        wbch(1).JavaPeer.setIndeterminate(1);     
        ppsEEG.preproInfo.SoftStep = 5;
        ppsFileLog = [ppsEEG.preproInfo.subjectPath '\ppsEEG.mat'];
        save(ppsFileLog,'-struct','ppsEEG','-v7.3')
        close(wb)
    end
    ppsEEG.preproInfo.SoftStep = 4;
    closereq
    SpikeDetection
    %close(reviewData)
end


% --- Executes on button press in pushbuttonBack.
function pushbuttonBack_Callback(hObject, eventdata, handles)
global ppsEEG
numLeads = ppsEEG.preproInfo.leadsInfo.numLeads;
if handles.leadOn > 1
    handles.leadOn = handles.leadOn - 1;
    %write_checkboxes(handles);
    guidata(hObject, handles);
    show_checkboxes(handles)
    read_checkboxes(handles);
    plot_sEEG(hObject,handles)
    chkVal_updateaxes(handles)
    handles.pushbtnNext.String = 'Next >>';
    if handles.leadOn == 1
        handles.pushbuttonBack.Enable = 'off';
    else
        
    end
end


% --------------------------------------------------------------------
function uitoggletoolZoom_ClickedCallback(hObject, eventdata, handles)
zoom xon

% --------------------------------------------------------------------
function uitoggletoolPan_ClickedCallback(hObject, eventdata, handles)
pan xon 

% --- Executes on button press in chkVal1.
function chkVal_Callback(hObject, eventdata, handles)
global ppsEEG
plots = handles.axesSignal.Children;
if strcmp(ppsEEG.preproInfo.RefMethod,'CAR')
    numContacts = length(ppsEEG.preproInfo.leadsInfo.channelNames{handles.leadOn});
elseif strcmp(ppsEEG.preproInfo.RefMethod,'Bipolar')
    numContacts = length(ppsEEG.preproInfo.bipolarInfo.channelNames{handles.leadOn});
end 
contact = sscanf(hObject.Tag,'chkVal%d');
%plots(contact + numContacts).Visible = ~hObject.Value;
if hObject.Value == true
    plots(contact + numContacts).Visible = 'off';
    if strcmp(ppsEEG.preproInfo.RefMethod,'CAR')
        ppsEEG.preproInfo.leadsInfo.rejected{handles.leadOn}(contact)=1;
    elseif strcmp(ppsEEG.preproInfo.RefMethod,'Bipolar')
        ppsEEG.preproInfo.bipolarInfo.rejected{handles.leadOn}(contact)=1;
    end
elseif hObject.Value == false
    plots(contact + numContacts).Visible = 'on';
    if strcmp(ppsEEG.preproInfo.RefMethod,'CAR')
        ppsEEG.preproInfo.leadsInfo.rejected{handles.leadOn}(contact)=0;
    elseif strcmp(ppsEEG.preproInfo.RefMethod,'Bipolar')
        ppsEEG.preproInfo.bipolarInfo.rejected{handles.leadOn}(contact)=0;
    end
end

function chkVal_updateaxes(handles)
global ppsEEG
if strcmp(ppsEEG.preproInfo.RefMethod,'CAR')
    rejected = ppsEEG.preproInfo.leadsInfo.rejected{handles.leadOn};
    numContacts = length(ppsEEG.preproInfo.leadsInfo.channelNames{handles.leadOn});
elseif strcmp(ppsEEG.preproInfo.RefMethod,'Bipolar')
    rejected = ppsEEG.preproInfo.bipolarInfo.rejected{handles.leadOn};
    numContacts = length(ppsEEG.preproInfo.bipolarInfo.channelNames{handles.leadOn});
end 

plots = handles.axesSignal.Children;

for i=1:length(rejected)
    %plots(numContacts + i).Visible = ~rejected(i);
    if rejected(i) == false
        plots(numContacts + i).Visible = 'on';
    elseif rejected(i) == true
        plots(numContacts + i).Visible = 'off';
    end
end

% --- Executes on button press in pushbtnPamRight.
function pushbtnPamRight_Callback(hObject, eventdata, handles)
axes(handles.axesSignal);
xl = xlim;
delta = diff(xl);
newxl = xl(1)-delta;
if newxl < 0 
    xlim([0 delta])
else
    xlim([newxl (xl(1))])
end


% --- Executes on button press in pushbtnPamLeft.
function pushbtnPamLeft_Callback(hObject, eventdata, handles)
global ppsEEG
fs = ppsEEG.preproInfo.samplingRate;

maxX = size(ppsEEG.data.signals.signalCAR,1)/fs;
axes(handles.axesSignal);
xl = xlim;
delta = diff(xl);
newxl = xl(2)+delta;
if newxl > maxX
    xlim([(maxX-delta) maxX])
else
    xlim([xl(2) newxl])
end

% --- Executes on selection change in popupSpam.
function popupSpam_Callback(hObject, eventdata, handles)
switch get(hObject,'Value')
    case 1
        handles.ampSpam = 20;
    case 2
        handles.ampSpam = 10;
    case 3
        handles.ampSpam = 5;
end
guidata(hObject, handles);
plot_sEEG(hObject,handles)
chkVal_updateaxes(handles)

% --- Executes during object creation, after setting all properties.
function popupSpam_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
