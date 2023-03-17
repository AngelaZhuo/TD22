% Do PSTH
clear
PVdirectory = "\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\D-struct";
addpath(genpath(PVdirectory))
Functions_directory = "\\zisvfs12\Home\yi.zhuo\Downloads\Master_GLM\Master_GLM\"; addpath(genpath(Functions_directory))
cd(Functions_directory)

load("Before.mat")
Matrices.Pupil.mouse
Exclude = [9:18,2,4,6,8];
idx = ones(size(Matrices.Pupil.matrix, 1), 1);
idx(Exclude) = 0; idx = logical(idx);
figure
Mirko(Matrices.Pupil.matrix(idx, :, :), Matrices.Pupil.trialMatrix(idx, :, :), Matrices.Pupil.events, "Diameter (a.u.)", 0, 0)


load("After.mat")
Matrices.Pupil.mouse
Exclude = [1:9,11,13,15];
idx = ones(size(Matrices.Pupil.matrix, 1), 1);
idx(Exclude) = 0; idx = logical(idx);
figure
Mirko(Matrices.Pupil.matrix(idx, :, :), Matrices.Pupil.trialMatrix(idx, :, :), Matrices.Pupil.events, "Diameter (a.u.)", 0, 0)


%% Make PSTH for individual animal

clear
PVdirectory = "\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\D-struct";
addpath(genpath(PVdirectory))
Functions_directory = "\\zisvfs12\Home\yi.zhuo\Downloads\Master_GLM\Master_GLM\"; addpath(genpath(Functions_directory))
cd(Functions_directory)

load("Before.mat")
Matrices.Pupil.mouse
for ms = 1:numel(Matrices.Pupil.mouse)
    idx = zeros(size(Matrices.Pupil.matrix, 1), 1);
    idx(ms) = 1;
    idx = logical (idx);
    f = figure;
    Mirko(Matrices.Pupil.matrix(idx, :, :), Matrices.Pupil.trialMatrix(idx, :, :), Matrices.Pupil.events, "Diameter (a.u.)", 0, 0)
    sgtitle([char(Matrices.Pupil.mouse(ms)),' Before']);
    exportgraphics(gcf,fullfile('\\zisvfs12\Home\yi.zhuo\Documents\Devaluation_Dig\plots\PSTH_EachAnimal\',[char(Matrices.Pupil.mouse(ms)),'_Before','.png']));
    close all
end

load("After.mat")
Matrices.Pupil.mouse
for ms = 1:numel(Matrices.Pupil.mouse)
    idx = zeros(size(Matrices.Pupil.matrix, 1), 1);
    idx(ms) = 1;
    idx = logical (idx);
    f = figure;
    Mirko(Matrices.Pupil.matrix(idx, :, :), Matrices.Pupil.trialMatrix(idx, :, :), Matrices.Pupil.events, "Diameter (a.u.)", 0, 0)
    sgtitle([char(Matrices.Pupil.mouse(ms)),' After']);
    exportgraphics(gcf,fullfile('\\zisvfs12\Home\yi.zhuo\Documents\Devaluation_Dig\plots\PSTH_EachAnimal\',[char(Matrices.Pupil.mouse(ms)),'_After','.png']));
    close all
end
