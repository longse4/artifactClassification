function [features,featureMapping]=ExtractFeaturesSpikeDetection_reduced(signal,rejected,MarkerIdx,MarkerChLabel,fs,SOZChLabel,lineNoise)

len = cell2mat(cellfun(@(x) size(x,1),MarkerIdx,'UniformOutput',0));
nEvents=sum(len);
fVector = logspace(log10(2),log10(120),30);

%Initialize variables -----------------------------------------------------
% RIPPLE VARIABLES
lineLength_ripple = zeros(nEvents,1);
ripple_kurt = zeros(nEvents,1);
ripple_skew = zeros(nEvents,1);
ripple_Duration = zeros(nEvents,1);
envelope_ripple_max = zeros(nEvents,1);
envelope_ripple_kurt = zeros(nEvents,1);
envelope_ripple_skew = zeros(nEvents,1);
envelope_ripple_mean = zeros(nEvents,1);

% FAST RIPPLE VARIABLES
lineLength_fastRipple = zeros(nEvents,1);
fastRipple_kurt = zeros(nEvents,1);
fastRipple_skew = zeros(nEvents,1);
nFastRipples = zeros(nEvents,1);
fastRipple_Duration = zeros(nEvents,1);
envelope_fastRipple_max = zeros(nEvents,1);
envelope_fastRipple_kurt = zeros(nEvents,1);
envelope_fastRipple_skew = zeros(nEvents,1);
envelope_fastRipple_mean = zeros(nEvents,1);

% BETA & GAMMA BAND
phys_kurt = zeros(nEvents,1);
phys_skew = zeros(nEvents,1);
phys_max = zeros(nEvents,1);
phys_diff = zeros(nEvents,1);
envelope_phys_max = zeros(nEvents,1);
envelope_phys_kurt = zeros(nEvents,1);
envelope_phys_skew = zeros(nEvents,1);
envelope_phys_mean = zeros(nEvents,1);

% WICKET BAND
lineLength_wicket = zeros(nEvents,1);
envelope_wicket_max = zeros(nEvents,1);
envelope_wicket_kurt = zeros(nEvents,1);
envelope_wicket_skew = zeros(nEvents,1);
envelope_wicket_mean = zeros(nEvents,1);
wicket_kurt = zeros(nEvents,1);
wicket_skew = zeros(nEvents,1);

% MUSCLE ARTIFACT BAND
envelope_muscle_max = zeros(nEvents,1);
envelope_muscle_kurt = zeros(nEvents,1);
envelope_muscle_mean = zeros(nEvents,1);
envelope_muscle_skew = zeros(nEvents,1);
muscle_skew = zeros(nEvents,1);
muscle_kurt = zeros(nEvents,1);

% PSD Tilt
tilt = zeros(nEvents,1);

% WAVELET VARIABLES
db4_d3_max = zeros(nEvents,1);

% WAVEFORM VARIABLES
max_amp = zeros(nEvents,1);
peak_to_peak = zeros(nEvents,1);
line_length_smooth = zeros(nEvents,1);
duration = zeros(nEvents,1);
n_peaks = zeros(nEvents,1);
slope2_peaks = zeros(nEvents,1);
m_peaks = zeros(nEvents,1);
m_troughs = zeros(nEvents,1);
n_crossing = zeros(nEvents,1);

state = zeros(nEvents,1);
anatomy = zeros(nEvents,1);
soz = zeros(nEvents,1);

tVec = 1:(fs*3);
channel= zeros(nEvents,1);
eventIdx= zeros(nEvents,1);
markerIndex= zeros(nEvents,1);

