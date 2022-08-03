function varargout = SpikeDetection(varargin)
% SPIKEDETECTION MATLAB code for SpikeDetection.fig
%      SPIKEDETECTION, by itself, creates a new SPIKEDETECTION or raises the existing
%      singleton*.
%
%      H = SPIKEDETECTION returns the handle to a new SPIKEDETECTION or the handle to
%      the existing singleton*.
%
%      SPIKEDETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPIKEDETECTION.M with the given input arguments.
%
%      SPIKEDETECTION('Property','Value',...) creates a new SPIKEDETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpikeDetection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpikeDetection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpikeDetection

% Last Modified by GUIDE v2.5 21-Jul-2022 13:01:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpikeDetection_OpeningFcn, ...
                   'gui_OutputFcn',  @SpikeDetection_OutputFcn, ...
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


% --- Executes just before SpikeDetection is made visible.
function SpikeDetection_OpeningFcn(hObject, eventdata, handles, varargin)
global ppsEEG
ppsEEG.preproInfo.SoftStep = 4;
handles.output = hObject;
movegui('center')

% Default values
handles.leadOn = 1;
handles.ampSpam = 10;
handles.resetValue = true;
if strcmp(ppsEEG.preproInfo.RefMethod, 'Bipolar') 
    handles.signalType = 'signalBipolar';
    handles.leadLengths = cellfun(@(x) size(x,2),ppsEEG.data.signals.signalBipolar);
elseif strcmp(ppsEEG.preproInfo.RefMethod, 'CAR') 
    handles.signalType = 'signalCAR';
    handles.leadLengths = cellfun(@(x) size(x,1),ppsEEG.preproInfo.leadsInfo.channelNames);
end
handles.kValue = 3.6;
handles.timebase = 15;

% Update handles structure
handles = read_checkboxes(handles);
guidata(hObject, handles);
plot_sEEG(hObject,handles)
show_checkboxes(handles)

if isfield(ppsEEG.data, 'spikeDetection')
    handles.rerunClassButton.Visible = 'on';
    handles.mark.Visible = 'on';
    handles.undo.Visible = 'on';
    handles.buttonReclass.Visible = 'on';
    handles.runButton.BackgroundColor = [ 0.8 0.8 0.8];
end

axes(handles.legendAxis);
imshow('EventLegend.png');



% --- Outputs from this function are returned to the command line.
function varargout = SpikeDetection_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes during object creation, initial k-value
function kValue_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- K-value user input for spike detection threshold
function kValue_Callback(hObject, eventdata, handles)
handles.kValue = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes on button press of runButton.
function runButton_Callback(hObject, eventdata, handles)
runDetection(handles);
plot_sEEG(hObject,handles)

% --- Run spike detection and plot
function runDetection(handles)
global ppsEEG
fs = ppsEEG.preproInfo.samplingRate;
k = handles.kValue;

% open wait bar
wb = waitbar(0,'Running spike detection (will take several minutes)...','windowstyle', 'modal');
wbch = allchild(wb);
wbch(1).JavaPeer.setIndeterminate(1);

if strcmp(handles.signalType,'signalBipolar')
    data = [ppsEEG.data.signals.(handles.signalType){1,1:length(ppsEEG.data.signals.(handles.signalType))}];
    handles.leadLengths = cellfun(@(x) size(x,2),ppsEEG.data.signals.signalBipolar);
    rejected = [ppsEEG.preproInfo.bipolarInfo.rejected{1,1:length(ppsEEG.preproInfo.bipolarInfo.rejected)}];

elseif strcmp(handles.signalType,'signalCAR')
    data = ppsEEG.data.signals.(handles.signalType);
    handles.leadLengths = cellfun('length',ppsEEG.preproInfo.leadsInfo.channelNames);  
    rejected = [ppsEEG.preproInfo.leadsInfo.rejected{1,1:length(ppsEEG.preproInfo.leadsInfo.rejected)}]; 
end

ppsEEG.preproInfo.spikeDetection.(handles.signalType).k = k;
disp('>>>Detecting potential events...');    
[ppsEEG.data.spikeDetection.(handles.signalType).markerLead,...
    ppsEEG.data.spikeDetection.(handles.signalType).markerLeadType,...
    ppsEEG.data.spikeDetection.(handles.signalType).markerAll,...
    ppsEEG.data.spikeDetection.(handles.signalType).markerAllType,...
    ppsEEG.data.spikeDetection.(handles.signalType).multi]...
    = PotentialEvents(data,rejected,fs,k,handles.leadLengths,'false',ppsEEG.preproInfo.lineNoise);

disp('>>>Starting feature extraction...');
if strcmp(handles.signalType, 'signalCAR')
    [ppsEEG.data.spikeDetection.(handles.signalType).features1,...
        ppsEEG.data.spikeDetection.(handles.signalType).featureMapping1,~,~]=CreateMonopolarFeatures(handles);
    
elseif strcmp(handles.signalType, 'signalBipolar')
    [ppsEEG.data.spikeDetection.(handles.signalType).features1,...
        ppsEEG.data.spikeDetection.(handles.signalType).featureMapping1,...
        ppsEEG.data.spikeDetection.(handles.signalType).features2,...
        ppsEEG.data.spikeDetection.(handles.signalType).featureMapping2]=CreateMonopolarFeatures(handles);
end

[ppsEEG.data.spikeDetection.(handles.signalType).validationPredictions,...
    ppsEEG.data.spikeDetection.(handles.signalType).validationPredictions_threshold]...
    = RunClassification(handles);

handles.rerunClassButton.Visible = 'on';
handles.mark.Visible = 'on';
handles.undo.Visible = 'on';
handles.buttonReclass.Visible = 'on';
handles.runButton.BackgroundColor = [ 0.8 0.8 0.8];
close(wb) 

% --- Executes on "next" button press
function buttonNext_Callback(hObject, eventdata, handles)
global ppsEEG
numLeads = ppsEEG.preproInfo.leadsInfo.numLeads;
handles.resetValue = false;

if handles.leadOn < numLeads
    %handles = write_checkboxes(handles);
    handles.leadOn = handles.leadOn + 1; 
    show_checkboxes(handles);
    handles = read_checkboxes(handles);
    plot_sEEG(hObject,handles)
    guidata(hObject, handles);
    handles.buttonBack.Enable = 'on';
else 
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
end

handles.probeSelection.Value = handles.leadOn;    
guidata(hObject, handles);


