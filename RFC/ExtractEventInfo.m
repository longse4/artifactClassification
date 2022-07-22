function ppsEEG = ExtractEventInfo(ppsEEG)

% Number of events per condition (manual, auto)
ppsEEG.Events.manualClass = cellfun(@(x,y) y(find(unique(x))), ppsEEG.Events.manualIdx,ppsEEG.Events.manualClass,'UniformOutput',false);
ppsEEG.Events.manualIdx = cellfun(@(x) unique(x), ppsEEG.Events.manualIdx,'UniformOutput',false);

ppsEEG.eventAnalysis.nManual = cellfun(@(x) size(x,1), ppsEEG.Events.manualIdx);
ppsEEG.eventAnalysis.nAuto = cellfun(@(x) size(x,1), ppsEEG.Events.autoIdx);
% Percentage of manual relative to auto
ppsEEG.eventAnalysis.missedManual = ppsEEG.eventAnalysis.nManual./(ppsEEG.eventAnalysis.nManual+ppsEEG.eventAnalysis.nAuto);

% Number of contacts per lead
len = cellfun(@(x) size(x,2), ppsEEG.preproInfo.leadsInfo.channelsBipolar);
% Initiate leadOn variable
leadOn = 1;
chVect = 1:len(leadOn);
% Initiate fields
ppsEEG.eventAnalysis.manualMarks.chanSpecific=cell(1,length(ppsEEG.eventAnalysis.nManual));
ppsEEG.eventAnalysis.manualMarks.leadSpecificIdx=cell(1,length(ppsEEG.eventAnalysis.nManual));
ppsEEG.eventAnalysis.manualMarks.leadSpecificDistance=cell(1,length(ppsEEG.eventAnalysis.nManual));
ppsEEG.eventAnalysis.autoMarks.chanSpecific=cell(1,length(ppsEEG.eventAnalysis.nManual));
ppsEEG.eventAnalysis.autoMarks.leadSpecificIdx=cell(1,length(ppsEEG.eventAnalysis.nManual));
ppsEEG.eventAnalysis.autoMarks.leadSpecificDistance=cell(1,length(ppsEEG.eventAnalysis.nManual));

% Loop through channels
for i = 1:length(ppsEEG.eventAnalysis.nManual)
    if i > sum(len(1:leadOn))
        leadOn=leadOn+1;
        chVect = sum(len(1:leadOn-1))+1:sum(len(1:leadOn));
 
    end 
    if ~isempty(ppsEEG.Events.manualClass{i})
        leadSpecificDistance=[]; leadSpecificIdx=[];
        for n = 1:length(ppsEEG.Events.manualIdx{i})
            idx = ppsEEG.Events.manualIdx{1,i}(n);
            
            %Channel specific
            if ~isempty(ppsEEG.Events.autoIdx{1,i})
                diffVector = idx-ppsEEG.Events.autoIdx{1,i};
                [val,iMin] = min(abs(diffVector));
                ppsEEG.eventAnalysis.manualMarks.chanSpecific{1,i}(n) = diffVector(iMin);
            else
                ppsEEG.eventAnalysis.manualMarks.chanSpecific{1,i}(n) = NaN;
            end
            
            %Lead specific 
            j=0;
            
            for ch = chVect(1):chVect(end)
                if i~=ch
                    if ~isempty(ppsEEG.Events.autoIdx{1,ch})
                        diffVector = idx-ppsEEG.Events.autoIdx{1,ch};
                        [~,iMin] = min(abs(diffVector));
                        j=j+1;                        
                        leadSpecificDistance(n,j)= ch-i;
                        leadSpecificIdx(n,j)= diffVector(iMin);
                    end
                end
                
            end
            
        end
        [ppsEEG.eventAnalysis.manualMarks.leadSpecificIdx{1,i},temp] = min(abs(leadSpecificIdx),[],2);
        for k = 1:size(leadSpecificDistance,1)
            ppsEEG.eventAnalysis.manualMarks.leadSpecificDistance{1,i}(k) = leadSpecificDistance(k,temp(k));
        end
    end
    
    if ~isempty(ppsEEG.Events.autoIdx{i})
        leadSpecificDistance=[]; leadSpecificIdx=[];
        for n = 1:length(ppsEEG.Events.autoIdx{i})
            idx = ppsEEG.Events.autoIdx{1,i}(n);
            
            %Channel specific
            if length(ppsEEG.Events.autoIdx{1,i}) >1
                diffVector = idx-ppsEEG.Events.autoIdx{1,i};
                diffVector(diffVector ==0)=[];
                [~,iMin] = min(abs(diffVector));
                ppsEEG.eventAnalysis.autoMarks.chanSpecific{1,i}(n) = diffVector(iMin);
            else
                ppsEEG.eventAnalysis.autoMarks.chanSpecific{1,i}(n) = NaN;
            end
            
            %Lead specific 
            j=0; 
            for ch = chVect(1):chVect(end)
                if i~=ch
                    if ~isempty(ppsEEG.Events.autoIdx{1,ch})
                        diffVector = idx-ppsEEG.Events.autoIdx{1,ch};
                        [~,iMin] = min(abs(diffVector));
                        j=j+1;                        
                        leadSpecificDistance(n,j)= ch-i;
                        leadSpecificIdx(n,j)= diffVector(iMin);
                    end
                end
                
            end
            
        end
        %[ppsEEG.eventAnalysis.autoMarks.leadSpecificIdx{1,i},temp] = min(abs(leadSpecificIdx),[],2);
        for k = 1:size(leadSpecificDistance,1)
            ppsEEG.eventAnalysis.autoMarks.leadSpecificIdx{1,i}{k} = leadSpecificIdx(k,abs(leadSpecificIdx(k,:))<0.3);
            ppsEEG.eventAnalysis.autoMarks.leadSpecificDistance{1,i}{k} = leadSpecificDistance(k,abs(leadSpecificIdx(k,:))<0.3);
            %ppsEEG.eventAnalysis.autoMarks.leadSpecificDistance{1,i}{k} = leadSpecificDistance(k,temp(k));
        end
    end
end