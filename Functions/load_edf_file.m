function [signal,state,parameters] = load_dat_file(files)

for kk = 1:length(files)
    disp(['Loading file ' num2str(kk) ' ...']);
    
    [hdr, record] = edfread('C:\Users\sarah.long\Documents\MATLAB\SEEG_Preprocessing\Oct27_2021\Data\example_EDF\ma0844az_1-1+.edf');
    
    [sig, sts, prms] = load_bcidat([dir char(files(kk))], '-calibrated');
    %[sig, sts, prms] = load_bcidat([dir char(files(kk))]);
    %concatenate signal from multiple files
    signal=cat(1,signal,sig);
    %concatenate all of the fields in the state structure
    stateNames=fieldnames(sts);
    index = find(strncmpi(stateNames,'_pad',1));
    stateNames(index) = [];
    if length(files)>1
        concatIdx = [concatIdx; length(sig)];
    end

    for jj = 1:length(stateNames)
        if(isfield(state, char(stateNames(jj)))==0)
            state(1).(char(stateNames(jj)))=sts.(char(stateNames(jj)));
        else
            state.(char(stateNames(jj)))=cat(1,state.(char(stateNames(jj))),sts.(char(stateNames(jj))));
        end
    end    
    % assuming parameters are mostly the same, these are the ones that change
    if (isfield(prms, 'TextToSpell'))
        tmp1 = cat(2,tmp1,char(prms.TextToSpell.Value));
    end    
end
parameters=prms;
if(isfield(parameters, 'TextToSpell'))
    parameters.TextToSpell.Value={tmp1};
end
parameters.concatIdx = concatIdx;
% in case is a stimulus presentation task, create a state called 'Trial'
% which basically counts each letter you type with the P300 Speller
if (isfield(state, 'StimulusCode'))
    samps=size(signal,1);
    indx=find(state.PhaseInSequence(1:samps-1)==1 & state.PhaseInSequence(2:samps)==2)+1;
    state.Trial=zeros(samps,1);
    state.Trial(indx)=ones(1,length(indx));
    state.Trial=int16(cumsum(state.Trial));
end