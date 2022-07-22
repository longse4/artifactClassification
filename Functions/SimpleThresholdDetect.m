function [indMarker]...
    =SimpleThresholdDetect(df,fs,k,polyspikeTime,power,envelopeType,varargin)
%INPUTS:
%   df.................input signal
%   fs.................sampling rate of input signal (Hz)
%   k..................threshold multiplier for detection above background
%   polyspikeTime......time range for merging detections (seconds)
%   power..............envelope raised to this power
%   envelopeType.......hilbert or assumes absolute value

%OUTPUTS:
%   indMarker..........index of spike marker (in seconds)

% -------------------------------------------------------------------------

% Calculate Hilbert's envelope (instantaneous envelope)
if strcmp(envelopeType,'hilbert')
    envelope=abs(hilbert(df)).^power; % calculates down the column
else
    envelope=abs(df).^power; % calculates down the column
end
    
if ~isempty(varargin)    
    p1=mean(log(envelope)); % mean[log(signal)]
    p2=std(log(envelope));  % standard deviation[log(signal)]
    % Threshold
    % log normalized mode = e^(mean(log) - std^2(log))
    lognormal_mode = exp(p1 - p2.^2);
    % log normalized median = e^(mean(log))
    lognormal_median = exp(p1);
    threshold=zeros(size(envelope));
    % k = Multiplier above background 
    threshold(:,1) = k*(lognormal_mode + lognormal_median);
else
    % Exclude outliers
    if k >5
        idx = abs(df)<(k+1)*std(df);
    else
        idx = abs(df)<(6)*std(df);
    end
    
    p1=median(envelope(idx));
    if strcmp(envelopeType,'hilbert')
        p2=std(envelope(idx));  % standard deviation(envelope)
    else
        p2=std(df(idx));  % standard deviation(signal)
    end
    % Threshold
    threshold=zeros(size(envelope));
    % k = Multiplier above background 
    threshold(:,1) = p1+k*p2;
end
threshold2=[];

% -------------------------------------------------------------------------
% Detection of spike 
[~, indMarker] = LocalMaxima(envelope,threshold,threshold2, fs, polyspikeTime);

end