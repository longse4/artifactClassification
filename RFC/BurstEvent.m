function [indEvent] =BurstEvent(signal,envelope,threshold1,threshold2,fs,crossingTime)
polyspikeTime = 1;
marker=zeros(size(envelope));  % initialize marker matrix      
marker2=zeros(size(envelope));  % initialize marker matrix      

marker(envelope(:,:) > threshold1(:)) = 1; % find crossing of threshold
marker2(envelope(:,:) > threshold2(:)) = 1; % find crossing of threshold


point1=[];
point1(:,1)=find(diff([0;marker])>0); % start index of crossing threshold
point1(:,2)=find(diff([marker;0])<0); % end index of crossing threshold

point2=[];
point2(:,1)=find(diff([0;marker2])>0); % start index of crossing threshold
point2(:,2)=find(diff([marker2;0])<0); % end index of crossing threshold

marker = false(size(envelope));    % change to logical --> all false(0)
marker2 = false(size(envelope));    % change to logical --> all false(0)

for k=1:size(point1,1)    
    % Detection of local maxima in section which crossed threshold curve
    if point1(k,2)-point1(k,1) > crossingTime*fs
        marker(point1(k,1):point1(k,2)) = true;
    end
end

for k=1:size(point2,1)    
    % Detection of local maxima in section which crossed threshold curve
    if point2(k,2)-point2(k,1) > crossingTime*fs
        marker2(point2(k,1):point2(k,2)) = true;
    end
end

% Union of local maxima are close together --------------------------------
point1((point1(:,2)-point1(:,1)<crossingTime*fs),:)=[];
point2((point2(:,2)-point2(:,1)<crossingTime*fs),:)=[];
val=[]; j=0;
if ~isempty(point1)   
    for k = 1:size(point1,1)
        temp = intersect(find(point1(k,1)>point2(:,1)),find(point1(k,2)<point2(:,2)));  
        if ~isempty(temp)
            j=j+1;
            val(j)= temp(1);
        end
    end
end
if ~isempty(val)
    point2 = point2(unique(val),:);
end

% idx_remove =[];
% for k=1:size(point2,1)-1
%     t= sort([point2(k,2) point2(k+1,1)]);
%     if ceil(t(1) + polyspikeTime*fs) > size(marker,1)
%         seg = t(1):numel(marker);
%     else
%         seg = t(1):t(2);
%     end
%     
% 
%     % check to see if more than one event during segment
%     if numel(seg)< round(polyspikeTime*fs)
%         point2(k,2) = point2(k+1,2);
%         idx_remove = [idx_remove;k+1];
%         
%     end
%         
% end
% point2(idx_remove,:)=[];

indEvent = point2/fs;
end