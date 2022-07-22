function [markingAnalysis,trueLabels,agreeLabels] = CompareMarkingInfo(mitro,bruzzone,importance)

% INPUT
% mitro/bruzzone        contain 'Events' field with auto & manual class info
% importance            vector of label class based on order of importance [2 3 1]


% both agree (initiate fields)
markingAnalysis.agree.Logic = cell(1,length(mitro.Events.autoClass));
markingAnalysis.agree.Art = cell(1,length(mitro.Events.autoClass));
markingAnalysis.agree.Path = cell(1,length(mitro.Events.autoClass));
markingAnalysis.agree.Phys = cell(1,length(mitro.Events.autoClass));
markingAnalysis.agree.ArtCount = cell(1,length(mitro.Events.autoClass));
markingAnalysis.agree.PathCount = cell(1,length(mitro.Events.autoClass));
markingAnalysis.agree.PhysCount = cell(1,length(mitro.Events.autoClass));
markingAnalysis.agree.Percent = cell(1,length(mitro.Events.autoClass));
markingAnalysis.agree.Sum = cell(1,length(mitro.Events.autoClass));
markingAnalysis.agree.Total=0;
markingAnalysis.agree.ArtTotal=0;
markingAnalysis.agree.PathTotal=0;
markingAnalysis.agree.PhysTotal=0;

% ambiguous information  (initiate fields)
markingAnalysis.ambiguous.Logic = cell(1,length(mitro.Events.autoClass));
markingAnalysis.ambiguous.Art = cell(1,length(mitro.Events.autoClass));
markingAnalysis.ambiguous.Path = cell(1,length(mitro.Events.autoClass));
markingAnalysis.ambiguous.Phys = cell(1,length(mitro.Events.autoClass));
markingAnalysis.ambiguous.ArtCount = cell(1,length(mitro.Events.autoClass));
markingAnalysis.ambiguous.PathCount = cell(1,length(mitro.Events.autoClass));
markingAnalysis.ambiguous.PhysCount = cell(1,length(mitro.Events.autoClass));
markingAnalysis.ambiguous.Percent= cell(1,length(mitro.Events.autoClass));
%markingAnalysis.ambiguousSum= cell(1,length(mitro.Events.autoClass));
markingAnalysis.ambiguous.ArtTotal=0;
markingAnalysis.ambiguous.PathTotal=0;
markingAnalysis.ambiguous.PhysTotal=0;

% disagree information  (initiate fields)
markingAnalysis.ambiguous.Logic = cell(1,length(mitro.Events.autoClass));
markingAnalysis.ambiguous.Sum = cell(1,length(mitro.Events.autoClass));
markingAnalysis.ambiguous.Total=0;

% Label logic 
trueLabels = cell(1,length(mitro.Events.autoClass));
agreeLabels = cell(1,length(mitro.Events.autoClass));
markingAnalysis.agree.MarkerIdx = cell(1,length(mitro.Events.autoClass));
markingAnalysis.agree.MarkerLabel = cell(1,length(mitro.Events.autoClass));
markingAnalysis.ambiguous.MarkerIdx = cell(1,length(mitro.Events.autoClass));
markingAnalysis.ambiguous.MarkerLabel = cell(1,length(mitro.Events.autoClass));

