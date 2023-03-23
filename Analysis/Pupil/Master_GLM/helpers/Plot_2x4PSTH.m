%% Compute 2x4 plot layout

control_group = 1:8;    %all the "morning" animals 
devalued_group = 9:20;  %all the "afternoon" animals
wild_group = 1:2:20;
mutant_group = 2:2:20;

            
for Type = 1:4
    figure
    tiledlayout(2,4)
    for epoch = 1:2
        if epoch == 1; Trials = 1:50; elseif epoch == 2; Trials = 101:150; end
        for s = [28, 29, 33, 34]
                load("CleanSession_" + s + ".mat")
                
                % Identity according to groups:
                Mice = Matrices.Pupil.mouse;
                Mice = replace(Mice, "y", "");
                Mice = str2double(Mice);
                if Type == 1 % Wild control
                    Identity = ismember(Mice, control_group) & ismember(Mice, wild_group);
                    Name = "WT_Control";
                elseif Type == 2 % Wild pain
                    Identity = ismember(Mice, devalued_group) & ismember(Mice, wild_group);
                    Name = "WT_Devalued";
                elseif Type == 3 % Mutant control
                    Identity = ismember(Mice, control_group) & ismember(Mice, mutant_group);
                    Name = "Mutant_Control";
                elseif Type == 4 % Mutant pain
                    Identity = ismember(Mice, devalued_group) & ismember(Mice, mutant_group);
                    Name = "Mutant_Devalued";
                end
                M = Matrices.Pupil.matrix(Identity, :, Trials);
                Baseline = mean(M(:,1:Events(1)-1,:),2,"omitnan");
                M = M./Baseline;
                M = zscore_xnan(M); %compute the z-score omiting the NaN values
                TM = Matrices.Pupil.trialMatrix(Identity, :, Trials); %
                if s == 34; TM(:,3,:) = 0; end
                nexttile
                Mirko(M, TM, Matrices.Pupil.events, "Pupil diameter (a.u.)", 0, 0);
                title("S = " +  s + ", epoch = " + epoch + ", n = " + sum(Identity) + " mice")
        end
    end
    sgtitle("Type: " + Name)
end