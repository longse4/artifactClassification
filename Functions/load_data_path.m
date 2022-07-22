function [ signal, state, parameters, files, elec_info ] = load_data_path(folderPath)
%
% Call the function: [signal, state, parms] = load_data();
% to load in (possibly multiple) .dat files
%
%Load in multiple .dat files
signal=[]; state=struct([]);  tmp1 = [];
folder = strcat(folderPath,'\','*.dat');
%[files,dir] = uigetfile('*.dat','Select the .dat file(s)','multiselect','on');
[files,dir] = uigetfile(folder,'Select the .dat file(s)','multiselect','on');
if(~iscell(files))
    files=cellstr(files);
end
concatIdx = [];
for kk = 1:length(files)
    disp(['Loading file ' num2str(kk) ' ...']);
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


answer = questdlg('Would you like to load clinical electrode info?', ...
	'Electrode Menu', ...
	'Yes','No','No');
switch answer
    case 'Yes'
        [filename,pathname] = uigetfile('*.xlsx','Select the Clinical Electrode Info');
        elec_info = readtable([pathname filename]);
        elec_info = elec_info{:,:};
        elec_info(cellfun('isempty',elec_info))={'NaN'};
    case 'No'
        elec_info=[];
end
        








