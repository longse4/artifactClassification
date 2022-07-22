function [bipolarAnatLabel,bipolarChLabel,bipolarReject,bipolarSOZ,...
    monopolarAnatLabel,monopolarChLabel,monopolarReject]...
    = CreateAnatLabels_noReject(elec_Info_Final_wm,preproInfo)

leadChNames = preproInfo.leadsInfo.channelNames;
    
bipolarAnatLabel = cell(1,length(leadChNames));
bipolarChLabel = cell(1,length(leadChNames));
bipolarReject = cell(1,length(leadChNames));
bipolarSOZ = cell(1,length(leadChNames));

monopolarAnatLabel = cell(1,length(leadChNames));
monopolarChLabel = cell(1,length(leadChNames));
monopolarReject = cell(1,length(leadChNames));
for lead=1:length(leadChNames)
    numContacts = length(leadChNames{lead})-1;
    chIdx = 0;
    if lead > 1
        len = cellfun('length',leadChNames);
        chIdx = sum(len(1:lead-1));
    end   
    rejected = preproInfo.leadsInfo.rejected{1,lead};
    if isfield(preproInfo.leadsInfo,'clinicalInfo')
        bipolarSOZ{lead} = zeros(numContacts,1);
        bipolarSOZ{lead}(strcmp(preproInfo.leadsInfo.clinicalInfo(chIdx+1:chIdx+numContacts,3),'SOZ'))=1;
    end
    %rejectedBipolar = preproInfo.referencingInfo.rejectedBipolar{1,lead};
    n=0;
    
    for j = 1:numContacts
        n = n+1;
        Index = find(contains(elec_Info_Final_wm.name,leadChNames{lead}{j}),1);
        bipolarAnatLabel{lead}{1,n}=strcat(elec_Info_Final_wm.ana_label_name{Index},{' '},'|',{' '},elec_Info_Final_wm.ana_label_name{Index+1});
        bipolarChLabel{lead}{1,n}=strcat(leadChNames{lead}{j},'-',string(j+1));
        if rejected(j)==1 || rejected(j+1)==1 %||rejectedBipolar(j)==1
            bipolarReject{lead}{1,n}=1;
        else
            bipolarReject{lead}{1,n}=0;
        end
        
    end
    n=0;
    for j = 1:numContacts+1
        n = n+1;
        Index = find(contains(elec_Info_Final_wm.name,leadChNames{lead}{j}),1);
        monopolarAnatLabel{lead}{1,n}=elec_Info_Final_wm.ana_label_name{Index};
        monopolarChLabel{lead}{1,n}=leadChNames{lead}{j};
        if rejected(j)==1
            monopolarReject{lead}{1,n}=1;
        else
            monopolarReject{lead}{1,n}=0;
        end
    end
end