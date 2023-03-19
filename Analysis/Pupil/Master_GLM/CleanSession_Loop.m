clear
PVdirectory = "\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\D-struct";
addpath(genpath(PVdirectory))
Functions_directory = "\\zisvfs12\Home\yi.zhuo\Documents\GitHub\TD22\Analysis\Pupil\Master_GLM\"; addpath(genpath(Functions_directory))
cd(Functions_directory)

for s = 1:6
    load("Session_" + s + ".mat")
    for m = 1:size(Matrices.Pupil.matrix,1)
        [Matrices.Pupil.matrix(m, :, :), ~] = CleanPupil_2023(Matrices.Pupil.matrix(m, :, :), Matrices.Pupil.trialMatrix(m, :, :), Matrices.Pupil.events, 4, 1);
        parsave_img("\\zisvfs12\home\Yi.Zhuo\Documents\GitHub\TD22\Analysis\Pupil\Master_GLM\Artifacts", "s_" + s + "_m_" + m, 1, 1, 1)
        sgtitle("Mouse " + Matrices.Pupil.mouse(m) + ", session " + s)
        close gcf
    end
    parsave("\\zisvfs12\Home\yi.zhuo\Documents\GitHub\TD22\Analysis\Pupil\Master_GLM\Sessions/CleanSession_" + num2str(s), Matrices)
end