% --- Executes on "back" button press 
function buttonBack_Callback(hObject, eventdata, handles)
handles.resetValue = false;
if handles.leadOn > 1
    %handles = write_checkboxes(handles);
    handles.leadOn = handles.leadOn - 1;
    guidata(hObject, handles);
    show_checkboxes(handles)
    handles = read_checkboxes(handles);
    plot_sEEG(hObject,handles)
    if handles.leadOn == 1
        handles.pushbuttonBack.Enable = 'off';
    end
end

handles.probeSelection.Value = handles.leadOn;
handles.resetValue = false;
guidata(hObject, handles);

function sensitivityText_Callback(hObject, eventdata, handles)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sensitivityText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);

% --- Executes on button press in buttonPlot.
function buttonPlot_Callback(hObject, eventdata, handles)
%handles.resetValue = true;
plot_sEEG(hObject,handles)

% --- Plot multiple values ---
function plot_sEEG(hObject,handles)
global ppsEEG

if ~iscell(handles.probeSelection.String)
    leadName=cell(length(ppsEEG.preproInfo.leadsInfo.channelNames),1);
    for n = 1:length(ppsEEG.preproInfo.leadsInfo.channelNames)
        leadName{n} = char(ppsEEG.preproInfo.leadsInfo.channelNames{n}(1));
        leadName{n} = leadName{n}(1:end-1);
    end
    handles.probeSelection.String = leadName;
    handles.probeSelection.Value =1;
end


axes(handles.axesSignal);
cla(handles.axesSignal)
handles.axesSignal.Units = 'centimeters';
position = handles.axesSignal.Position;

if position(3)>30
    handles.axesSignal.Position = [position(1) position(2) 30 position(4)];
end
handles.axesSignal.ActivePositionProperty = 'position';

hold on
handles = write_checkboxes(handles);

sensitivity = str2double(get(handles.sensitivityText,'String'));
leadName = char(ppsEEG.preproInfo.leadsInfo.channelNames{handles.leadOn}(1));
leadName = leadName(1:end-1);
fs = ppsEEG.preproInfo.samplingRate;

if strcmp(handles.signalType,'signalBipolar')
    numContacts = length(ppsEEG.preproInfo.bipolarInfo.channelNames{handles.leadOn});
    data = ppsEEG.data.signals.(handles.signalType){handles.leadOn};
    handles.leadLength = cellfun(@(x) size(x,2), ppsEEG.preproInfo.bipolarInfo.channelNames);
    reject = ppsEEG.preproInfo.bipolarInfo.rejected{handles.leadOn};   
     
elseif strcmp(handles.signalType,'signalCAR')
    chIdx = 0;
    if handles.leadOn > 1
        len = cellfun('length',ppsEEG.preproInfo.leadsInfo.channelNames);
        chIdx = sum(len(1:handles.leadOn-1));
    end
    numContacts = length(ppsEEG.preproInfo.leadsInfo.channelNames{1,handles.leadOn});  
    data = ppsEEG.data.signals.(handles.signalType)(:,chIdx+1:chIdx+numContacts);
    handles.leadLength = cellfun('length',ppsEEG.preproInfo.leadsInfo.channelNames);
    reject = ppsEEG.preproInfo.leadsInfo.rejected{1,handles.leadOn}; 
end

handles.numContacts = numContacts;
%chVector = chIdx+1:chIdx+numContacts;

if all(reject==1)
    stdY = mean(std(data));
    midY = mean(mean(data));
else
    stdY = mean(std(data(:,reject==0)));
    midY = mean(mean(data(:,reject==0)));
