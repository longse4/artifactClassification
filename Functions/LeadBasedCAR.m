function LeadBasedCAR()

global ppsEEG
anatMapping = readtable('anat_labels.csv');
anatMonopolar = ppsEEG.preproInfo.leadsInfo.clinicalInfo.Anat_Label;
anatomyIdx = zeros(length(anatMonopolar),1);
anatomyLabel = cell(length(anatMonopolar),1);
ppsEEG.preproInfo.leadsInfo.labelRFC = zeros(length(anatMonopolar),1);

for i =1:length(anatMapping.OldLabel)
    temp =find(ismember(anatMonopolar,strcat("'", anatMapping.OldLabel{i}, "'"))==1);
    if ~isempty(temp)
        anatomyIdx(temp,1)=i;
        for j = 1:length(temp)
            anatomyLabel{temp(j),1}=anatMapping.NewLabel{i};
        end
    end 
end

anat_mapping_uni =unique(anatMapping.NewLabel);
%Label for classification purposes
for i =1:length(anat_mapping_uni)
    ppsEEG.preproInfo.leadsInfo.labelRFC(strcmp(anatomyLabel,anat_mapping_uni{i}),1)=i;
end

leadNum=[];
% Initiate for CAR by leads
ppsEEG.data.signals.signalCAR=zeros(size(ppsEEG.data.signals.signalComb60Hz));
for lead = 1:length(ppsEEG.preproInfo.leadsInfo.channelNames)
    temp = zeros(1,length(ppsEEG.preproInfo.leadsInfo.channelNames{1,lead})); 
    temp(:)=lead;
    leadNum = [leadNum,temp]; 
    chanVect = find(leadNum==lead); 
    rejectLead =ppsEEG.preproInfo.leadsInfo.rejected{1,lead};    
    CAR = mean(ppsEEG.data.signals.signalComb60Hz(:,chanVect(rejectLead==0)),2);
    n = chanVect(1:length(ppsEEG.preproInfo.leadsInfo.channelNames{1,lead}));
    ppsEEG.data.signals.signalCAR(:,n) = ppsEEG.data.signals.signalComb60Hz(:,n)- CAR;
end
