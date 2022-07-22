function [indMarker,markerType]=IED_KurtosisDetect(df,fs)

threshold=std(df);

winsize=10*fs; %in seconds %was 10
noverlap=0.9; %percentage %was 90%
noverlap = noverlap*winsize; 
index = 1:(winsize - noverlap):(size(df,1) - winsize + 1);
marker=zeros(length(df),1);
kurt_10 = zeros(1,length(index));
for i=1:length(index)
    tempIdx = index(i):index(i)+ winsize-1;
    segment = df(tempIdx);
    kurt_10(i) = kurtosis(segment);
end
mu = mean(log(kurt_10));
sigma = std(log(kurt_10));
for i=1:length(index)
    tempIdx = index(i):index(i)+ winsize-1;
    segment = df(tempIdx);
    if log(kurt_10(i))>mu+3*sigma
        [eventMax,eventIdx] = max(abs(segment));
        if eventMax > 5*threshold
            marker(tempIdx(eventIdx))=10;
        end
    end
end

winsize=5*fs; %in seconds %was 5
noverlap=0.9; %percentage %was 90%
noverlap = noverlap*winsize; 
index = 1:(winsize - noverlap):(size(df,1) - winsize + 1);
kurt_5 = zeros(1,length(index));
for i=1:length(index)
    tempIdx = index(i):index(i)+ winsize-1;
    segment = df(tempIdx);
    kurt_5(i) = kurtosis(segment);
end
mu = mean(log(kurt_5));
sigma = std(log(kurt_5));
for i=1:length(index)
    tempIdx = index(i):index(i)+ winsize-1;
    segment = df(tempIdx);
    if log(kurt_5(i))>mu+3*sigma
        [eventMax,eventIdx] = max(abs(segment));
        if eventMax > 5*threshold
            marker(tempIdx(eventIdx))=10;
        end
    end
end

winsize=3*fs; %in seconds %was 5
noverlap=0.9; %percentage %was 90%
noverlap = noverlap*winsize; 
index = 1:(winsize - noverlap):(size(df,1) - winsize + 1);

kurt_3 = zeros(1,length(index));
for i=1:length(index)
    tempIdx = index(i):index(i)+ winsize-1;
    segment = df(tempIdx);
    kurt_3(i) = kurtosis(segment);
end
mu = mean(log(kurt_3));
sigma = std(log(kurt_3));
for i=1:length(index)
    tempIdx = index(i):index(i)+ winsize-1;
    segment = df(tempIdx);
    if log(kurt_3(i))>mu+3*sigma
        [eventMax,eventIdx] = max(abs(segment));
        if eventMax > 5*threshold
            marker(tempIdx(eventIdx))=10;
        end
    end
end

indMarker = find(marker>0)/fs;
markerType = marker(marker>0);

