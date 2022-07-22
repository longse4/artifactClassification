function df=Filtering(bandwidth,signal,fs,type,order,var)

df = zeros(size(signal));

switch type
    case 1 % IIR-cheby2
        if strcmp(var,'low') || strcmp(var,'bandpass')
            % low pass
            Wp = 2*bandwidth(2)/fs;
            Ws = 2*bandwidth(2)/fs+ 0.05;
            Rp = 6; Rs = 60;
            [n,Ws] = cheb2ord(Wp,Ws,Rp,Rs);
            [bl,al] = cheby2(n,Rs,Ws);
            [zl,pl,kl] = cheby2(n,Rs,Ws);
            
            SOS = zp2sos(zl,pl,kl);
            if isstable(SOS) == true
                disp(strcat('Lowpass filter stable'));
            end
            %zplane(zl,pl)
        end
        
        if strcmp(var,'high') || strcmp(var,'bandpass')
            % high pass
            Wp = 2*bandwidth(1)/fs;
            Ws = 2*bandwidth(1)/fs - 0.01;
            Rp = 6; Rs = 60;
            [n,Ws] = cheb2ord(Wp,Ws,Rp,Rs);
            [bh,ah] = cheby2(n,Rs,Ws,'high');
            [zh,ph,kh]= cheby2(n,Rs,Ws,'high');
            
            SOS = zp2sos(zh,ph,kh);
            if isstable(SOS) == true
%                disp(strcat('Highpass filter stable'));
            end
            %zplane(zl,pl)
        end
        
    case 2 % IIR butterworth
        if strcmp(var,'low') || strcmp(var,'bandpass')
            % low pass
            [bl,al]=butter(order(2),2*bandwidth(2)/fs);
            [zl,pl,kl]=butter(order(2),2*bandwidth(2)/fs);
            
            SOS = zp2sos(zl,pl,kl);
            if isstable(SOS) == true
%                disp(strcat('Lowpass filter stable'));
            end
            %zplane(zl,pl)
        end
        
        if strcmp(var,'high') || strcmp(var,'bandpass')
            % high pass
            [bh,ah]=butter(order(1),2*bandwidth(1)/fs,'high');
            [zh,ph,kh]=butter(order(1),2*bandwidth(1)/fs,'high');
            
            SOS = zp2sos(zh,ph,kh);
            if isstable(SOS) == true
%                disp(strcat('Highpass filter stable'));
            end
            %zplane(zl,pl)
        end
end


if ~exist('parfor')==5
    if strcmp(var,'high') || strcmp(var,'bandpass') 
        df=filtfilt(bh,ah,signal);
%         parfor ch=1:size(signal,2)
%             df(:,ch)=filtfilt(bh,ah,signal(:,ch));
%         end
        %disp('Highpass complete');
    end
    
    if strcmp(var,'low') || strcmp(var,'bandpass')
        if strcmp(var,'bandpass')
            df=filtfilt(bl,al,df);
        else
            df=filtfilt(bl,al,signal);
        end
%         parfor ch=1:size(signal,2)
%             if strcmp(var,'bandpass')
%                 df(:,ch)=filtfilt(bl,al,df(:,ch));
%             else
%                 df(:,ch)=filtfilt(bl,al,signal(:,ch));
%             end
%         end
        %disp('Lowpass filtering complete');
    end
    
else
    if strcmp(var,'high') || strcmp(var,'bandpass') 
        df=filtfilt(bh,ah,signal);
%         for ch=1:size(signal,2)
%             df(:,ch)=filtfilt(bh,ah,signal(:,ch));
%         end
        %disp('Highpass filtering complete');
    end
    
    if strcmp(var,'low') || strcmp(var,'bandpass')
        if strcmp(var,'bandpass')
            df=filtfilt(bl,al,df);
        else
            df=filtfilt(bl,al,signal);
        end
%         for ch=1:size(signal,2)
%             if strcmp(var,'bandpass')
%                 df(:,ch)=filtfilt(bl,al,df(:,ch));
%             else
%                 df(:,ch)=filtfilt(bl,al,signal(:,ch));
%             end
%         end
        %disp('Lowpass complete');
    end
end
    