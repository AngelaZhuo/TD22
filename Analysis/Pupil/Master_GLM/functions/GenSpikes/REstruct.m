%% Restruct the PVstruct
function REstruct(PVstruct, TargetDirectory)
    for u = 1:size(PVstruct.spikes,2)
        PVstruct.clu_info(u).PVid = u;
        PVstruct.clu_info(u).mirko_counter = PVstruct.clu_info(u).sesh_counter;
        PVstruct.clu_info(u).sesh_counter = int64(PVstruct.clu_info(u).sesh_counter.*3);
    end
    PVbig = PVstruct; clear PVstruct
    %Check if the fields have changed
    PVfields = fields(PVbig); PVfields([2, 3, 6, 7, 8, 9]) = [];
    for fi = 1:numel(PVfields)
        PVstruct.(PVfields{fi}) = PVbig.(PVfields{fi});
    end
    
    for Si = [50, 100, 150]
        fitties = [PVbig.clu_info.trialNum];
        fitties = find(fitties == Si);
        PVstruct.spikes = PVbig.spikes(1, fitties);
        PVstruct.clu_info = PVbig.clu_info(1, fitties);
        PVstruct.TrialMatrix = PVbig.TrialMatrix(fitties,:,:);
        
        PVfields = fields(PVbig); PVfields([2, 3, 6, 7, 8]) = [];
        for fi = 1:numel(PVfields)
            PVsmall.(PVfields{fi}) = PVstruct.(PVfields{fi});
        end
        scount = [PVstruct.clu_info.sesh_counter]; 
        Sesh = unique(scount);
        
        for s = 1:numel(Sesh) % if Sesh(1) == 0
            Name = num2str(int64(Sesh(s))); 
            idx = find(scount == Sesh(s));
            PVsmall.spikes = PVstruct.spikes(1, idx); 
            PVsmall.clu_info = PVstruct.clu_info(1, idx);
            PVsmall.TrialMatrix = PVstruct.TrialMatrix(idx,:,:);
            save(TargetDirectory + "/PVsmall/PVsmall_" + Name, "PVsmall", "-v7.3");
            if PVsmall.clu_info(1).mirko_counter >= 24
                break
            end
        end
    end
end
