function [indBurst]...
    =SingleChannelDetectBurst(signal,fs,winsize,overlap,crossingTime,k,k2,power,varargin)
%INPUTS:
%   signal.............input signal
%   fs.................sampling rate of input signal (Hz)
%   winsize............window size of segments (seconds)
%   overlap............window overlap (decimal)
%   polyspikeTime......time range for merging detections (seconds)

%OUTPUTS:
%   indMarker..........index of spike marker (in seconds)

% -------------------------------------------------------------------------
winsize=round(winsize*fs);
noverlap=round(overlap*winsize);
index = 1:(winsize - noverlap):(size(signal,1) - winsize + 1);

k2 =3;

p = zeros(length(index),1);
for i=1:length(index) 
    segment = signal(index(i):index(i)+ winsize-1);
    if power ~= 1
        segment = segment.^power;
    end
    p(i,1) = sum(abs(diff(segment)));   % line length
end
n = round(size(signal,1)/length(index));     % approximate number values covered by each step

% Smooth 
p_smooth=[];
p_smooth(:,1)=filtfilt(ones(round(winsize/n),1)/(round(winsize/n)),1,p(:,1));

% -------------------------------------------------------------------------

% spline creation
p_interp=[];
p_interp(:,1) = interp1(index+round(winsize/2),p_smooth(:,1),(index(1):index(end))+round(winsize/2),'spline');
p_interp=[...
    % repeat first value at the beginning (winsize/2)
    ones(floor(winsize/2),size(p_smooth,2)).*repmat(p_interp(1,:),floor(winsize/2),1);p_interp;...
    % repeat the last value at end as needed
    ones(size(signal,1)-(length(p_interp)+floor(winsize/2)),size(p_smooth,2)).*repmat(p_interp(end,:),size(signal,1)-(length(p_interp)+floor(winsize/2)),1)];

%p_interp = zscore(p_interp);
threshold_1 = zeros(size(p_interp));
threshold_2 = zeros(size(p_interp));
if isempty(varargin)
    threshold_1(:)=median((p_interp)) + (k)*std(abs(p_interp));
    threshold_2(:)=median((p_interp)) + (k)*std(abs(p_interp));
else
    threshold_1(:)=median((p_interp(~isoutlier(p_interp(:,1),'median'),1))) + (k)*std(abs(p_interp(~isoutlier(p_interp(:,1),'median'),1)));
    threshold_2(:)=median((p_interp(~isoutlier(p_interp(:,1),'median'),1))) + (k2)*std(abs(p_interp(~isoutlier(p_interp(:,1),'median'),1)));
end

% -------------------------------------------------------------------------
% Detection of burst events 
[indBurst] = BurstEvent(signal,p_interp, threshold_1,threshold_2, fs,crossingTime);

%[eventInfo] = EventClassification(signal_zscore,signal,indBurst,fs);


end