end
maxYax =  midY + handles.ampSpam*stdY;
minYax = midY - handles.ampSpam*stdY;
deltaYax = maxYax - minYax;
data = (sensitivity).*(data/deltaYax);
data = flip(data,2);
[NSamples,~] = size(data);
xAxis = (0:NSamples-1)./fs; 
xAxis = repmat(xAxis',1,numContacts);
idxMin = 1650 - (numContacts)*100;
offset = repmat(idxMin:100:1600,NSamples,1);
handles.offset = offset;

for i=1:16
    SpikeCountObj = findobj('Tag',sprintf('SpikeCount%d',i));
    SpikeCountObj(1).String = num2str(0);
    SpikeCountObj(1).Visible = 'off';
    
end

%disable display of certain signals
handles.axesSignal.ColorOrderIndex = 1;
plot(xAxis,data+offset)
plots = handles.axesSignal.Children;
for i =1:length(handles.rejected)
    if handles.rejected(i) == 1
        plots(i).Color(4)=0.25;
    elseif handles.rejected(i) == 0
        plots(i).Color(4)=1;
    end
end

if isfield(ppsEEG.data, 'spikeDetection')
    chIdx = 0;
    if handles.leadOn > 1
        chIdx = sum(handles.leadLength(1:handles.leadOn-1));
    end 
    handles.chIdx = chIdx;
    handles.numContacts = numContacts;
    guidata(hObject, handles);
    
    if isfield(ppsEEG.data.spikeDetection, char(handles.signalType))
        %markerAll=ppsEEG.data.spikeDetection.(handles.signalType).markerAll(chIdx+1:chIdx+numContacts);
        markerAll=ppsEEG.data.spikeDetection.(handles.signalType).markerLead(chIdx+1:chIdx+numContacts);
        eventClassAll=ppsEEG.data.spikeDetection.(handles.signalType).classAll(chIdx+1:chIdx+numContacts);
        if isfield(ppsEEG.data.spikeDetection.(handles.signalType),'markerManual')
            manual = ppsEEG.data.spikeDetection.(handles.signalType).markerManual(chIdx+1:chIdx+numContacts);
        else
            manual = cell(size(markerAll));
        end
        
        handles.SpikeCountText.Visible = 'on';
        for i=1:size(markerAll,2)
            [indMarkerAll{i}]= markerAll{i};
            %[indMarkerLead{i}]= markerLead{i};
            [indManual{i}] = manual{i}; 
            [classAll{i}]= eventClassAll{i};
            
            SpikeCountObj = findobj('Tag',sprintf('SpikeCount%d',i));

            if ~isempty(classAll{i})
                SpikeCountObj(1).String = num2str(sum(classAll{i}==2));
            end
            SpikeCountObj(1).Visible = 'on';
        end
        %indMarkerLead = flip(indMarkerLead);
        indMarkerAll = flip(indMarkerAll);
        indManual = flip(indManual);
        classAll = flip(classAll);
        
    else
        %indMarkerLead = cell(size(data,2));
        indMarkerAll = cell(size(data,2));
        indManual = cell(size(data,2));
        classAll = cell(size(data,2));
    end    
             
    handles.axesSignal.ColorOrderIndex = 1;
    hold on
    for i=1:size(data,2)
        if ~isempty(indMarkerAll{i}) 
            y = zeros(size(indMarkerAll{i}));
            y(:)=offset(1,i);
            f = [1 2 3 4];
            for j = 1:length(indMarkerAll{i})
                v = [(indMarkerAll{i}(j)-.2) y(j)-50;(indMarkerAll{i}(j)-.2) y(j)+50; (indMarkerAll{i}(j)+.2) y(j)+50; (indMarkerAll{i}(j)+.2) y(j)-50];
                handles.axesSignal.ColorOrderIndex = i;
                if classAll{i}(j) == 1
                    %patches{i}(j) = 
                    patch('Faces', f,'Vertices',v,'FaceColor','r','FaceAlpha',.1,'EdgeColor','none');
                elseif classAll{i}(j) == 2
                    patch('Faces', f,'Vertices',v,'FaceColor','g','FaceAlpha',.1,'EdgeColor','none');
                elseif classAll{i}(j) == 3
                    patch('Faces', f,'Vertices',v,'FaceColor','b','FaceAlpha',.1,'EdgeColor','none');
                else
                    patch('Faces', f,'Vertices',v,'FaceAlpha',.1,'EdgeColor','none');
                end
                %plot([indMarkerAll{i}(j) indMarkerAll{i}(j)], [0 1700],'LineWidth',1,'LineStyle',':')
            end
        end
        
        if ~isempty(indManual{i})
            if size(indManual{i},2)==1
                indManual{i}= indManual{i}';
            end
            y = zeros(size(indManual{i},1));
            y(:)=offset(1,i);
            f = [1 2 3 4];
            for j = 1:size(indManual{i},1)
                v = [(indManual{i}(j,1)) y(j)-50;(indManual{i}(j,1)) y(j)+50; (indManual{i}(j,2)) y(j)+50; (indManual{i}(j,2)) y(j)-50];
                handles.axesSignal.ColorOrderIndex = i;
                patch('Faces', f,'Vertices',v,'FaceAlpha',.2,'EdgeColor','none');
            end
        end       
        
    end
end


if handles.resetValue == true
    if handles.timebase == 60
        xlim([0 5])
    elseif handles.timebase == 30
        xlim([0 10])
    elseif handles.timebase == 15    
        xlim([0 20])
    end
    ylim([0 1650])
    handles.resetValue = false;
end


set(gca,'YTickLabel',[])
ylabel(sprintf('Amplitude [%d uV/div]',round(deltaYax/2)))
xlabel('Time (sec)')
numLeads = ppsEEG.preproInfo.leadsInfo.numLeads;
if strcmp(handles.signalType,'signalBipolar')
    title(sprintf('Lead %s, [%d/%d], %d bipolar combinations',leadName,handles.leadOn,numLeads,numContacts))
elseif strcmp(handles.signalType,'signalCAR')
    title(sprintf('Lead %s [%d/%d], %d contacts',leadName,handles.leadOn,numLeads,numContacts))
end

grid on
grid minor
pan xon
guidata(hObject, handles)


% --------------------------------------------------------------------
function uitoggletoolZoom_ClickedCallback(hObject, eventdata, handles)
zoom xon

% --------------------------------------------------------------------
function uitoggletoolPan_ClickedCallback(hObject, eventdata, handles)
pan xon


% --- Executes on button press in PanRight.
function PanRight_Callback(hObject, eventdata, handles)
axes(handles.axesSignal);
global ppsEEG
fs = ppsEEG.preproInfo.samplingRate;
panPercent = str2double(get(handles.panText,'String'));
maxX = size(ppsEEG.data.signals.signalCAR,1)/fs;
axes(handles.axesSignal);
xl = xlim;

delta = diff(xl)-diff(xl)*(1-panPercent/100);
if xl(2)+delta > maxX
    xlim([(maxX-diff(xl)) maxX])
else
    xlim([xl(1)+delta xl(2)+delta])
end

% --- Executes on button press in PanLeft.
function PanLeft_Callback(hObject, eventdata, handles)
axes(handles.axesSignal);
xl = xlim;
panPercent = str2double(get(handles.panText,'String'));
delta = diff(xl)-diff(xl)*(1-panPercent/100);
if xl(1)-delta < 0 
    xlim([0 delta])
else
    xlim([xl(1)-delta xl(2)-delta])
end

% --- Executes on selection change in signalType.
function signalType_Callback(hObject, eventdata, handles)
global ppsEEG
switch get(hObject,'Value')
    case 1
        handles.signalType = 'signalCAR';
        handles.leadLengths = cellfun('length',ppsEEG.preproInfo.leadsInfo.channelNames);       
    case 2
        handles.signalType = 'signalBipolar';
        if ~isfield(ppsEEG.data.signals,'signalBipolar')
            GenerateBipolar
        end
        handles.leadLengths = cellfun(@(x) size(x,2),ppsEEG.data.signals.signalBipolar);
end
handles.resetValue = false;
guidata(hObject, handles)
plot_sEEG(hObject,handles)
show_checkboxes(handles)

% --- Executes during object creation, after setting all properties.
function signalType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global ppsEEG
if strcmp(ppsEEG.preproInfo.RefMethod, 'CAR')
    hObject.Value=1;
elseif strcmp(ppsEEG.preproInfo.RefMethod, 'Bipolar')
    hObject.Value=2;
end

% --- Executes on selection change in ampSpan.
function ampSpan_Callback(hObject, eventdata, handles)
switch get(hObject,'Value')
    case 1
        handles.ampSpam = 30;
    case 2
        handles.ampSpam = 20;
    case 3
        handles.ampSpam = 10;
    case 4 
        handles.ampSpam = 5;
end
handles.resetValue = false;
plot_sEEG(hObject,handles)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ampSpan_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
hObject.Value=3;


% --- Executes on button press in mark.
function mark_Callback(hObject, eventdata, handles)
global ppsEEG

handles.resetValue = false;
if handles.leadOn ==1
    chInd = 0;
else
    chInd = sum(handles.leadLength(1:handles.leadOn-1));
end
numContacts = handles.leadLength(1,handles.leadOn);

[SpikeTimes,~] = ginput(2);
SpikeTimes = sort(SpikeTimes);
setappdata(0,'Times',SpikeTimes);
setappdata(0,'CurrChannel',1);
setappdata(0,'NumContacts',numContacts);

uiwait(Annotations)
handles.selectedChannels = getappdata(0,'selectedChannels');
spikeClass = getappdata(0,'spikeClass');
Idx = find(handles.selectedChannels);
SpikeTimes = SpikeTimes';

if ~isfield(ppsEEG.data.spikeDetection.(handles.signalType), 'markerManual')
    ppsEEG.data.spikeDetection.(handles.signalType).markerManual = cell(size(ppsEEG.data.spikeDetection.(handles.signalType).markerLead));
    ppsEEG.data.spikeDetection.(handles.signalType).classManual = cell(size(ppsEEG.data.spikeDetection.(handles.signalType).markerLead));
end
for i = 1:length(Idx)
    if isempty(ppsEEG.data.spikeDetection.(handles.signalType).markerManual{Idx(i)+chInd})
        ppsEEG.data.spikeDetection.(handles.signalType).markerManual{Idx(i)+chInd}(1,:) = SpikeTimes;
        ppsEEG.data.spikeDetection.(handles.signalType).classManual{Idx(i)+chInd}(1,1) = spikeClass;
    else
        ppsEEG.data.spikeDetection.(handles.signalType).markerManual{Idx(i)+chInd}(end+1,:) = SpikeTimes;
        ppsEEG.data.spikeDetection.(handles.signalType).classManual{Idx(i)+chInd}(end+1,:) = spikeClass;
    end
end
guidata(hObject,handles)
plot_sEEG(hObject,handles)


% --- Executes on button press in undo.
function undo_Callback(hObject, eventdata, handles)
global ppsEEG

handles.resetValue = false;
[SpikeTimes,~] = ginput(2);
SpikeTimes = sort(SpikeTimes);
numContacts = handles.leadLength(1,handles.leadOn);
setappdata(0,'Times',SpikeTimes);
setappdata(0,'CurrChannel',1);
setappdata(0,'NumContacts',numContacts);

uiwait(Annotations)
handles.selectedChannels = getappdata(0,'selectedChannels');
Idx = find(handles.selectedChannels);
if handles.leadOn ==1
    chInd = 0;
else
    chInd = sum(handles.leadLength(1:handles.leadOn-1));
end

chInd = chInd + Idx;

for i = 1:length(Idx)
    % marker
    if isfield(ppsEEG.data.spikeDetection.(handles.signalType),'markerLead')
        if ~isempty(ppsEEG.data.spikeDetection.(handles.signalType).markerLead{1,chInd(i)})    
            indMarker = ppsEEG.data.spikeDetection.(handles.signalType).markerLead;
            indRemove = intersect(find(indMarker{1,chInd(i)}(:,1)>SpikeTimes(1)),...
                find(indMarker{1,chInd(i)}(:,end)<SpikeTimes(2)));
            if ~isempty(indRemove)
                ppsEEG.data.spikeDetection.(handles.signalType).markerLead{1,chInd(i)}(indRemove,:)=[];
                ppsEEG.data.spikeDetection.(handles.signalType).classAll{1,chInd(i)}(indRemove,:)=[];
            end
        end
    end    
    % manual marker
    if isfield(ppsEEG.data.spikeDetection.(handles.signalType),'markerManual')
        if ~isempty(ppsEEG.data.spikeDetection.(handles.signalType).markerManual{1,chInd(i)})
            indMarker = ppsEEG.data.spikeDetection.(handles.signalType).markerManual;
            indRemove = intersect(find(indMarker{1,chInd(i)}(:,1)>SpikeTimes(1)),...
                find(indMarker{1,chInd(i)}(:,end)<SpikeTimes(2)));
            if ~isempty(indRemove)
                ppsEEG.data.spikeDetection.(handles.signalType).markerManual{1,chInd(i)}(indRemove,:)=[];
                ppsEEG.data.spikeDetection.(handles.signalType).classManual{1,chInd(i)}(indRemove,1)=[];
            end
        end
    end 
end

plot_sEEG(hObject,handles)
guidata(hObject,handles)


% ---
function show_checkboxes(handles)
global ppsEEG
numContacts = handles.leadLengths(1,handles.leadOn);

for i=1:16
    chkObj = findobj('Tag',sprintf('chk%d',i));
    if i > numContacts
        chkObj.Visible = 'off';
    else
        chkObj.Visible = 'on';
    end
end

% ---
function handles = read_checkboxes(handles)
global ppsEEG
if strcmp(handles.signalType,'signalBipolar')
    handles.rejected = ppsEEG.preproInfo.bipolarInfo.rejected{handles.leadOn};
    for i=1:length(handles.rejected)
        chkObj = findobj('Tag',sprintf('chk%d',i));
        chkObj.Value = handles.rejected(i);
    end
elseif strcmp(handles.signalType,'signalCAR')
    chIdx = 0;
    if handles.leadOn > 1
        len = cellfun('length',ppsEEG.preproInfo.leadsInfo.channelNames);
        chIdx = sum(len(1:handles.leadOn-1));
    end
    numContacts = length(ppsEEG.preproInfo.leadsInfo.channelNames{1,handles.leadOn});
    handles.rejected = ppsEEG.preproInfo.leadsInfo.rejected{1,handles.leadOn};
    
    for i=1:length(handles.rejected)
        chkObj = findobj('Tag',sprintf('chk%d',i));
        chkObj.Value = handles.rejected(i);
    end
end


% ---
function handles = write_checkboxes(handles)
global ppsEEG    
if strcmp(handles.signalType,'signalBipolar')
    handles.rejected = ppsEEG.preproInfo.bipolarInfo.rejected{handles.leadOn};
    for i=1:length(handles.rejected)
        chkObj = findobj('Tag',sprintf('chk%d',i));
        handles.rejected(i) = chkObj.Value;
    end
    ppsEEG.preproInfo.bipolarInfo.rejected{handles.leadOn}=handles.rejected;
elseif strcmp(handles.signalType,'signalCAR')
    chIdx = 0;
    if handles.leadOn > 1
        len = cellfun('length',ppsEEG.preproInfo.leadsInfo.channelNames);
        chIdx = sum(len(1:handles.leadOn-1));
    end
    numContacts = length(ppsEEG.preproInfo.leadsInfo.channelNames{1,handles.leadOn});
    handles.rejected = ppsEEG.preproInfo.leadsInfo.rejected{handles.leadOn};
    for i=1:length(handles.rejected)
        chkObj = findobj('Tag',sprintf('chk%d',i));
        handles.rejected(i) = chkObj.Value;
    end
    ppsEEG.preproInfo.leadsInfo.rejected{handles.leadOn}=handles.rejected;
end


% --- Executes on button press in chkVal1.
function chkVal_Callback(hObject, eventdata, handles)
global ppsEEG
for i=1:length(handles.rejected)
    chkObj = findobj('Tag',sprintf('chk%d',i));
    handles.rejected(i) = chkObj.Value;
end

%disable display of certain signals
axes(handles.axesSignal);
handles.axesSignal.ColorOrderIndex = 1;

numContacts = handles.numContacts;
numChildren = length(handles.axesSignal.Children);

plotIdx = (numChildren - numContacts+1:numChildren);

for i =1:length(handles.rejected)
    if handles.rejected(i) == 1
        handles.axesSignal.Children(plotIdx(i)).Color(4)=.25;
        ppsEEG.preproInfo.bipolarInfo.rejected{1,handles.leadOn}(i)=1;
    elseif handles.rejected(i) == 0
        handles.axesSignal.Children(plotIdx(i)).Color(4)=1;
        ppsEEG.preproInfo.bipolarInfo.rejected{1,handles.leadOn}(i)=0;
    end
end



function probArtifact_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function probArtifact_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function probPathology_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function probPathology_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function probPhysiology_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function probPhysiology_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in resetTimeButton.
function resetTimeButton_Callback(hObject, eventdata, handles)
axes(handles.axesSignal);
handles.resetValue = true;
if handles.resetValue == true
    if handles.timebase == 60
        xlim([0 5])
    elseif handles.timebase == 30
        xlim([0 10])
    elseif handles.timebase == 15    
        xlim([0 20])
    end
    ylim([0 1650])
    handles.resetValue = false;
end
guidata(hObject,handles);


% --- Executes on button press in buttonReclass.
function buttonReclass_Callback(hObject, eventdata, handles)
global ppsEEG
%user input
[EventX,EventY] = ginput();% ginput(1);
%offset position of channel data
offset = flip(handles.offset(1,:));

chIdx = zeros(length(EventY),1);
for i = 1:length(EventY)
    [~,chIdx(i)]=min(abs(offset-EventY(i)));
end

%classify event 
uiwait(AddClassification)
eventClass = getappdata(1,'eventClass');
handles.saved = 'false';

if handles.leadOn > 1
    if strcmp(handles.signalType,'signalBipolar')
        len = cellfun(@(x) size(x,2),ppsEEG.preproInfo.bipolarInfo.channelNames);
    else
        len = cellfun(@(x) size(x,2),ppsEEG.preproInfo.leadsInfo.channelNames);
    end
    chIdx_total = sum(len(1:handles.leadOn-1));
else
    chIdx_total=0;
end

chIdx_total = chIdx + chIdx_total;

for i = 1:length(chIdx)
    % All channels marker
    %[val,idx]= min(abs(ppsEEG.data.spikeDetection.signalBipolar.markerAll{1,chIdx_total(i)}-EventX(i)));
    [val,idx]= min(abs(ppsEEG.data.spikeDetection.(handles.signalType).markerLead{1,chIdx_total(i)}-EventX(i)));
    if val < 0.5
        ppsEEG.data.spikeDetection.(handles.signalType).classAll{1,chIdx_total(i)}(idx)= eventClass(1);
    end
    % Manually added markers
    if isfield(ppsEEG.data.spikeDetection.(handles.signalType),'markerManual')
        [val,idx]= min(abs(ppsEEG.data.spikeDetection.(handles.signalType).markerManual{1,chIdx_total(i)}-EventX(i)));
        if val < 0.5
            ppsEEG.data.spikeDetection.(handles.signalType).classManual{1,chIdx_total(i)}(idx,1)= eventClass(1);
        end
    end
end

axes(handles.axesSignal);
hold on
offset =flip(handles.offset(1,:));

for ch=1:size(chIdx,1)
    %indMarkerAll = ppsEEG.data.spikeDetection.signalBipolar.markerAll{chIdx_total(ch)};
    indMarkerAll = ppsEEG.data.spikeDetection.(handles.signalType).markerLead{chIdx_total(ch)};
    [~,idx] = min(abs(indMarkerAll-EventX(ch)));
    y=offset(1,chIdx(ch));
    f = [1 2 3 4];
    v = [(indMarkerAll(idx)-.3) y-50;...
        (indMarkerAll(idx)-.3) y+50;...
        (indMarkerAll(idx)+.3) y+50;...
        (indMarkerAll(idx)+.3) y-50];
    if eventClass == 1
        patch('Faces', f,'Vertices',v,'FaceColor','r','FaceAlpha',.1,'EdgeColor','none');
    elseif eventClass== 2
        patch('Faces', f,'Vertices',v,'FaceColor','g','FaceAlpha',.1,'EdgeColor','none');
    elseif eventClass== 3
        patch('Faces', f,'Vertices',v,'FaceColor','b','FaceAlpha',.1,'EdgeColor','none');
    else
        patch('Faces', f,'Vertices',v,'FaceAlpha',.1,'EdgeColor','none');
    end
end

guidata(hObject,handles)



% --- Executes on selection change in probeSelection.
function probeSelection_Callback(hObject, eventdata, handles)
global ppsEEG
handles.resetValue = false;
handles.leadOn = get(hObject,'Value');

% guidata(hObject, handles);
% plot_sEEG(hObject,handles)
% %chkVal_updateaxes(handles)

%handles = write_checkboxes(handles);
show_checkboxes(handles);
handles = read_checkboxes(handles);
plot_sEEG(hObject,handles)

if handles.leadOn == 1
    handles.buttonBack.Enable = 'off';
    handles.nextBack.Enable = 'on';
elseif handles.leadOn == ppsEEG.preproInfo.leadsInfo.numLeads 
    handles.nextBack.Enable = 'off';
    handles.buttonBack.Enable = 'on';
else
    handles.nextBack.Enable = 'on';
    handles.buttonBack.Enable = 'on';
end

handles.probeSelection.Value = handles.leadOn;    
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function probeSelection_CreateFcn(hObject, eventdata, handles)
global ppsEEG
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);

