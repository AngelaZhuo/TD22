%% Restruct the PVstruct
function REstruct_pupil(PVstruct, TargetDirectory)
    for u = 1:size(PVstruct.info,2)
        PVstruct.info(u).session_count = int64( PVstruct.info(u).session_count.*3);
    end
    scount = [PVstruct.info.session_count]; 
    Sesh = unique(scount); Sesh(Sesh > 72) = [];

    for s = 1:numel(Sesh) % if Sesh(1) == 0
        Name = num2str(int64(Sesh(s))); 
        idx = find(scount == Sesh(s));
        idx(idx > size(PVstruct.pupil,2)) = [];
        PVsmall.info = PVstruct.info(1, idx); 
        PVsmall.pupil = PVstruct.pupil(1, idx); 
        PVsmall.events = PVstruct.events(1, idx);
        save(TargetDirectory + "/PVsmall/PVsmall_" + Name, "PVsmall", "-v7.3");
    end
end