len = cellfun(@(x) size(x,2),mitro.preproInfo.leadsInfo.channelsBipolar);
lead = 1;
for ch = 1: length(mitro.Events.autoClass)
      
    if ~isempty(mitro.Events.autoClass{1,ch})
        % agree initialization 
        markingAnalysis.agree.Logic{1,ch}=false(size(mitro.Events.autoClass{1,ch},1),1);
        markingAnalysis.agree.Art{1,ch}=false(size(mitro.Events.autoClass{1,ch},1),1);
        markingAnalysis.agree.Path{1,ch}=false(size(mitro.Events.autoClass{1,ch},1),1);
        markingAnalysis.agree.Phys{1,ch}=false(size(mitro.Events.autoClass{1,ch},1),1);
        % ambiguous initialization 
        markingAnalysis.ambiguous.Logic{1,ch}=false(size(mitro.Events.autoClass{1,ch},1),1);
        markingAnalysis.ambiguous.Art{1,ch}=false(size(mitro.Events.autoClass{1,ch},1),1);
        markingAnalysis.ambiguous.Path{1,ch}=false(size(mitro.Events.autoClass{1,ch},1),1);
        markingAnalysis.ambiguous.Phys{1,ch}=false(size(mitro.Events.autoClass{1,ch},1),1);
        
        %trueLabels{1,ch}=zeros(size(mitro.Events.autoClass{1,ch},1),1);
        agreeMarker=0;
        disagreeMarker=0;
        for nEvent = 1:size(mitro.Events.autoClass{1,ch},1)
            if mitro.Events.autoClass{1,ch}(nEvent,1) == bruzzone.Events.autoClass{1,ch}(nEvent,1)
                agreeMarker = agreeMarker+1;
                agreeLabels{1,ch}{nEvent,1} = 1;
                markingAnalysis.agree.MarkerIdx{1,ch}(agreeMarker,1) = mitro.Events.autoIdx{1,ch}(nEvent,1);
                markingAnalysis.agree.Logic{1,ch}(nEvent,1) = true;              
                if mitro.Events.autoClass{1,ch}(nEvent,1) == importance(1,1)
                    trueLabels{1,ch}{nEvent,1} = importance(1,1);
                    markingAnalysis.agree.MarkerLabel{1,ch}{agreeMarker,1} = importance(1,1);
                elseif mitro.Events.autoClass{1,ch}(nEvent,1) == importance(1,2) 
                    trueLabels{1,ch}{nEvent,1} = importance(1,2);
                    markingAnalysis.agree.MarkerLabel{1,ch}{agreeMarker,1} = importance(1,2);
                elseif mitro.Events.autoClass{1,ch}(nEvent,1) == importance(1,3) 
                    trueLabels{1,ch}{nEvent,1} = importance(1,3);
                    markingAnalysis.agree.MarkerLabel{1,ch}{agreeMarker,1} = importance(1,3);
                else
                    trueLabels{1,ch}{nEvent,1} = importance(1,3);
                    markingAnalysis.agree.MarkerLabel{1,ch}{agreeMarker,1} = importance(1,3);
                end
                
                if trueLabels{1,ch}{nEvent,1} ==1
                    markingAnalysis.agree.Art{1,ch}(nEvent,1) = true;
                elseif trueLabels{1,ch}{nEvent,1} ==2
                    markingAnalysis.agree.Path{1,ch}(nEvent,1) = true;
                elseif trueLabels{1,ch}{nEvent,1} ==3
                    markingAnalysis.agree.Phys{1,ch}(nEvent,1) = true; 
                end                  
                                    
            else
                disagreeMarker = disagreeMarker+1;
                agreeLabels{1,ch}{nEvent,1} = 0;
                % IMPORTANCE FOR TRUE LABEL BASED ON 'IMPORTANCE VECTOR                 
                markingAnalysis.ambiguous.Logic{1,ch}=true;
                markingAnalysis.ambiguous.MarkerIdx{1,ch}(disagreeMarker,1) = mitro.Events.autoIdx{1,ch}(nEvent,1);
                if mitro.Events.autoClass{1,ch}(nEvent,1) == importance(1,1) || bruzzone.Events.autoClass{1,ch}(nEvent,1) == importance(1,1)
                    markingAnalysis.ambiguous.Phys{1,ch}(nEvent,1) = true;
                    trueLabels{1,ch}{nEvent,1} = importance(1,1);
                elseif mitro.Events.autoClass{1,ch}(nEvent,1) == importance(1,2) || bruzzone.Events.autoClass{1,ch}(nEvent,1) == importance(1,2)
                    markingAnalysis.ambiguous.Path{1,ch}(nEvent,1) = true;
                    trueLabels{1,ch}{nEvent,1} = importance(1,2);
                elseif mitro.Events.autoClass{1,ch}(nEvent,1) == importance(1,3) || bruzzone.Events.autoClass{1,ch}(nEvent,1) == importance(1,3)
                    markingAnalysis.ambiguous.Art{1,ch}(nEvent,1) = true;
                    trueLabels{1,ch}{nEvent,1} = importance(1,3);
                else
                    trueLabels{1,ch}{nEvent,1} = importance(1,3);
                    markingAnalysis.ambiguous.Art{1,ch}{agreeMarker,1} = importance(1,3);
                end                
                markingAnalysis.ambiguous.MarkerLabel{1,ch}(disagreeMarker,1) =  mitro.Events.autoClass{1,ch}(nEvent,1);
                markingAnalysis.ambiguous.MarkerLabel{1,ch}(disagreeMarker,2) =  bruzzone.Events.autoClass{1,ch}(nEvent,1);
            end
        end
        %agree
        markingAnalysis.agree.Percent{1,ch} = sum(markingAnalysis.agree.Logic{1,ch}==true)/length(markingAnalysis.agree.Logic{1,ch});
        markingAnalysis.agree.Sum{1,ch} = sum(markingAnalysis.agree.Logic{1,ch}==true);       
        markingAnalysis.agree.ArtCount{1,ch} = sum(markingAnalysis.agree.Art{1,ch}==true);
        markingAnalysis.agree.PathCount{1,ch} = sum(markingAnalysis.agree.Path{1,ch}==true);
        markingAnalysis.agree.PhysCount{1,ch} = sum(markingAnalysis.agree.Phys{1,ch}==true);        
        markingAnalysis.agree.Total = markingAnalysis.agree.Total + markingAnalysis.agree.Sum{1,ch};
        markingAnalysis.agree.ArtTotal = markingAnalysis.agree.ArtTotal + markingAnalysis.agree.ArtCount{1,ch};
        markingAnalysis.agree.PathTotal = markingAnalysis.agree.PathTotal + markingAnalysis.agree.PathCount{1,ch};
        markingAnalysis.agree.PhysTotal = markingAnalysis.agree.PhysTotal + markingAnalysis.agree.PhysCount{1,ch};
        
        % ambiguous
        markingAnalysis.ambiguous.Percent{1,ch} = sum(markingAnalysis.ambiguous.Logic{1,ch}==true)/length(markingAnalysis.ambiguous.Logic{1,ch});
        markingAnalysis.ambiguous.ArtCount{1,ch} = sum(markingAnalysis.ambiguous.Art{1,ch} == true);
        markingAnalysis.ambiguous.PathCount{1,ch} = sum(markingAnalysis.ambiguous.Path{1,ch} == true);
        markingAnalysis.ambiguous.PhysCount{1,ch} = sum(markingAnalysis.ambiguous.Phys{1,ch} == true);
        markingAnalysis.ambiguous.ArtTotal = markingAnalysis.ambiguous.ArtTotal + markingAnalysis.ambiguous.ArtCount{1,ch};
        markingAnalysis.ambiguous.PathTotal = markingAnalysis.ambiguous.PathTotal + markingAnalysis.ambiguous.PathCount{1,ch};
        markingAnalysis.ambiguous.PhysTotal = markingAnalysis.ambiguous.PhysTotal + markingAnalysis.ambiguous.PhysCount{1,ch};
        
        % disagree
        markingAnalysis.ambiguous.Sum{1,ch} = sum(markingAnalysis.agree.Logic{1,ch}==false);
        markingAnalysis.ambiguous.Total = markingAnalysis.ambiguous.Total + markingAnalysis.ambiguous.Sum{1,ch};
    end
    
end
        