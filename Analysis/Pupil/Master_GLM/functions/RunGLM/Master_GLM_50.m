function Matrices = Master_GLM_50(Matrices, Events, Regions, nboot, Types)
    Bootstrap_K_only; keep = 1:50;
    Ranges = [[1, Events(3)]; [Events(3)-2, Events(6)]; [Events(6)-2, Events(6) + 60]];
    for teil = 1:numel(Regions)
        if isempty(Matrices.(Regions{teil}).trialMatrix)
            Regions{teil} + " has no units"
        else
            "Running CPD on " + Regions{teil} + "[" + num2str(size(Matrices.(Regions{teil}).trialMatrix, 1)) + "]"
            M =  Matrices.(Regions{teil}).matrix.^0.5; 
            TrialMatrix =  Matrices.(Regions{teil}).trialMatrix; 
            Jitter = Matrices.(Regions{teil}).jitter;
            Neurons = size(M,1);

            for neur = 1:Neurons
                TM = TrialMatrix(neur,:,:); TM = TM(:,:,keep);
                Matrix = M(neur, :, :); Matrix = Matrix(:, :, keep);
                DM = GenXD_Master(TM, Types, Jitter(neur, keep)', Ranges);
                for ty = 1:numel(Types)
                    X = DM.(Types(ty)).DMatrix;
                    R = DM.(Types(ty)).Range; 
                    Design = DM.(Types(ty)).Design;
                    Unite = DM.(Types(ty)).Unite;
                    Resid = NaN(2, R(2)-R(1)+1); CPD = NaN(numel(Design) + size(Unite,1), R(2)-R(1)+1);
                    [B, residual] = OLS(X,permute(Matrix(:, R(1):R(2), :), [3,2,1]), 1);
                    Results.("unit_" + num2str(neur)).(Types(ty)).Betas = B';
                    Results.("unit_" + num2str(neur)).(Types(ty)).Resid = sum(residual.^2, 1);
                    Resid(1, :) = sum(residual.^2, 1);
                    % Incompletes:
                    for reg = 1:numel(Design)
                        [~, residual] = OLS(X(:, setdiff(1:end,reg+1)),permute(Matrix(:, R(1):R(2), :), [3,2,1]), 1);
                        Resid(2, :) = sum(residual.^2, 1);
                        CPD(reg, :) = (Resid(2, :) - Resid(1, :))./Resid(2, :);
                    end
                    for uni = 1:numel(Unite)
                        REG = Unite{uni};
                        [~, residual] = OLS(X(:, setdiff(1:end,REG+1)),permute(Matrix(:, R(1):R(2), :), [3,2,1]), 1);
                        Resid(2, :) = sum(residual.^2, 1);
                        CPD(uni + numel(Design), :) = (Resid(2, :) - Resid(1, :))./Resid(2, :);
                    end
                    Results.("unit_" + num2str(neur)).(Types(ty)).CPD = CPD;
                    Results.("unit_" + num2str(neur)).(Types(ty)).pVal = zeros(size(CPD));
                end
            end
            for ty = 1:numel(Types)
                CPD = [];
                for neur = 1:Neurons
                    CPD = cat(3, CPD, Results.("unit_" + num2str(neur)).(Types(ty)).CPD);
                end
                Population.(Types(ty)).CPD = mean(CPD, 3, 'omitnan'); % Omitnan because we might have Y = zeros and thus Resid = 0 resulting in NaN CPD values.
                Population.(Types(ty)).pVal = zeros(1, size(CPD,2));
            end
%             for neur = 1:Neurons
%                 for ty = 1:numel(Types)
%                     BOOT.("unit_" + num2str(neur)).(Types(ty)).CPD = [];
%                 end
%             end
            for bst = 1:nboot
                for neur = 1:Neurons
                    TM = TrialMatrix(neur,:,:); TM = TM(:,:,keep);
                    Matrix = M(neur, :, :); Matrix = Matrix(:, :, keep);
                    DM = GenXD_Master(TM, Types, Jitter(neur, keep)', Ranges);
                    Trials = 50;
                    if Trials == 50; K = K50; Batches = Batches50; elseif Trials == 100; K = K100; Batches = Batches100;elseif Trials == 150; K = K150; Batches = Batches150;end
                    BstIndex = []; for i = K(bst, :); BstIndex = cat(2, BstIndex, Batches(i, 1):Batches(i, 2)); end
                    for ty = 1:numel(Types)
                        X = DM.(Types(ty)).DMatrix;
                        R = DM.(Types(ty)).Range; 
                        Design = DM.(Types(ty)).Design;
                        Unite = DM.(Types(ty)).Unite;
                        Resid = NaN(2, R(2)-R(1)+1); CPD = NaN(numel(Design) + size(Unite,1), R(2)-R(1)+1);
                        [~, residual] = OLS(X,permute(Matrix(:, R(1):R(2), BstIndex), [3,2,1]), 1);
                        Resid(1, :) = sum(residual.^2, 1);
                        for reg = 1:numel(Design)
                            [~, residual] = OLS(X(:, setdiff(1:end,reg+1)),permute(Matrix(:, R(1):R(2), BstIndex), [3,2,1]), 1);
                            Resid(2, :) = sum(residual.^2, 1);
                            CPD(reg, :) = (Resid(2, :) - Resid(1, :))./Resid(2, :);
                        end
                        for uni = 1:numel(Unite)
                            REG = Unite{uni};
                            [~, residual] = OLS(X(:, setdiff(1:end,REG+1)),permute(Matrix(:, R(1):R(2), BstIndex), [3,2,1]), 1);
                            Resid(2, :) = sum(residual.^2, 1);
                            CPD(uni + numel(Design), :) = (Resid(2, :) - Resid(1, :))./Resid(2, :);
                        end
                        Results.("unit_" + num2str(neur)).(Types(ty)).pVal = Results.("unit_" + num2str(neur)).(Types(ty)).pVal + (Results.("unit_" + num2str(neur)).(Types(ty)).CPD < CPD); 
                        RUN.("unit_" + num2str(neur)).(Types(ty)).CPD = CPD;
%                         if bst < 300
%                             BOOT.("unit_" + num2str(neur)).(Types(ty)).CPD = cat(3, BOOT.("unit_" + num2str(neur)).(Types(ty)).CPD, CPD);
%                         end
                    end      
                end
                for ty = 1:numel(Types)
                    RunAvg = []; % BstAvg = [];
                    for neur = 1:Neurons
                        RunAvg = cat(3, RunAvg, RUN.("unit_" + num2str(neur)).(Types(ty)).CPD);
%                         BstAvg = cat(4, BstAvg, BOOT.("unit_" + num2str(neur)).(Types(ty)).CPD);
                    end
                    RunAvg = mean(RunAvg, 3, "omitnan");
                    Population.(Types(ty)).pVal = Population.(Types(ty)).pVal + (Population.(Types(ty)).CPD < RunAvg);
%                     Population.(Types(ty)).BCPDmean = mean(BstAvg, [3, 4], "omitnan"); 
%                     Population.(Types(ty)).BCPDstd = std(mean(BstAvg, 3, "omitnan"), 0, 4);
                end
            end
            for ty = 1:numel(Types)
                Population.(Types(ty)).pVal = Population.(Types(ty)).pVal./nboot;
                Population.(Types(ty)).Range = DM.(Types(ty)).Range;
                Population.(Types(ty)).Design = DM.(Types(ty)).Design;
                Population.(Types(ty)).vif = vif(DM.(Types(ty)).DMatrix(:, 2:end));
                Population.(Types(ty)).Labels = cat(2,DM.(Types(ty)).Design, DM.(Types(ty)).UniteName);
                Population.(Types(ty)).United = DM.(Types(ty)).Unite;
                Population.(Types(ty)).nboot = nboot;
            end
            Matrices.(Regions{teil}).Population = Population;
            Matrices.(Regions{teil}).SingleUnit = Results;
            clear Results Population
        end
    end
end
    