function panText_Callback(hObject, eventdata, handles)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function panText_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);

% --- Executes on selection change in timebaseDropDown.
function timebaseDropDown_Callback(hObject, eventdata, handles)
idx = get(hObject,'Value');

if idx ==1
    handles.timebase = 60;
elseif idx == 2
    handles.timebase = 30;
elseif idx == 3
    handles.timebase = 15;
end

axes(handles.axesSignal);
x = xlim;
xlim([x(1) x(1)+300/handles.timebase])

guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function timebaseDropDown_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [features1,featureMapping1,features2,featureMapping2]=CreateMonopolarFeatures(handles)
global ppsEEG
features1 =[];featureMapping1=[];
features2=[];featureMapping2=[];
% Load in filtered monopolar data
n=0; leadNum=[]; leadNumAll=[]; 

% Initiate for CAR by leads
if strcmp(handles.signalType, 'signalCAR')
    rejected = [ppsEEG.preproInfo.leadsInfo.rejected{1,1:length(ppsEEG.preproInfo.leadsInfo.rejected)}];
    [features1,featureMapping1]=ExtractFeaturesSpikeDetection_reduced(...
        ppsEEG.data.signals.signalCAR,...
        rejected,...
        ppsEEG.data.spikeDetection.(handles.signalType).markerLead,...
        ppsEEG.preproInfo.leadsInfo.labelRFC,...
        ppsEEG.preproInfo.samplingRate,...
        ppsEEG.preproInfo.leadsInfo.sozChannel,...
        ppsEEG.preproInfo.lineNoise);
    
