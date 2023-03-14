clear

load('\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\D-struct\d_devaluation.mat');

session_index = find(~cellfun(@isempty, {d.pupil.raw_trace},'UniformOutput',1));

for ses = 1:numel(session_index)
    Intan_Video_TimeDiff = d.info(session_index(ses)).LED_on_trigger_intan - d.info(session_index(ses)).LED_on_trigger_camera;
    Intan_Video_FrameDiff = round(Intan_Video_TimeDiff.*10);
    
    % add nans to beginning of video to align to intan
    d.pupil(session_index(ses)).aligned_trace = cat(1, NaN(Intan_Video_FrameDiff,1), d.pupil(session_index(ses)).raw_trace);   
end


save('\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\D-struct\d_devaluation.mat','d');