% filter coefficients 
[b,a]=butter(3,2*(0.05)/fs,'high');
% muscle artifact        
[bh_muscle,ah_muscle]=butter(3,2*(70)/fs,'high');   %70Hz
[bl_muscle,al_muscle]=butter(3,2*(100)/fs,'low');    %100Hz
% physiological band
[bh_phys,ah_phys]=butter(3,2*(20)/fs,'high');   %20Hz
[bl_phys,al_phys]=butter(3,2*(80)/fs,'low');    %80Hz
%fast ripple band features ------------------------------------
[bh_fastripple,ah_fastripple]=butter(3,2*(200)/fs,'high');  %200Hz
[bl_fastripple,al_fastripple]=butter(3,2*(599)/fs,'low');   %599Hz
%ripple band features -----------------------------------------
[bh_ripple,ah_ripple]=butter(3,2*(80)/fs,'high');   %80Hz
[bl_ripple,al_ripple]=butter(3,2*(200)/fs,'low');   %200Hz
%wicket band features -----------------------------------------
[bh_wicket,ah_wicket]=butter(3,2*(6)/fs,'high');  %6 Hz
[bl_wicket,al_wicket]=butter(3,2*(11)/fs,'low');   %11 Hz

%samples_30sec=round(fs*0.5);
samples_90sec=round(fs*1.5);
%samples_120sec=round(fs*2.0);

