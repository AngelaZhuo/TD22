clear
PVdirectory = "\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\D-struct";
addpath(genpath(PVdirectory))
Functions_directory = "C:\GitHub\TD22\Analysis\Pupil\Master_GLM\"; addpath(genpath(Functions_directory))
cd(Functions_directory)

for s = 1:6
    load("CleanSession_" + s + ".mat")
    clf
%     for m = 1:size(Matrices.Pupil.matrix,1)
        if  s = 1:5
            WT_animal = [1,3,5,7,9,11,12,15,17];
            Mutant_animal = [2,4,6,8,10,13,14,16,18];
            M = Matrices.Pupil.matrix(WT_animal, :, :);
            M = zscore(M, 0, [2 3]);
            TM = Matrices.Pupil.trialMatrix(WT_animal, :, :);
            Mirko(M, TM, Matrices.Pupil.events, "Pupil diameter (a.u.)", 0, 0);
            parsave_img("\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\plots\PSTH\All_trials\z-score\Cleaned\Individual_session", "zscore_WT_RID_s_" + s, 0, 1, 0)
        end
        
        if  s = 6
            WT_animal = [2,4,6,8,10,12,14];
            Mutant_animal = [1,3,5,7,9,11,13,15];
            M = Matrices.Pupil.matrix(Mutant_animal, :, :);
            TM = Matrices.Pupil.trialMatrix(Mutant_animal, :, :);
            Mirko(M, TM, Matrices.Pupil.events, "Pupil diameter (a.u.)", 0, 0);
            parsave_img("\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\plots\PSTH\All_trials\Uncleaned\Individual_session", "Mutant_Extinction_", 0, 1, 0)
        end
%     Use Mirko with whole M
    % Save that image properly    
    %parsave_img("\\zisvfs12\home\Yi.Zhuo\Documents\GitHub\TD22\Analysis\Pupil\Master_GLM\Artifacts", "s_" + s + "_m_" + m, 1, 1, 1)
end


