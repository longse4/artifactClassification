function [marker, indEvent] =LocalMaxima_RMS(df,envelope,threshold_5x,threshold_3x,fs,polyspikeTime)

marker=zeros(size(envelope));                   % initialize marker matrix      
marker(envelope(:,:) > threshold_5x(:)) = 1;    % find crossing of threshold
marker_3x=zeros(size(envelope));
marker_3x(envelope(:,:) > threshold_3x(:)) = 1;	% find crossing of threshold

point=[];
point(:,1)=find(diff([0;marker])>0);            % start index of crossing threshold
point(:,2)=find(diff([marker;0])<0);            % end index of crossing threshold

point_3x=[];
point_3x(:,1)=find(diff([0;marker_3x])>0);      % start index of crossing threshold
point_3x(:,2)=find(diff([marker_3x;0])<0);      % end index of crossing threshold

marker = false(size(envelope));                 % change to logical --> all false(0)
%marker_art = false(size(envelope));  
rect_df = abs(df);
for k=1:size(point,1)    
    % Detection of local maxima in section which crossed threshold curve
    if point(k,2)-point(k,1) > ceil(.006*fs) && point(k,2)-point(k,1) < ceil(.1*fs)         
        inter(:,1) = point(k,1)>point_3x(:,1);
        inter(:,2) = point(k,2)<point_3x(:,2);
        idx_3x = find(sum(inter,2)>1);
        seg = rect_df(point_3x(idx_3x,1):point_3x(idx_3x,1));
        if length(seg)>3
            nPeaks = findpeaks(seg);
            if nPeaks > 6 && nPeaks <50
                marker(point(k,1):point(k,2)) = true;
            end
        end
        marker(point(k,1):point(k,2)) = true;
%     elseif point(k,2)-point(k,1) > ceil(.1*fs) 
%         marker_art(point(k,1):point(k,2)) = true;       
    end
end

% Union when close together --------------------------------
event = find(marker==true);     % indices of local maxima found in previous step
state_previous=false;           % initiate previous state variable

for k=1:length(event)
    if ceil(event(k) + polyspikeTime*fs) > size(marker,1)
        seg = marker(event(k)+1:end);
    else
        seg = marker( event(k) + 1:ceil(event(k) + polyspikeTime*fs));
    end
    
    % state_previous is true
    if state_previous
        % check to see if more than one spike during segment
        if sum(seg)>0
            state_previous=true;
        else
            state_previous=false;
            marker(start:event(k))=true; % connect spikes as a single event 
        end
        
    % state_previous is false
    else
        % check to see if more than one spike during segment
        if sum(seg)>0
            state_previous=true;
            start=event(k);       % mark start
        end
    end
end

% finding the beginning and end of detected event
point=[];
point(:,1)=find(diff([0;marker])>0); % start of spike event
point(:,2)=find(diff([marker;0])<0); % end of spike event
point(point(:,2)- point(:,1) < ceil(.006*fs) & point(:,2)- point(:,1) > ceil(.1*fs),:)=[];     
indEvent = point/fs;

% point_art=[];
% point_art(:,1)=find(diff([0;marker_art])>0); % start of spike event
% point_art(:,2)=find(diff([marker_art;0])<0); % end of spike event
%indArt = point_art/fs;
end