i=0;
for ch = 1:numel(MarkerIdx) 
    tempSOZCh = SOZChLabel(ch);
    tempMarkerIdx = MarkerIdx{1,ch};
    if ~isempty(tempMarkerIdx) && rejected(ch)==0
        %high pass filter
        signal_filt=filtfilt(b,a,signal(:,ch));
        signal_smooth = filtfilt(ones(round(fs/lineNoise),1)/(round(fs/lineNoise)),1,signal_filt);
        
        %loops through all detected events in a single channel
        for event = i+1:i+numel(tempMarkerIdx)
            idx = round(tempMarkerIdx(event-i)*fs);
            soz(event,1) = tempSOZCh;
            if iscell(MarkerChLabel)
                anatomy(event,1) = MarkerChLabel{ch};
            else
                anatomy(event,1) = MarkerChLabel(ch);
            end
            
            %data = zscore(signal(idx-round(fs*1.5):idx+round(fs*1.5)-1,ch));
            data = zscore(signal_filt(idx-samples_90sec:idx+samples_90sec-1));
            channel(event,1) = ch;
            eventIdx(event,1) = event;
            markerIndex(event,1)= tempMarkerIdx(event-i);
            state(event,1) = 1;
            
            %smoothing ------------------------------------------------
            data_smooth = zscore(signal_smooth(idx-samples_90sec:idx+samples_90sec-1));
            
            %muscle artifact features ---------------------------------
            data_muscle=filtfilt(bh_muscle,ah_muscle,data);
            data_muscle=filtfilt(bl_muscle,al_muscle,data_muscle);
            envelope_muscle = (abs(hilbert(data_muscle)));
            envelope_muscle_max(event,1)=max(envelope_muscle(fs*.1:end-fs*.1));
            envelope_muscle_kurt(event,1)=kurtosis(envelope_muscle(fs*.1:end-fs*.1));
            envelope_muscle_skew(event,1)=skewness(envelope_muscle(fs*.1:end-fs*.1));
            envelope_muscle_mean(event,1) = mean(envelope_muscle(fs*.1:end-fs*.1));
            muscle_skew(event,1)=skewness(data_muscle(fs*.1:end-fs*.1));
            muscle_kurt(event,1)=kurtosis(data_muscle(fs*.1:end-fs*.1));           
            
            %physiological band features ----------------------------------
            data_phys=filtfilt(bh_phys,ah_phys,data);
            data_phys=filtfilt(bl_phys,al_phys,data_phys);
            envelope_phys = (abs(hilbert(data_phys)));
            envelope_phys_max(event,1)=max(envelope_phys(fs*.1:end-fs*.1));
            envelope_phys_kurt(event,1)=kurtosis(envelope_phys(fs*.1:end-fs*.1));
            envelope_phys_skew(event,1)=skewness(envelope_phys(fs*.1:end-fs*.1));
            envelope_phys_mean(event,1) = mean(envelope_phys(fs*.1:end-fs*.1));
            phys_kurt(event,1)=kurtosis(data_phys(fs*.1:end-fs*.1));
            phys_skew(event,1)=skewness(data_phys(fs*.1:end-fs*.1));
            phys_max(event,1) = max(abs(data_phys(fs*.1:end-fs*.1)));
            min_idx = min(data_phys(fs*.1:end-fs*.1));
            max_idx = max(data_phys(fs*.1:end-fs*.1));
            phys_diff(event,1) = abs(max_idx - min_idx);
            
            %fast ripple band features ------------------------------------
            data_fastRipple=filtfilt(bh_fastripple,ah_fastripple,data);
            data_fastRipple=filtfilt(bl_fastripple,al_fastripple,data_fastRipple);
            lineLength_fastRipple(event,1) = sum(abs(diff(data_fastRipple)));
            envelope_fastRipple = (abs(hilbert(data_fastRipple)));
            envelope_fastRipple_max(event,1)=max(envelope_fastRipple(fs*.1:end-fs*.1));
            envelope_fastRipple_kurt(event,1)=kurtosis(envelope_fastRipple(fs*.1:end-fs*.1));
            envelope_fastRipple_skew(event,1)=skewness(envelope_fastRipple(fs*.1:end-fs*.1));
            envelope_fastRipple_mean(event,1) = mean(envelope_fastRipple(fs*.1:end-fs*.1));
            fastRipple_kurt(event,1)=kurtosis(data_fastRipple(fs*.1:end-fs*.1));
            fastRipple_skew(event,1)=skewness(data_fastRipple(fs*.1:end-fs*.1));
            
            fR = DetectRMS_3x(data_fastRipple,fs,0.01,0.003,0);
            if ~isempty(fR)
                nFastRipples(event,1) = size(fR,1); %number of fast ripples
                fastRipple_Duration(event,1) = max(fR(:,2)-fR(:,1)); %longest fast ripple duration
            end
            
            %ripple band features -----------------------------------------
            data_ripple=filtfilt(bh_ripple,ah_ripple,data);
            data_ripple=filtfilt(bl_ripple,al_ripple,data_ripple);
            lineLength_ripple(event,1) = sum(abs(diff(data_ripple)));
            envelope_ripple = (abs(hilbert(data_ripple)));
            envelope_ripple_max(event,1)=max(envelope_ripple(fs*.1:end-fs*.1));
            envelope_ripple_kurt(event,1)=kurtosis(envelope_ripple(fs*.1:end-fs*.1));
            envelope_ripple_skew(event,1)=skewness(envelope_ripple(fs*.1:end-fs*.1));
            envelope_ripple_mean(event,1) = mean(envelope_ripple(fs*.1:end-fs*.1));
            ripple_kurt(event,1)=kurtosis(data_ripple(fs*.1:end-fs*.1));
            ripple_skew(event,1)=skewness(data_ripple(fs*.1:end-fs*.1));
            
            r = DetectRMS_3x(data_ripple,fs,0.01,0.003,0);
            if ~isempty(r)
                ripple_Duration(event,1) = max(r(:,2)-r(:,1));  %longest ripple duration
            end
            
            %wicket band features -----------------------------------------
            data_wicket=filtfilt(bh_wicket,ah_wicket,data);
            data_wicket=filtfilt(bl_wicket,al_wicket,data_wicket);
            lineLength_wicket(event,1) = sum(abs(diff(data_wicket)));
            envelope_wicket = (abs(hilbert(data_wicket)));
            envelope_wicket_max(event,1)=max(envelope_wicket(fs*.1:end-fs*.1));
            envelope_wicket_kurt(event,1)=kurtosis(envelope_wicket(fs*.1:end-fs*.1));
            envelope_wicket_skew(event,1)=skewness(envelope_wicket(fs*.1:end-fs*.1));
            envelope_wicket_mean(event,1) = mean(envelope_wicket(fs*.1:end-fs*.1));
            wicket_kurt(event,1)=kurtosis(data_wicket(fs*.1:end-fs*.1));
            wicket_skew(event,1)=skewness(data_wicket(fs*.1:end-fs*.1));
            
            
            %tilt features ------------------------------------------------
            [p,f] = periodogram(data,[],fVector,fs);
            Y=p'; Y= 10*log10(Y);
            X=(f');
            H = [ones(length(Y),1),X];
            Astar = (H'*H)\H'*Y;
            Yhat = H*Astar;
            tilt(event,1) = tan((Yhat(end)-Yhat(1))/(X(end)-X(1)))';
            
            %wavelet features ---------------------------------------------
            data_128 = resample(data,128,fs);
            wave_n =3; wave_typ = 'db4';
            [db4_d3_max(event,1)]...
                = CalculateWaveletFeatures_reduced(data_128,wave_n,wave_typ);
            
            %morphological features ---------------------------------------
            [temp_max_amp]= max(data);
            [min_amp]= min(data);
            peak_to_peak(event,1) = temp_max_amp - min_amp;
            max_amp(event,1)=max(temp_max_amp,min_amp);
            line_length_smooth(event,1) = sum(abs(diff(data_smooth)));
            
            peaks = findpeaksx(tVec,data_smooth,0,-10,round(0.0125*fs),1,3);
            n_peaks(event,1) = peaks(end,1);
            peak_height = data(peaks(:,2));
            peak_idx = peaks(:,2);
            troughs = findpeaksx(tVec,-data_smooth,0,-10,round(0.0125*fs),1,3);
            trough_height = data(troughs(:,2));
            trough_idx = troughs(:,2);
            if size(trough_idx,1)>size(peak_idx,1)
                n = size(trough_idx,1)-size(peak_idx,1)-1;
                trough_idx(end-n:end)=[];
                trough_height(end-n:end)=[];
                troughs(end-n:end,:)=[];
            elseif size(trough_idx,1)<size(peak_idx,1)
                n = size(peak_idx,1)-size(trough_idx,1)-1;
                peak_idx(end-n:end)=[];
                peak_height(end-n:end)=[];
                peaks(end-n:end,:)=[];
            end            
            if length(peak_idx)>1 && length(trough_idx)>1 && length(troughs)>2 && length(peaks)>2
                slope2=zeros(length(peak_idx)-1,1);
                
                if trough_idx(1)<peak_idx(1)
                    for j = 1:length(peak_idx)-1
                        slope2(j) = fs*(peak_height(j)+trough_height(j+1))/(trough_idx(j+1) - peak_idx(j));
                    end
                    slope2_peaks(event,1) =mean(slope2(peaks(1:end-1,3)>2));
                else

                    for j = 1:length(peak_idx)-1
                        slope2(j) = fs*(trough_height(j)+peak_height(j+1))/(peak_idx(j+1) - trough_idx(j));
                    end
                    slope2_peaks(event,1) =mean(slope2(peaks(1:end-1,3)>2));
                end
                
            end            
            m_peaks(event,1) = mean(peak_height(peaks(:,3)>2));
            m_troughs(event,1) = mean(trough_height(troughs(:,3)>2));
            n_crossing(event,1) = length(find(diff(sign(data_smooth(0.1*fs:end-0.1*fs)))));
        end
        i=i+numel(tempMarkerIdx);
    end
end

features = table(ripple_Duration,nFastRipples,fastRipple_Duration,...
    envelope_wicket_max,envelope_muscle_max,envelope_phys_max,envelope_fastRipple_max,envelope_ripple_max,...
    envelope_wicket_kurt,envelope_muscle_kurt,envelope_phys_kurt,envelope_fastRipple_kurt,envelope_ripple_kurt,...
    envelope_wicket_skew,envelope_muscle_skew,envelope_phys_skew,envelope_fastRipple_skew,envelope_ripple_skew,...
    envelope_wicket_mean,envelope_muscle_mean,envelope_phys_mean,envelope_fastRipple_mean,envelope_ripple_mean,...
    wicket_kurt,muscle_kurt,phys_kurt,fastRipple_kurt,ripple_kurt,...
    wicket_skew,muscle_skew,phys_skew,fastRipple_skew,ripple_skew,...
    lineLength_wicket,lineLength_fastRipple,lineLength_ripple,...
    phys_max,phys_diff,...
    tilt,...
    db4_d3_max,...
    max_amp, peak_to_peak,duration,...
    line_length_smooth,...
    n_peaks,m_peaks,m_troughs,n_crossing,...
    slope2_peaks,...
    anatomy,state,soz);

featureMapping.channel = channel;
featureMapping.eventIdx = eventIdx;
featureMapping.MarkerIdx = markerIndex;

for j= 1: size(features,2)
    features.(j)(isnan(features.(j))) = 0;
end 


