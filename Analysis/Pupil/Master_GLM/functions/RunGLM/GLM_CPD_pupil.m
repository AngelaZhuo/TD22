function Matrices = GLM_CPD_pupil(Matrices, Events, Regions, nboot, Types)
    Bootstrap_K_only;
    Ranges = [[1, Events(3)-2]; [Events(4)-11, Events(6)-2]; [Events(6), Events(6) + 85]];
    for teil = 1:numel(Regions)
        if ~isempty(Matrices.(Regions{teil}).trialMatrix)
            "Running CPD on " + Regions{teil} + "[" + num2str(size(Matrices.(Regions{teil}).trialMatrix, 1)) + "]"
            M =  Matrices.(Regions{teil}).matrix; 
            TrialMatrix =  Matrices.(Regions{teil}).trialMatrix; 
            Jitter = Matrices.(Regions{teil}).jitter;
            Neurons = size(M,1);

            for neur = 1:Neurons
                TM = TrialMatrix(neur,:,:); 
                keep = ~isnan(squeeze(TM(1,1,:))); TM = TM(:,:,keep);
                Matrix = M(neur, :, :); Matrix = Matrix(:, :, keep);
                DM = GenXD_ort(TM, Types, Jitter(neur, keep)', Ranges);
                for ty = 1:numel(Types)
                    X = DM.(Types(ty)).DMatrix;
                    R = DM.(Types(ty)).Range; 
                    Design = DM.(Types(ty)).Design;
                    Unite = DM.(Types(ty)).Unite;
                    Resid = NaN(2, R(2)-R(1)+1); CPD = NaN(numel(Design) + size(Unite,1), R(2)-R(1)+1);
                    Xw = X; Yw = permute(Matrix(:, R(1):R(2), :), [3,2,1]); Rs = size(Xw, 2); Ts = size(Xw,1); Bs = size(Yw,2);
                    B = NaN(Rs, Bs); residual = NaN(1, Bs);
                    for bin = 1:Bs
                        Yin = Yw(:,bin);
                        if all(isnan(Yin)); residual(1, bin) = NaN; B(:, bin) = NaN; continue; end
                        Xin = Xw;
                        Yin = Yin(~isnan(Yin));
                        Xin = Xin(~isnan(Yin), :);
                        [smallB, smallR] = OLS(Xin, Yin, 1);
                        B(:, bin) = smallB;
                        residual(1, bin) = sum(smallR.^2, "omitnan");
                    end
                    Results.("unit_" + num2str(neur)).(Types(ty)).Betas = B;
                    Results.("unit_" + num2str(neur)).(Types(ty)).Resid = residual;
                    Resid(1, :) = residual;
                    % Incompletes:
                    for reg = 1:numel(Design)
                        Xw = X(:, setdiff(1:end,reg+1)); Yw = permute(Matrix(:, R(1):R(2), :), [3,2,1]); Rs = size(Xw, 2); Ts = size(Xw,1); Bs = size(Yw,2);
                        B = NaN(Rs, Bs); residual = NaN(1, Bs);
                        for bin = 1:Bs
                            Yin = Yw(:,bin);
                            if all(isnan(Yin)); residual(1, bin) = NaN; B(:, bin) = NaN; continue; end
                            Xin = Xw;
                            Yin = Yin(~isnan(Yin));
                            Xin = Xin(~isnan(Yin), :);
                            [smallB, smallR] = OLS(Xin, Yin, 1);
                            B(:, bin) = smallB;
                            residual(1, bin) = sum(smallR.^2, "omitnan");
                        end
                        Resid(2, :) = residual;
                        CPD(reg, :) = (Resid(2, :) - Resid(1, :))./Resid(2, :);
                    end
                    for uni = 1:size(Unite,1)
                        REG = Unite{uni};
                        Xw = X(:, setdiff(1:end,REG+1)); Yw = permute(Matrix(:, R(1):R(2), :), [3,2,1]); Rs = size(Xw, 2); Ts = size(Xw,1); Bs = size(Yw,2);
                        B = NaN(Rs, Bs); residual = NaN(1, Bs);
                        for bin = 1:Bs
                            Yin = Yw(:,bin);
                            if all(isnan(Yin)); residual(1, bin) = NaN; B(:, bin) = NaN; continue; end
                            Xin = Xw;
                            Yin = Yin(~isnan(Yin));
                            Xin = Xin(~isnan(Yin), :);
                            [smallB, smallR] = OLS(Xin, Yin, 1);
                            B(:, bin) = smallB;
                            residual(1, bin) = sum(smallR.^2, "omitnan");
                        end
                        Resid(2, :) = residual;
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
                    DM = GenXD_ort(TM, Types, Jitter(:, keep)', Ranges);
                    Trials = sum(keep);
                    if Trials == 50; K = K50; Batches = Batches50; elseif Trials == 100; K = K100; Batches = Batches100;
                    elseif Trials == 150; K = K150; Batches = Batches150; elseif Trials == 145; K = K45; Batches = Batches45;end
                    BstIndex = []; for i = K(bst, :); BstIndex = cat(2, BstIndex, Batches(i, 1):Batches(i, 2)); end
                    for ty = 1:numel(Types)
                        X = DM.(Types(ty)).DMatrix;
                        R = DM.(Types(ty)).Range; 
                        Design = DM.(Types(ty)).Design;
                        Unite = DM.(Types(ty)).Unite;
                        Resid = NaN(2, R(2)-R(1)+1); CPD = NaN(numel(Design) + size(Unite,1), R(2)-R(1)+1);
                        Xw = X; Yw = permute(Matrix(:, R(1):R(2), :), [3,2,1]); Rs = size(Xw, 2); Ts = size(Xw,1); Bs = size(Yw,2);
                        B = NaN(Rs, Bs); residual = NaN(1, Bs);
                        for bin = 1:Bs
                            Yin = Yw(:,bin);
                            if all(isnan(Yin)); residual(1, bin) = NaN; B(:, bin) = NaN; continue; end
                            Outliers = sum(isnan(Yin));
                            BIin = BstIndex;
                            for ol = 1:Outliers
                                BIin(BIin == Trials - ol + 1) = [];
                            end
                            Yin = Yin(~isnan(Yin));
                            Xin = Xw(BIin, :);
                            [smallB, smallR] = OLS(Xin, Yin, 1);
                            B(:, bin) = smallB;
                            residual(1, bin) = sum(smallR.^2, "omitnan");
                        end
                        Resid(1, :) = residual;
                        for reg = 1:numel(Design)
                            Xw = X(:, setdiff(1:end,reg+1)); Yw = permute(Matrix(:, R(1):R(2), :), [3,2,1]); Rs = size(Xw, 2); Ts = size(Xw,1); Bs = size(Yw,2);
                            B = NaN(Rs, Bs); residual = NaN(1, Bs);
                            for bin = 1:Bs
                                Yin = Yw(:,bin);
                                if all(isnan(Yin)); residual(1, bin) = NaN; B(:, bin) = NaN; continue; end
                                Outliers = sum(isnan(Yin));
                                BIin = BstIndex;
                                for ol = 1:Outliers
                                    BIin(BIin == Trials - ol + 1) = [];
                                end
                                Yin = Yin(~isnan(Yin));
                                Xin = Xw(BIin, :);
                                [smallB, smallR] = OLS(Xin, Yin, 1);
                                B(:, bin) = smallB;
                                residual(1, bin) = sum(smallR.^2, "omitnan");
                            end                        
                            Resid(2, :) = residual;
                            CPD(reg, :) = (Resid(2, :) - Resid(1, :))./Resid(2, :);
                        end
                        for uni = 1:size(Unite,1)
                            REG = Unite{uni};
                            Xw = X(:, setdiff(1:end,REG+1)); Yw = permute(Matrix(:, R(1):R(2), :), [3,2,1]); Rs = size(Xw, 2); Ts = size(Xw,1); Bs = size(Yw,2);
                            B = NaN(Rs, Bs); residual = NaN(1, Bs);
                            for bin = 1:Bs
                                Yin = Yw(:,bin);
                                if all(isnan(Yin)); residual(1, bin) = NaN; B(:, bin) = NaN; continue; end
                                Outliers = sum(isnan(Yin));
                                BIin = BstIndex;
                                for ol = 1:Outliers
                                    BIin(BIin == Trials - ol + 1) = [];
                                end
                                Yin = Yin(~isnan(Yin));
                                Xin = Xw(BIin, :);
                                [smallB, smallR] = OLS(Xin, Yin, 1);
                                B(:, bin) = smallB;
                                residual(1, bin) = sum(smallR.^2, "omitnan");
                            end                        
                            Resid(2, :) = residual;
                            CPD(uni + numel(Design), :) = (Resid(2, :) - Resid(1, :))./Resid(2, :);
                        end
                        Results.("unit_" + num2str(neur)).(Types(ty)).pVal = Results.("unit_" + num2str(neur)).(Types(ty)).pVal + (Results.("unit_" + num2str(neur)).(Types(ty)).CPD < CPD); 
                        RUN.("unit_" + num2str(neur)).(Types(ty)).CPD = CPD;
%                         if bst < 10
%                             BOOT.("unit_" + num2str(neur)).(Types(ty)).CPD = cat(3, BOOT.("unit_" + num2str(neur)).(Types(ty)).CPD, CPD);
%                         end
                    end      
                end
                for ty = 1:numel(Types)
                    RunAvg = []; %BstAvg = [];
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
                sigU = zeros(size(Population.(Types(ty)).pVal));
                for neur = 1:Neurons
                    Results.("unit_" + num2str(neur)).(Types(ty)).pVal = Results.("unit_" + num2str(neur)).(Types(ty)).pVal./nboot;
                    Results.("unit_" + num2str(neur)).(Types(ty)).pVal(isnan(Results.("unit_" + num2str(neur)).(Types(ty)).CPD)) = NaN;
                    sigU = sigU + (Results.("unit_" + num2str(neur)).(Types(ty)).pVal < 0.05);
                end
                Population.(Types(ty)).pVal = Population.(Types(ty)).pVal./nboot;
                Population.(Types(ty)).Range = DM.(Types(ty)).Range;
                Population.(Types(ty)).Design = DM.(Types(ty)).Design;
                Population.(Types(ty)).vif = vif(DM.(Types(ty)).DMatrix(:, 2:end));
                Population.(Types(ty)).Labels = cat(2,DM.(Types(ty)).Design, DM.(Types(ty)).UniteName);
                Population.(Types(ty)).United = DM.(Types(ty)).Unite;
                Population.(Types(ty)).sigU = sigU;
                Population.(Types(ty)).nboot = nboot;
            end
            Matrices.(Regions{teil}).Population = Population;
            Matrices.(Regions{teil}).SingleUnit = Results;
            Results = rmfield(Results, fields(Results));
            Population = rmfield(Population, fields(Population));
%             clear Results Population
        end
    end
end
    