%     monopolarContact1 = ppsEEG.data.signals.signalCAR(:,rejected==0);
%     sozContact1 = ppsEEG.preproInfo.leadsInfo.sozChannel(rejected==0);
%     anatContact1 = ppsEEG.preproInfo.leadsInfo.labelRFC  (rejected==0);
%     [features1,featureMapping1]=ExtractFeaturesSpikeDetection_reduced(monopolarContact1,rejected,...
%         ppsEEG.data.spikeDetection.(handles.signalType).markerLead,anatContact1,...
%         ppsEEG.preproInfo.samplingRate,sozContact1,ppsEEG.preproInfo.lineNoise);
    
elseif strcmp(handles.signalType, 'signalBipolar')
    %rejected = [ppsEEG.preproInfo.bipolarInfo.rejected{1,1:length(ppsEEG.preproInfo.bipolarInfo.rejected)}];
    rejectedMonopolar = [ppsEEG.preproInfo.leadsInfo.rejected{1,1:length(ppsEEG.preproInfo.leadsInfo.rejected)}];
    monopolarContact1=zeros(size(ppsEEG.data.signals.signalCAR));
    sozContact1=zeros(1,size(ppsEEG.data.signals.signalCAR,2));
    anatContact1=zeros(1,size(ppsEEG.data.signals.signalCAR,2));
    monopolarContact2=zeros(size(ppsEEG.data.signals.signalCAR));
    sozContact2=zeros(1,size(ppsEEG.data.signals.signalCAR,2));
    anatContact2=zeros(1,size(ppsEEG.data.signals.signalCAR,2));
    rejected1=zeros(1,size(rejectedMonopolar,2));
    rejected2=zeros(1,size(rejectedMonopolar,2));

    for lead = 1:length(ppsEEG.preproInfo.leadsInfo.channelNames)
        temp = zeros(1,length(ppsEEG.preproInfo.leadsInfo.channelNames{1,lead})); 
        temp(:)=lead;
        leadNum = [leadNum,temp]; 
        chanVect = find(leadNum==lead); 
        temp = zeros(1,length(ppsEEG.preproInfo.leadsInfo.channelNames{1,lead})); 
        temp(:)=lead;
        leadNumAll = [leadNumAll,temp];
        chanVectAll = find(leadNumAll==lead);

        % Loop through channels within a lead (minus one) 
        for ch = 1:length(ppsEEG.preproInfo.leadsInfo.channelNames{1,lead})-1
            if ppsEEG.preproInfo.leadsInfo.rejected{1,lead}(1,ch) ==0 && ppsEEG.preproInfo.leadsInfo.rejected{1,lead}(1,ch+1) ==0
                n=n+1;
                monopolarContact1(:,n) = ppsEEG.data.signals.signalCAR(:,chanVect(ch));
                monopolarContact2(:,n) = ppsEEG.data.signals.signalCAR(:,chanVect(ch+1));
                sozContact1(:,n) = ppsEEG.preproInfo.leadsInfo.sozChannel(chanVectAll(ch));
                anatContact1(:,n) = ppsEEG.preproInfo.leadsInfo.labelRFC(chanVectAll(ch));
                rejected1(:,n) = rejectedMonopolar(chanVectAll(ch+1));
                sozContact2(:,n) = ppsEEG.preproInfo.leadsInfo.sozChannel(chanVectAll(ch+1));
                anatContact2(:,n) = ppsEEG.preproInfo.leadsInfo.labelRFC(chanVectAll(ch+1));
                rejected2(:,n) = rejectedMonopolar(chanVectAll(ch+1));
            end
        end
    end

    monopolarContact1 = monopolarContact1(:,1:n); %monopolarContact1(:,rejected==1)=[];
    monopolarContact2 = monopolarContact2(:,1:n); %monopolarContact2(:,rejected==1)=[];
    sozContact1=sozContact1(1:n); %sozContact1(rejected==1)=[];
    anatContact1=anatContact1(1:n); %anatContact1(rejected==1)=[];
    sozContact2=sozContact2(1:n); %sozContact2(rejected==1)=[];
    anatContact2=anatContact2(1:n); %anatContact2(rejected==1)=[];
    rejected1 = rejected1(1,1:n);
    rejected2 = rejected2(1,1:n);

    [features1,featureMapping1]=ExtractFeaturesSpikeDetection_reduced(monopolarContact1,rejected1,...
        ppsEEG.data.spikeDetection.(handles.signalType).markerLead,anatContact1,...
        ppsEEG.preproInfo.samplingRate,sozContact1,ppsEEG.preproInfo.lineNoise);

    [features2,featureMapping2]=ExtractFeaturesSpikeDetection_reduced(monopolarContact2,rejected2,...
        ppsEEG.data.spikeDetection.(handles.signalType).markerLead,anatContact2,...
        ppsEEG.preproInfo.samplingRate,sozContact2,ppsEEG.preproInfo.lineNoise);
