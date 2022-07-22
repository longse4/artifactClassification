function [indMarker]...
    =DetectRMS(df,fs,polyspikeTime,winsize,overlap)
%INPUTS:
%   df.................input signal
%   fs.................sampling rate of input signal (Hz)
%   polyspikeTime......time range for merging detections (seconds)
%   winsize............window size of segment (seconds)
%   overlap............overlap of segments (decimal)
%   new_fs.............new sampling rate (Hz)

%OUTPUTS:
%   marker.............logical vector of markers (resampled to new_fs)
%   indMarker..........index of marker (based on time in seconds)
%   threshold..........threshold vector used for detection (resampled to new_fs)

% Creating Distribution ---------------------------------------------------
winsize=round(winsize*fs);
noverlap=round(overlap*winsize);
index = 1:(winsize - noverlap):(size(df,1) - winsize + 1);

p = zeros(length(index),1);
for i=1:length(index)    
    segment = df(index(i):index(i)+ winsize-1);
    p(i,1) = rms(segment);
end

% Spline Creation ---------------------------------------------------------
p_interp=[];
p_interp(:,1) = interp1(index+round(winsize/2),p(:,1),(index(1):index(end))+round(winsize/2),'spline');
p_interp=[...
    % repeat first value at the beginning (winsize/2)
    ones(floor(winsize/2),size(p,2)).*repmat(p_interp(1,:),floor(winsize/2),1);p_interp;...
    % repeat the last value at end as needed
    ones(size(df,1)-(length(p_interp)+floor(winsize/2)),size(p,2)).*repmat(p_interp(end,:),size(df,1)-(length(p_interp)+floor(winsize/2)),1)];

% Threshold Creation ------------------------------------------------------        
threshold_5x = zeros(size(p_interp));
threshold_3x = zeros(size(p_interp));
% Exclude outliers in creating threshold
threshold_5x(:)=mean(p(:,1)) + 5*std(p(:,1));
threshold_3x(:)=mean(p(:,1)) + 3*std(p(:,1));

% Threshold Detection -----------------------------------------------------
[~,indMarker] = LocalMaxima_RMS(df,p_interp, threshold_5x,threshold_3x, fs, polyspikeTime);

end