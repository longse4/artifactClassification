function GenerateBipolar()
global ppsEEG

ppsEEG.data.signals.signalBipolar =cell(1,length(ppsEEG.preproInfo.leadsInfo.channelNames));
ppsEEG.preproInfo.bipolarInfo.channelNames =cell(1,length(ppsEEG.preproInfo.leadsInfo.channelNames));
ppsEEG.preproInfo.bipolarInfo.rejected=cell(1,length(ppsEEG.preproInfo.leadsInfo.channelNames));
ppsEEG.preproInfo.bipolarInfo.anatBipolar=cell(1,length(ppsEEG.preproInfo.leadsInfo.channelNames));

for i=1:length(ppsEEG.preproInfo.leadsInfo.channelNames)
    numContacts = length(ppsEEG.preproInfo.leadsInfo.channelNames{i})-1;
    chIdx = 0;
    if i > 1
        len = cellfun('length',ppsEEG.preproInfo.leadsInfo.channelNames);
        chIdx = sum(len(1:i-1));
    end
    rejected = ppsEEG.preproInfo.leadsInfo.rejected{1,i};
    leadName = char(ppsEEG.preproInfo.leadsInfo.channelNames{i}(1));
    leadName = leadName(1:end-1);
    n=0;

    for j = 1:numContacts
        if rejected(j)==0 && rejected(j+1)==0
            n=n+1;
            ppsEEG.data.signals.signalBipolar{i}(:,n) = ppsEEG.data.signals.signalComb60Hz(:,chIdx+j)...
                - ppsEEG.data.signals.signalComb60Hz(:,chIdx+j+1);
            ppsEEG.preproInfo.bipolarInfo.channelNames{i}(:,n) = strcat(leadName,string(j),'-',string(j+1));
            if isfield(ppsEEG.preproInfo.leadsInfo,'clinicalInfo')
                ppsEEG.preproInfo.bipolarInfo.anatBipolar{i}{n} = [strip(ppsEEG.preproInfo.leadsInfo.clinicalInfo{chIdx+j,7},"'")...
                    ,'|',strip(ppsEEG.preproInfo.leadsInfo.clinicalInfo{chIdx+j+1,7},"'")];
            end
            ppsEEG.preproInfo.bipolarInfo.rejected{i}(n) =0;

        end
    end
end