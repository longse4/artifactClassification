function [marker, indMarker] =LocalMaxima(envelope,threshold,threshold2,fs,polyspikeTime)

marker=zeros(size(envelope));  % initialize marker matrix      
marker(envelope(:,:) > threshold(:)) = 1; % find crossing of threshold
if ~isempty(threshold2)
    marker(envelope(:,:) > threshold2(:)) = 1; % find crossing of threshold
end

point=[];
point(:,1)=find(diff([0;marker])>0); % start index of crossing threshold
point(:,2)=find(diff([marker;0])<0); % end index of crossing threshold

marker = false(size(envelope));    % change to logical --> all false(0)

for k=1:size(point,1)
    
    % Detection of local maxima in section which crossed threshold curve
    if point(k,2)-point(k,1) > 2
        seg = envelope(point(k,1):point(k,2));      % amplitudes 
        seg_diff = diff(seg);                       % difference between amplitudes
        seg_diff = sign(seg_diff);                  % find the sign of the difference 
        seg_diff = find(diff([0;seg_diff]) < 0);  	% index of local maxima 
        marker(point(k,1) + seg_diff - 1) = true;
    
    elseif point(k,2)- point(k,1) <= 2
        seg = envelope(point(k,1):point(k,2));      % amplitudes 
        [~,s_max] = max(seg);                       % index of local maxima in the section
        marker(point(k,1) + s_max - 1) = true;      % mark the index with maximum amplitude
    end
end


% Union of local maxima are close together --------------------------------

maxima = find(marker==true);    % indices of local maxima found in previous step
state_previous=false;           % initiate previous state variable

for k=1:length(maxima)
    if ceil(maxima(k) + polyspikeTime*fs) > size(marker,1)
    %if ceil(maxima(k) + polyspikeTime) > size(marker,1)
        seg = marker(maxima(k)+1:end);
    else
        seg = marker( maxima(k) + 1:ceil(maxima(k) + polyspikeTime*fs));
        %seg = marker( maxima(k) + 1:ceil(maxima(k) + polyspikeTime));
    end
    
    % state_previous is true
    if state_previous
        % check to see if more than one spike during segment
        if sum(seg)>0
            state_previous=true;
            marker(start:maxima(k))=true; % connect spikes as a single event
        else
            state_previous=false;
            marker(start:maxima(k))=true; % connect spikes as a single event 
        end
        
    % state_previous is false
    else
        % check to see if more than one spike during segment
        if sum(seg)>0
            state_previous=true;
            start=maxima(k);       % mark first spike in event
        end
    end
end

% finding of the maxima of the section with local maxima (now accounts for poly spikes)
point=[];
point(:,1)=find(diff([0;marker])>0); % start of spike event
point(:,2)=find(diff([marker;0])<0); % end of spike event

% local maxima with gradient in surroundings
for k=1:size(point,1)
    if point(k,2)-point(k,1)>1
        % pointer: any detected spike
        % point(:,1): start of spike event
        % point(:,2): end of spike event
        
        % local_max: index of local maxima within a spike event
        local_max = maxima(maxima >= point(k,1) & maxima <= point(k,2)); 
        % reset marker to false 
        marker(point(k,1):point(k,2))=false;   
        % local_max_val: envelope magnitude at local maxima
        local_max_val=envelope(local_max); 
        % local_max_poz: index of envelope local maxima
        local_max_poz=(diff(sign(diff([0;local_max_val;0]))<0)>0);
        % set marker to true at the index of local maxima 
        marker(local_max(local_max_poz))=true;
    end
end

% remove any spikes in the first 2 seconds and last second of data
marker([1:fs*2, end-fs:end],:)=false;
indMarker = find(marker)/fs;

newMarker = [];
state_previous = false;
if length(indMarker)<2
    newMarker = indMarker;
end

for k=1:length(indMarker)-1    
    % state_previous is true
    if state_previous
        % check to see if more than one spike during segment
        if indMarker(k+1)-indMarker(k)<polyspikeTime
            state_previous=true;
            if k == length(indMarker)-1 
                temp_idx = round(indMarker(start)*fs):round(indMarker(k)*fs);
                [~,tempMarker] = max(envelope(temp_idx));
                newMarker = [newMarker;temp_idx(tempMarker)/fs];
            end
        else
            state_previous=false;
            temp_idx = round(indMarker(start)*fs):round(indMarker(k)*fs);
            [~,tempMarker] = max(envelope(temp_idx));
            newMarker = [newMarker;temp_idx(tempMarker)/fs];
        end
        
    % state_previous is false
    else
        if k<length(indMarker)   
            % check to see if more than one spike during segment
            if indMarker(k+1)-indMarker(k)<polyspikeTime
                state_previous=true;
                start=k;       % mark first spike in event
            else
                newMarker = [newMarker;indMarker(k)];
                state_previous=false;
            end
        else
            newMarker = [newMarker;indMarker(k)];
        end
    end
end
indMarker = newMarker;
end