end

function [validationPredictions,validationPredictions_threshold] = RunClassification(handles)
global ppsEEG

disp('>>>Loading Classifier...');
load('compactModel.mat')
disp('>>>Classifying detected events...');


% RF Classifier 
ensemblePredictFcn = @(x) predict(rf_Optimization_compact,x);
validationPredictFcn = @(x) ensemblePredictFcn(x);

% Adjust scores based on new prior probability
Prior1_old = rf_Optimization_compact.Prior(1);
Prior1_new = str2double(handles.probArtifact.String);
Prior2_old = rf_Optimization_compact.Prior(2);
Prior2_new = str2double(handles.probPathology.String);
Prior3_old = rf_Optimization_compact.Prior(3);
Prior3_new = str2double(handles.probPhysiology.String);

ppsEEG.preproInfo.spikeDetection.probArtifact = Prior1_new;
ppsEEG.preproInfo.spikeDetection.probPathology = Prior2_new;
ppsEEG.preproInfo.spikeDetection.probPhysiology = Prior3_new;

validationPredictors1 = ppsEEG.data.spikeDetection.(handles.signalType).features1(:,rf_Optimization_compact.PredictorNames);
[~, featureScores1] = validationPredictFcn(validationPredictors1);

Scores1(:,1) = (Prior1_new/Prior1_old).*(featureScores1(:,1))./...
    ((Prior1_new/Prior1_old)*featureScores1(:,1)+...
    (Prior2_new/Prior2_old)*featureScores1(:,2)+...
    (Prior3_new/Prior3_old)*featureScores1(:,3));

