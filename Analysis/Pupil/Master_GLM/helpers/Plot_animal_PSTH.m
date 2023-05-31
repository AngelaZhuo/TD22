clear
Functions_directory = "\\zisvfs12\Home\yi.zhuo\Documents\GitHub\TD22\Analysis\Pupil\Master_GLM"; addpath(genpath(Functions_directory))
cd(Functions_directory)
load("thr0.99_CleanSession_33.mat")
load("Events.mat")

Mice = Matrices.Pupil.mouse;
WT_morning = [];
    for im = 1:size(Mice,1)
        mouse_num = str2double(Mice{im}(2:end));
         if mod(mouse_num, 2) ~= 0 && ismember(im, 1:8)     
             %WT = mod(mouse_num, 2) ~= 0
             %Mutant = mod(mouse_num,2) == 0
            WT_morning(end+1) = im;
         end 
    end
    
for x = 1:size(WT_morning,2)
    figure
%     tiledlayout(2,1)
%     for epoch = 1:2
%         if epoch == 1; Trials = 1:50; elseif epoch == 2; Trials = 101:150; end
            
                    M = Matrices.Pupil.matrix(WT_morning(x), :, :);
                    Baseline = mean(M(:,1:Events(1)-1,:),2,"omitnan");
                    M = M./Baseline;
                    M = zscore_xnan(M); %compute the z-score omiting the NaN values
                    TM = Matrices.Pupil.trialMatrix(WT_morning(x), :, :);
                    nexttile
                    Mirko(M, TM, Matrices.Pupil.events, "zscore", 0, 0);
                    title("S = 33" + ", m = " + Matrices.Pupil.mouse(WT_morning(x)))
                    sgtitle(['S = 33, WT_morning',", m = " + Matrices.Pupil.mouse(WT_morning(x))],'Interpreter','none')
                    parsave_img("\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\plots\PSTH\z-score\Cleaned\thr0.99_animal", "s33_WT_morning_" + Matrices.Pupil.mouse(WT_morning(x)), 0, 1, 0)
    end



% figure
% M = Matrices.Pupil.matrix(WT_morning, :, :);
% Baseline = mean(M(:,1:Events(1)-1,:),2,"omitnan");
% M = M./Baseline;
% M = zscore_xnan(M); %compute the z-score omiting the NaN values
% TM = Matrices.Pupil.trialMatrix(WT_morning, :, :); %
% nexttile
% Mirko(M, TM, Matrices.Pupil.events, "zscore", 0, 0);
% title("S = 27")
% sgtitle(['S = 27, WT_afternoon'],'Interpreter','none')
% parsave_img("\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\plots\PSTH\z-score\Cleaned\thr0.99_session", "s27_WT_afternoon", 0, 1, 0)



