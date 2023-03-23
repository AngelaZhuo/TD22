%%Loop to create pupil PSTH

clear
PVdirectory = "\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\D-struct";
addpath(genpath(PVdirectory))
Functions_directory = "C:\GitHub\TD22\Analysis\Pupil\Master_GLM\"; addpath(genpath(Functions_directory))
cd(Functions_directory)
load("Events.mat")

for s = 24:34
    load("CleanSession_" + s + ".mat")
    clf
%     for m = 1:size(Matrices.Pupil.matrix,1)
            [WT_animal,Mutant_animal] = isMutant(Matrices.Pupil.mouse);
            M = Matrices.Pupil.matrix(Mutant_animal, :, :);
%             M = Matrices.Pupil.matrix(WT_animal, :, 1:50);
            Baseline = mean(M(:,1:Events(1)-1,:),2,"omitnan");
            M = M./Baseline;
%             M = zscore_xnan(M); %compute the z-score omiting the NaN values
            TM = Matrices.Pupil.trialMatrix(Mutant_animal, :, :); %TM(:,3,:) = 0;
%             TM = Matrices.Pupil.trialMatrix(WT_animal, :, 1:50); %TM(:,3,:) = 0;
            Mirko(M, TM, Matrices.Pupil.events, "Pupil diameter (a.u.)", 0, 0);
            sgtitle(['trace Mutant s ', num2str(s)])
            parsave_img("\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\plots\PSTH\All_trials\Pupil_trace\Cleaned\Individual_session", "trace_Mutant_s_" + s, 0, 1, 0)
            

%     Use Mirko with whole M
    % Save that image properly    
    %parsave_img("\\zisvfs12\home\Yi.Zhuo\Documents\GitHub\TD22\Analysis\Pupil\Master_GLM\Artifacts", "s_" + s + "_m_" + m, 1, 1, 1)
end