Scores1(:,2)= (Prior2_new/Prior2_old).*(featureScores1(:,2))./...
    ((Prior1_new/Prior1_old)*featureScores1(:,1)+...
    (Prior2_new/Prior2_old)*featureScores1(:,2)+...
    (Prior3_new/Prior3_old)*featureScores1(:,3));

Scores1(:,3) = (Prior3_new/Prior3_old).*(featureScores1(:,3))./...
    ((Prior1_new/Prior1_old)*featureScores1(:,1)+...
    (Prior2_new/Prior2_old)*featureScores1(:,2)+...
    (Prior3_new/Prior3_old)*featureScores1(:,3));

validationPredictions = zeros(size(featureScores1,1),1);
for j = 1:size(validationPredictions,1)
    if Scores1(j,2)>= 0.42
        validationPredictions(j,1) = 2;
    elseif Scores1(j,1)>= 0.75
        validationPredictions(j,1) = 1;
    elseif Scores1(j,3)>= 0.49
        validationPredictions(j,1) = 3;
    else
        [~,temp1]=max(Scores1(j,:));
        
        if temp1 == 2
            validationPredictions(j,1) = 2;
        elseif temp1 == 1
            validationPredictions(j,1) = 1;
        else
            validationPredictions(j,1) = 3;
        end
    end
end

ppsEEG.data.spikeDetection.signalBipolar.scores1 = Scores1;

if strcmp(handles.signalType, 'signalBipolar')
    validationPredictors2 = ppsEEG.data.spikeDetection.(handles.signalType).features2(:,rf_Optimization_compact.PredictorNames);
    [~, featureScores2] = validationPredictFcn(validationPredictors2);

    Scores2(:,1) = (Prior1_new/Prior1_old).*(featureScores2(:,1))./...
        ((Prior1_new/Prior1_old)*featureScores2(:,1)+...
        (Prior2_new/Prior2_old)*featureScores2(:,2)+...
        (Prior3_new/Prior3_old)*featureScores2(:,3));
    
    Scores2(:,2)= (Prior2_new/Prior2_old).*(featureScores2(:,2))./...
        ((Prior1_new/Prior1_old)*featureScores2(:,1)+...
        (Prior2_new/Prior2_old)*featureScores2(:,2)+...
        (Prior3_new/Prior3_old)*featureScores2(:,3));
    
    Scores2(:,3) = (Prior3_new/Prior3_old).*(featureScores2(:,3))./...
        ((Prior1_new/Prior1_old)*featureScores2(:,1)+...
        (Prior2_new/Prior2_old)*featureScores2(:,2)+...
        (Prior3_new/Prior3_old)*featureScores2(:,3));
    
    validationPredictions = zeros(size(featureScores2,1),1);
    for j = 1:size(validationPredictions,1)
        if Scores1(j,2)>= 0.42|| Scores2(j,2)>= 0.42
            validationPredictions(j,1) = 2;
        elseif Scores1(j,1)>= 0.75|| Scores2(j,1)>= 0.75
            validationPredictions(j,1) = 1;
        elseif Scores1(j,3)>= 0.49 || Scores2(j,3)>= 0.49
            validationPredictions(j,1) = 3;
        else
            [~,temp1]=max(Scores1(j,:));
            [~,temp2]=max(Scores2(j,:));
            
            if temp1 == 2 || temp2 ==2
                validationPredictions(j,1) = 2;
            elseif temp1 == 1 || temp2 ==1
                validationPredictions(j,1) = 1;
            else
                validationPredictions(j,1) = 3;
            end
        end
    end   
    ppsEEG.data.spikeDetection.(handles.signalType).scores2 = Scores2;
end

% True labels and concurrent marks
allEventConcurrentIdx=cell(size(featureScores1,1),1);
allEventConcurrentCh=cell(size(featureScores1,1),1);
allEventConcurrentClass=cell(size(featureScores1,1),1);
for event = 1:length(allEventConcurrentIdx)
    % find concurrent events
    idx = find(abs(ppsEEG.data.spikeDetection.(handles.signalType).featureMapping1.MarkerIdx(event)-...
        ppsEEG.data.spikeDetection.(handles.signalType).featureMapping1.MarkerIdx)<0.1);
    % remove event of interest
    idx(idx==event)=[];
    % indices of all concurrent events
    allEventConcurrentIdx{event,1} = ppsEEG.data.spikeDetection.(handles.signalType).featureMapping1.MarkerIdx(idx);
    % channels of concurrent events
    allEventConcurrentCh{event,1} = ppsEEG.data.spikeDetection.(handles.signalType).featureMapping1.channel(idx);
    % event classification of concurrent events
    allEventConcurrentClass{event,1} = validationPredictions(idx);
end

% If any mark within 300ms is pathology --> all concurrent events are pathology
validationPredictions_threshold=validationPredictions;
for event = 1:length(validationPredictions)
    % check if 50% OR MORE of concurrent events were marked as pathology
    if ~isempty(allEventConcurrentIdx{event}) && sum(allEventConcurrentClass{event}==2)/length(allEventConcurrentClass{event})>=0.5
        % if so, change event to pathology
        validationPredictions_threshold(event)=2;
    end
end

for ch = 1:length(ppsEEG.data.spikeDetection.(handles.signalType).markerLead)
    ppsEEG.data.spikeDetection.(handles.signalType).classAll{1,ch}=...
        validationPredictions_threshold(ppsEEG.data.spikeDetection.(handles.signalType).featureMapping1.channel ==ch);
end

% --- Executes on button press in rerunClassButton.
function rerunClassButton_Callback(hObject, eventdata, handles)
global ppsEEG
[ppsEEG.data.spikeDetection.(handles.signalType).validationPredictions,...
    ppsEEG.data.spikeDetection.(handles.signalType).validationPredictions_threshold]...
    = RunClassification(handles);


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
global ppsEEG
wb = waitbar(0,'Backing up data...','windowstyle', 'modal');
wbch = allchild(wb);
wbch(1).JavaPeer.setIndeterminate(1);

