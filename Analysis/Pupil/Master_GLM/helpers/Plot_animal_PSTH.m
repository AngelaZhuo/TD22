clear
Functions_directory = "C:\GitHub\TD22\Analysis\Pupil\Master_GLM\"; addpath(genpath(Functions_directory))
cd(Functions_directory)
load("CleanSession_26.mat")
load("Events.mat")

Mice = Matrices.Pupil.mouse;
WT_morning = [];
    for im = 1:size(Mice,1)
        mouse_num = str2double(Mice{im}(2:end));
         if mod(mouse_num, 2) ~= 0 && ismember(im, 1:8)
            WT_morning(end+1) = im;
         end 
    end
    
for x = 1:size(WT_morning,2)
    figure
    tiledlayout(2,1)
    for epoch = 1:2
        if epoch == 1; Trials = 1:50; elseif epoch == 2; Trials = 101:150; end
            
                    M = Matrices.Pupil.matrix(WT_morning(x), :, Trials);
                    Baseline = mean(M(:,1:Events(1)-1,:),2,"omitnan");
                    M = M./Baseline;
                    M = zscore_xnan(M); %compute the z-score omiting the NaN values
                    TM = Matrices.Pupil.trialMatrix(WT_morning(x), :, Trials); %
                    nexttile
                    Mirko(M, TM, Matrices.Pupil.events, "zscore", 0, 0);
                    title("S = 26" + ", epoch = " + epoch + ", m = " + Matrices.Pupil.mouse(WT_morning(x)))
                    sgtitle(['S = 26, WT_morning',", m = " + Matrices.Pupil.mouse(WT_morning(x))],'Interpreter','none')
                    parsave_img("\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\plots\PSTH\z-score\Cleaned\Individual_animal", "s26_WT_morning_" + Matrices.Pupil.mouse(WT_morning(x)), 0, 1, 0)
    end
end

% Devalued_TM = Matrices.Pupil.trialMatrix(WT_devalued,:,:);
% 
% Num_6R_pairs = 0;
% for tr = 1:150
%     Num_6R_pairs  = Num_6R_pairs +nnz(Devalued_TM(:,1,tr)==6 & Devalued_TM(:,3,tr)==1);
% end
% 
% Num_5R_pairs = 0;
% for tr = 1:150
%     Num_5R_pairs  = Num_5R_pairs +nnz(Devalued_TM(:,1,tr)==5 & Devalued_TM(:,3,tr)==1);
% end


