function [leadMarkerIdx,leadMarkerType,allChanMarkerIdx,allChanMarkerType,multi]=...
    PotentialEvents(signal,rejected,fs,k,leadLengths,rippleDetection,lineNoise)
%[MarkerIdx,MarkerType,MarkerIdxHF] 

%INPUTS
%   signal(double)..............signal (samples,#channels)
%   rejected(double)............(1,#channels)
%   fs(double)..................sample rate
%   k(double)...................threshold
%   leadLengths(double).........matrix of lead lengths
%   rippleDetection(logic)......true/false
%   lineNoise(double)...........50 or 60 (in Hz)

%OUTPUTS
%   leadMarkerIdx(cell).........index of events using leads{1,#channels}
%   leadMarkerType(cell)........types of detected events {1,#channels}
%   allChanMarkerIdx(cell)......index of events using all channels{1,#channels}
%   allChanMarkerType(cell).....types of detected events {1,#channels}
%   multi.......................events grouped by time across channels

multiSpikeTime=0.300; 
combineSpikeTypesTime = 0.120;
acrossLeadsTime = 0.100;
numChannels = size(signal,2);
sum(leadLengths)

chIdx = zeros(2,length(leadLengths));
for i = 1:length(leadLengths)
    if i ==1
        chIdx(1,i) = 1;
    else
        chIdx(1,i) = sum(leadLengths(1:i-1))+1;
    end
    chIdx(2,i) = sum(leadLengths(1:i));
end

% Initialize 
ind_marker_kurtosis=cell(1,numChannels);
ind_marker=cell(1,numChannels);
ind_marker_15_60=cell(1,numChannels);
ind_marker_ripple=cell(1,numChannels);
ind_marker_fastRipple=cell(1,numChannels);

% Filtering
if lineNoise ==60
    df = Filtering([0.5 59],signal,fs,2,[3,3],'bandpass');
    df_15_60=Filtering([15 59],signal,fs,2,[3,3],'bandpass');
elseif lineNoise ==60
    df = Filtering([0.5 49],signal,fs,2,[3,3],'bandpass');
    df_15_60=Filtering([15 49],signal,fs,2,[3,3],'bandpass');
end
    
if strcmp(rippleDetection, 'true')
    df_ripple=Filtering([80 200],signal,fs,2,[4,4],'bandpass');
    df_fastRipple=Filtering([250 599],signal,fs,2,[4,4],'bandpass');
end

%Signal resampling to 200 Hz 
if fs>200
    df = resample(df,200,fs);
    fs_200 = 200;
end

% Initial event detection
parfor ch=1:numChannels
    if all(signal(:,ch)~=0) && rejected(ch) ==0
        [ind_marker_kurtosis{1,ch},~]...
            =IED_KurtosisDetect(df(:,ch),fs_200);
    end
end

parfor ch=1:numChannels
    if all(signal(:,ch)~=0) && rejected(ch) ==0
        [ind_marker{1,ch}]...
            =SimpleThresholdDetect(signal(:,ch),fs,5,multiSpikeTime,1,'absolute');
    end
end

parfor ch=1:numChannels
    if all(signal(:,ch)~=0) && rejected(ch) ==0
        [ind_marker_15_60{1,ch}]...
            =SimpleThresholdDetect(df_15_60(:,ch),fs,k,multiSpikeTime,1,'hilbert','log');
    end
end
if strcmp(rippleDetection, 'true')
    parfor ch=1:numChannels
        if all(signal(:,ch)~=0) && rejected(ch) ==0
            [ind_marker_ripple{1,ch}]=...
                DetectRMS(df_ripple(:,ch),fs,0.01,0.003,0);
        end
    end
    parfor ch=1:numChannels
        if all(signal(:,ch)~=0) && rejected(ch) ==0
            [ind_marker_fastRipple{1,ch}]=...
                DetectRMS(df_fastRipple(:,ch),fs,0.01,0.003,0);
        end
    end
end

%--------------------------------------------------------------------------
% Finding co-occuring spikes within certain time (across methods)

numChannels= size(signal,2);
MarkerIdx = cell(1,size(signal,2));
MarkerType = cell(1,size(signal,2));
MarkerIdxHF = cell(1,size(signal,2));
for ch=1:numChannels
    spike.pos=[];spike.type=[];  
    if ~isempty(ind_marker{ch})
        ind_temp = ind_marker{ch};
        if ~isempty(ind_temp)
            for i=1:length(ind_temp)
                spike.pos=[spike.pos; ind_temp(i)];
                spike.type=[spike.type; 1];
            end
        end
    end
    if ~isempty(ind_marker_15_60{ch})
        ind_temp = ind_marker_15_60{ch};
        if ~isempty(ind_temp)
            for i=1:length(ind_temp)
                spike.pos=[spike.pos; ind_temp(i)];
                spike.type=[spike.type; 2];
            end
        end
    end
    if ~isempty(ind_marker_ripple{ch})
        ind_temp = mean(ind_marker_ripple{ch},2);
        if ~isempty(ind_temp)
            for i=1:length(ind_temp)
                spike.pos=[spike.pos; ind_temp(i)];
                spike.type=[spike.type; 3];
            end
        end
    end
    if ~isempty(ind_marker_fastRipple{ch})
        ind_temp = mean(ind_marker_fastRipple{ch},2);
        if ~isempty(ind_temp)
            for i=1:length(ind_temp)
                spike.pos=[spike.pos; ind_temp(i)];
                spike.type=[spike.type; 4];
            end
        end
    end
    
    if ~isempty(ind_marker_kurtosis{ch})
        ind_temp = ind_marker_kurtosis{ch};
        if ~isempty(ind_temp)
            for i=1:length(ind_temp)
                spike.pos=[spike.pos; ind_temp(i)];
                spike.type=[spike.type; 5];
            end
        end
    end
    
    if ~isempty(spike.pos) && length(spike.pos)>2
        [sorted.time, sorted.ind] = sort(spike.pos);
        sorted.type = spike.type(sorted.ind);
        difference = (diff(sorted.time) <= combineSpikeTypesTime); 
        j=10;
        difference(end:end+j)=0;
        
        nEvents=length(difference)-j;
        type=cell(nEvents,1); 
        time=cell(nEvents,1);
        for i =1:length(difference)-j
            state = false;
            j=10;
            while j >= 0 && state == false
                if all(difference(i:i+j) == 1)
                    type{i,1} =sorted.type(i:i+j+1)';
                    time{i,1} =sorted.time(i:i+j+1)';
                    j = -1;
                    state = true;
                elseif j == 0 && difference(i) ==0
                    type{i,1} =unique(sorted.type(i));
                    time{i,1} =sorted.time(i);
                    j = -1;
                end
                j=j-1;
            end
        end
        
        if i < nEvents
            time(i+1:end,:)=[];
            type(i+1:end,:)=[];
        end
        
        remove = zeros(length(time),1);
        if length(time)>1
            for j = 1:length(time)-1
                if ~isempty(intersect(time{j},time{j+1}))
                    remove(j+1)=1;
                end
            end
        end
        
        eventHF = zeros(length(time),1);
        for j = 1:length(time)
            if size(unique(type{j}),2)==2 && any(type{j}) == 3 && any(type{j}) == 4
                eventHF(j)=1;
                %remove(j)=1;
            end
        end
        
        if any(eventHF)==1
            timeHF=time(eventHF==1);
            MarkerIdxHF{1,ch}(:,1) = cellfun(@(x) x(1),timeHF);
        end
        time(remove==1)=[];
        type(remove==1)=[];
        
        for j = 1:length(time)
            if size(type{j},2)>1 && any(type{j})==1 || any(type{j})==2 || any(type{j})==5
                t = round(time{j}(1)*fs)-round(combineSpikeTypesTime*fs):round(time{j}(end)*fs)+round(combineSpikeTypesTime*fs);
                t(t<=0)=[];
                t(t>=length(signal(:,ch)))=[];
                [~,idx] = max(abs(signal(t,ch)));
                time{j}(1)=t(idx)/fs;               
            end
        end        
        MarkerIdx{1,ch}(:,1) = cellfun(@(x) x(1),time);
        MarkerType{1,ch} = type;        
    end
end

%% Multi-channel detection
out.pos=[];out.chan=[];out.chInd=[];out.type=[];

% Regular detections
for ch=1:numChannels
    if ~isempty(MarkerIdx{1,ch})
        n=1;
        while n<=size(MarkerIdx{1,ch},1)
            out.pos=[out.pos; MarkerIdx{1,ch}(n,1)];
            out.type=[out.type; MarkerType{1,ch}(n,1)];
            out.chan=[out.chan; ch];
            out.chInd = [out.chInd; n];
            n=n+1;
        end
    end
    
end
%% Detection across leads
% SORTING PER CHANNELS IN LEADS AND THEN BY INDEX

[sorted2.chan, sorted2.ind] = sort(out.chan);
sorted2.value = out.pos(sorted2.ind);
sorted2.chInd = out.chInd(sorted2.ind);
sorted2.type= out.type(sorted2.ind);

j = 0;
multichan = [];
for lead = 1:size(chIdx,2)
    value = sorted2.value(sorted2.chan >= chIdx(1,lead) & sorted2.chan <= chIdx(2,lead));
    type = sorted2.type(sorted2.chan >= chIdx(1,lead) & sorted2.chan <= chIdx(2,lead));
    chan = sorted2.chan(sorted2.chan >= chIdx(1,lead) & sorted2.chan <= chIdx(2,lead));
    
    [resorted_value, resorted_ind] = sort(value);
    resorted_type = type(resorted_ind);
    resorted_chan = chan(resorted_ind);
    multistate = false;
    for i =1:length(resorted_value)
        if multistate == false
            % intersecting detected spikes detected 
            [val,ind] = intersect(round(resorted_value(:)*fs),(round((resorted_value(i)-acrossLeadsTime)*fs):1:(round((resorted_value(i)+acrossLeadsTime)*fs))));
            for n = 1:length(val)
                ind = [ind; find(round(resorted_value(:)*fs)==val(n))];
            end
            ind = unique(ind);
            val = round(resorted_value(ind)*fs);
            if any(ind~=i)
                [val,ind] = intersect(round(resorted_value(:)*fs),(round(resorted_value(i)*fs):1:(round((resorted_value(i)+acrossLeadsTime)*fs))));            
                for n = 1:length(val)
                    ind = [ind; find(round(resorted_value(:)*fs)==val(n))];
                end
                ind = unique(ind);
                val = round(resorted_value(ind)*fs);
            end
            % check that there are spikes in more than one channel or involved
            if length(val)>1 && length(unique(resorted_chan(ind)))>1
                j = j+1;
                multistate = true;
                multichan.time{j} = resorted_value(ind);
                multichan.chan{j} = resorted_chan(ind);
                multichan.type{j} = resorted_type(ind);              
            elseif cell2mat(resorted_type(i))==9
                j = j+1;
                multichan.time{j} = resorted_value(i);
                multichan.chan{j} = resorted_chan(i);
                multichan.type{j} = resorted_type(i);
            end
        elseif i==ind(end)
            multistate = false;
        end
    end
    
end

multi.leadSpecific = multichan;
leadMarkerType = cell(1,numChannels);
leadMarkerIdx = cell(1,numChannels);
for i = 1:length(multichan.chan)
    for chInd = 1:length(multichan.chan{i})
        ch =multichan.chan{i}(chInd);
        if isempty(leadMarkerType{1,ch})
            leadMarkerType{1,ch}={};
        end
        % True spikes put in cell format with columns corresponding to channels
        leadMarkerIdx{1,ch} = [leadMarkerIdx{1,ch};multichan.time{i}(chInd)];
        leadMarkerType{1,ch} =[leadMarkerType{1,ch};multichan.type{i}(chInd)];
    end
end


%% Detection across all channels
clear sorted
[sorted.value, sorted.ind] = sort(out.pos);
sorted.chan = out.chan(sorted.ind);
sorted.type= out.type(sorted.ind);

multistate = false;
multichan = [];
j = 0;
for i = 1: length(sorted.value) 
    % ignore artifacts
    if multistate == false
        % intersecting spikes detected
        [val,ind] = intersect(round(sorted.value(:)*fs),round((sorted.value(i)-acrossLeadsTime)*fs):1:(round((sorted.value(i)+acrossLeadsTime)*fs)));
        for n = 1:length(val)
            ind = [ind; find(round(sorted.value(:)*fs)==val(n))];
        end
        ind = unique(ind);
        val = round(sorted.value(ind)*fs);
        if any(ind~=i)
            [val,ind] = intersect(round(sorted.value(:)*fs),(round(sorted.value(i)*fs):1:(round((sorted.value(i)+acrossLeadsTime)*fs))));
            
            for n = 1:length(val)
                ind = [ind; find(round(sorted.value(:)*fs)==val(n))];
            end
            ind = unique(ind);
            val = round(sorted.value(ind)*fs);
        end
        
        if length(val)>1 && length(unique(sorted.chan(ind)))>1
            j = j+1;
            multistate = true;
            multichan.time{j} = val/fs;
            multichan.chan{j} = sorted.chan(ind);
            multichan.type{j} = sorted.type(ind);
            multichan.ind{j} = ind;
        elseif cell2mat(sorted.type(i))==9
            j = j+1;
            multichan.time{j} = sorted.value(i);
            multichan.chan{j} = sorted.chan(i);
            multichan.type{j} = sorted.type(i);
        end
    elseif i == ind(end)
        multistate = false;
    end
end

multi.allLeads = multichan;

allChanMarkerType = cell(1,numChannels);
allChanMarkerIdx = cell(1,numChannels);
for i = 1:length(multichan.chan)
    for chInd = 1:length(multichan.chan{i})
        ch =multichan.chan{i}(chInd);
        if isempty(allChanMarkerType{1,ch})
            allChanMarkerType{1,ch}={};
        end
        % True spikes put in cell format with columns corresponding to channels
        allChanMarkerIdx{1,ch} = [allChanMarkerIdx{1,ch};multichan.time{i}(chInd)];
        allChanMarkerType{1,ch} =[allChanMarkerType{1,ch};multichan.type{i}(chInd)];
    end
end

% Not within first/last 1.5 seconds
for ch = 1:length(allChanMarkerType)
    allChanMarkerType{1,ch} = allChanMarkerType{1,ch}...
        (allChanMarkerIdx{1,ch} > 1.5 & allChanMarkerIdx{1,ch} <length(signal)/fs-1.5);
    allChanMarkerIdx{1,ch} = allChanMarkerIdx{1,ch}...
        (allChanMarkerIdx{1,ch} > 1.5 & allChanMarkerIdx{1,ch} <length(signal)-1.5);
    leadMarkerType{1,ch} = leadMarkerType{1,ch}...
        (leadMarkerIdx{1,ch} > 1.5 & leadMarkerIdx{1,ch} <length(signal)-1.5);
    leadMarkerIdx{1,ch} = leadMarkerIdx{1,ch}...
        (leadMarkerIdx{1,ch} > 1.5 & leadMarkerIdx{1,ch} <length(signal)-1.5);
end

disp('Spike Detection Complete!');