if ppsEEG.preproInfo.flags.SaveUnreferenced ==0
    ppsEEG.data.signals = rmfield(ppsEEG.data.signals,'signalComb60Hz');
end

if ppsEEG.preproInfo.flags.SaveReferenced ==0
    if strcmp(ppsEEG.preproInfo.RefMethod, 'CAR')  
        ppsEEG.data.signals = rmfield(ppsEEG.data.signals,'signalCAR');
    elseif strcmp(ppsEEG.preproInfo.RefMethod, 'Bipolar')  
        ppsEEG.data.signals = rmfield(ppsEEG.data.signals,'signalBipolar');
    end
end

if ppsEEG.preproInfo.flags.SpikeDetection ==0
    ppsEEG.data.spikeDetection = rmfield(ppsEEG.data,'spikeDetection');
end
    
ppsFileLog = [ppsEEG.preproInfo.subjectPath '\ppsEEG.mat'];
save(ppsFileLog,'-struct','ppsEEG','-v7.3')
close(wb)

function patchUpdate(hObject,handles)
global ppsEEG

if ~iscell(handles.probeSelection.String)
    leadName=cell(length(ppsEEG.preproInfo.leadsInfo.channelNames),1);
    for n = 1:length(ppsEEG.preproInfo.leadsInfo.channelNames)
        leadName{n} = char(ppsEEG.preproInfo.leadsInfo.channelNames{n}(1));
        leadName{n} = leadName{n}(1:end-1);
    end
    handles.probeSelection.String = leadName;
    handles.probeSelection.Value =1;
end

numContacts = handles.numContacts;
chIdx = handles.chIdx;
offset = handles.offset;

axes(handles.axesSignal);
leadName = char(ppsEEG.preproInfo.leadsInfo.channelNames{handles.leadOn}(1));
leadName = leadName(1:end-1);

if isfield(ppsEEG.data, 'spikeDetection')
    guidata(hObject, handles);
    
    if isfield(ppsEEG.data.spikeDetection, char(handles.signalType))
        %markerAll=ppsEEG.data.spikeDetection.(handles.signalType).markerAll(chIdx+1:chIdx+numContacts);
        markerAll=ppsEEG.data.spikeDetection.(handles.signalType).markerLead(chIdx+1:chIdx+numContacts);
        eventClassAll=ppsEEG.data.spikeDetection.(handles.signalType).classAll(chIdx+1:chIdx+numContacts);
        if isfield(ppsEEG.data.spikeDetection.(handles.signalType),'markerManual')
            manual = ppsEEG.data.spikeDetection.(handles.signalType).markerManual(chIdx+1:chIdx+numContacts);
        else
            manual = cell(size(markerAll));
        end        
        handles.SpikeCountText.Visible = 'on';
        for i=1:size(markerAll,2)
            [indMarkerAll{i}]= markerAll{i};
            [indManual{i}] = manual{i}; 
            [classAll{i}]= eventClassAll{i};
            SpikeCountObj = findobj('Tag',sprintf('SpikeCount%d',i));
            if ~isempty(classAll{i})
                SpikeCountObj(1).String = num2str(sum(classAll{i}==2));
            end
            SpikeCountObj(1).Visible = 'on';
        end
        indMarkerAll = flip(indMarkerAll);
        indManual = flip(indManual);
        classAll = flip(classAll);
        
    else
        indMarkerAll = cell(size(data,2));
        indManual = cell(size(data,2));
        classAll = cell(size(data,2));
    end    
             
    handles.axesSignal.ColorOrderIndex = 1;
    hold on
    for i=1:size(data,2)
        if ~isempty(indMarkerAll{i}) 
            y = zeros(size(indMarkerAll{i}));
            y(:)=offset(1,i);
            f = [1 2 3 4];
            for j = 1:length(indMarkerAll{i})
                v = [(indMarkerAll{i}(j)-.2) y(j)-50;(indMarkerAll{i}(j)-.2) y(j)+50; (indMarkerAll{i}(j)+.2) y(j)+50; (indMarkerAll{i}(j)+.2) y(j)-50];
                handles.axesSignal.ColorOrderIndex = i;
                if classAll{i}(j) == 1
                    %patches{i}(j) = 
                    patch('Faces', f,'Vertices',v,'FaceColor','r','FaceAlpha',.1,'EdgeColor','none');
                elseif classAll{i}(j) == 2
                    patch('Faces', f,'Vertices',v,'FaceColor','g','FaceAlpha',.1,'EdgeColor','none');
                elseif classAll{i}(j) == 3
                    patch('Faces', f,'Vertices',v,'FaceColor','b','FaceAlpha',.1,'EdgeColor','none');
                else
                    patch('Faces', f,'Vertices',v,'FaceAlpha',.1,'EdgeColor','none');
                end
                plot([indMarkerAll{i}(j) indMarkerAll{i}(j)], [0 1700],'LineWidth',1,'LineStyle',':')
            end
        end
        
        if ~isempty(indManual{i})
            if size(indManual{i},2)==1
                indManual{i}= indManual{i}';
            end
            y = zeros(size(indManual{i},1));
            y(:)=offset(1,i);
            f = [1 2 3 4];
            for j = 1:size(indManual{i},1)
                v = [(indManual{i}(j,1)) y(j)-50;(indManual{i}(j,1)) y(j)+50; (indManual{i}(j,2)) y(j)+50; (indManual{i}(j,2)) y(j)-50];
                handles.axesSignal.ColorOrderIndex = i;
                patch('Faces', f,'Vertices',v,'FaceAlpha',.2,'EdgeColor','none');
            end
        end       
        
    end
end

if handles.resetValue == true
    if handles.timebase == 60
        xlim([0 5])
    elseif handles.timebase == 30
        xlim([0 10])
    elseif handles.timebase == 15    
        xlim([0 20])
    end
    ylim([0 1650])
    handles.resetValue = false;
end


set(gca,'YTickLabel',[])
ylabel(sprintf('Amplitude [%d uV/div]',round(deltaYax/2)))
xlabel('Time (sec)')
numLeads = ppsEEG.preproInfo.leadsInfo.numLeads;
if strcmp(handles.signalType,'signalBipolar')
    title(sprintf('Lead %s, [%d/%d], %d bipolar combinations',leadName,handles.leadOn,numLeads,numContacts))
elseif strcmp(handles.signalType,'signalCAR')
    title(sprintf('Lead %s [%d/%d], %d contacts',leadName,handles.leadOn,numLeads,numContacts))
end

grid on
grid minor
pan xon
guidata(hObject, handles)
