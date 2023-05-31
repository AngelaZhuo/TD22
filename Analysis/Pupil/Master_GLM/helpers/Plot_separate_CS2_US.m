% Load your pupil data matrix M and its trial matrix TM;
clear
load("CleanSession_34.mat")
load("Events.mat")
figure


for division = 1:2
    clf
    tiledlayout(3,3)
    [WT_idx,Mutant_idx] = isMutant(Matrices.Pupil.mouse);
    if division == 1
        mouse = WT_idx;
        type = "WT";
    elseif division == 2
        mouse = Mutant_idx;
        type = "Mutant";
    end
    
    for ia = 1:numel(mouse)
        M = Matrices.Pupil.matrix(mouse(ia), :, :);
        TM = Matrices.Pupil.trialMatrix(mouse(ia), :, :);
        %TM(:,3,:) = 0 %if the session is 34 (extinction) 

        % CS2
        BL_US = mean(M(:, Events(4)-5:Events(4)-1, :), 2);
        M_ = M ./ BL_US;
        M_ = zscore_xnan(M_); %compute the z-score omiting the NaN values
        nexttile
        Mirko(M_, TM, Events, "zscore", 0, 0)
        xlim([41, 72])
        ylim([-.5, 1])
        title("m = " + Matrices.Pupil.mouse(mouse(ia)))
    end
    sgtitle("S = 34 " + type);
    parsave_img("\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\plots\PSTH\CS2_9tiles", "s34_" + type, 0, 1, 0)
end
    

for division = 1:2
    clf
    tiledlayout(3,3)
    [WT_idx,Mutant_idx] = isMutant(Matrices.Pupil.mouse);
    if division == 1
        mouse = WT_idx;
        type = "WT";
    elseif division == 2
        mouse = Mutant_idx;
        type = "Mutant";
    end
    
    for ia = 1:numel(mouse)
        M = Matrices.Pupil.matrix(mouse(ia), :, :);
        TM = Matrices.Pupil.trialMatrix(mouse(ia), :, :);
         %TM(:,3,:) = 0 %if the session is 34 (extinction) 

        % US
        BL_US = mean(M(:, Events(6)-5:Events(6)-1, :), 2);
        M_ = M ./ BL_US;
        M_ = zscore_xnan(M_); %compute the z-score omiting the NaN values
        nexttile
        Mirko(M_, TM, Events, "zscore", 0, 0)
        xlim([81, 171])
        ylim([-1, 2])
        title("m = " + Matrices.Pupil.mouse(mouse(ia)))
    end
    sgtitle("S = 34 " + type);
    parsave_img("\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\plots\PSTH\US_9tiles", "s34_" + type, 0, 1, 0)
end
