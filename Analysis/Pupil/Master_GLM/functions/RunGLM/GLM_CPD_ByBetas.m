function Matrices = GLM_CPD_ByBetas(Matrices, Events, Regions, nboot, Types)
    Bootstrap_K_only;
    Ranges = [[1, Events(3)-2]; [Events(4)-11, Events(6)-2]; [Events(6), Events(6) + 85]];
    for teil = 1:numel(Regions)
        if isempty(Matrices.(Regions{teil}).trialMatrix)
            Regions{teil} + " has no units"
            continue
        else
            "Running CPD on " + Regions{teil} + "[" + num2str(size(Matrices.(Regions{teil}).trialMatrix, 1)) + "]"
        end
        M =  Matrices.(Regions{teil}).matrix; 
        TrialMatrix =  Matrices.(Regions{teil}).trialMatrix; 
        Jitter = Matrices.(Regions{teil}).jitter;
        Neurons = size(M,1);
        for ty = 1:numel(Types)
            Range = Matrices.(Regions{teil}).Population.(Types(ty)).Range(1):Matrices.(Regions{teil}).Population.(Types(ty)).Range(2);
            Regs = size(Matrices.(Regions{teil}).SingleUnit.("unit_" + num2str(1)).(Types(ty)).Betas, 2) - 1;
            CPDplus = NaN(Regs, numel(Range), Neurons);
            CPDminus = NaN(Regs, numel(Range), Neurons);
            Positive.(Types(ty)).index = NaN(Regs, numel(Range), Neurons);
            Negative.(Types(ty)).index = NaN(Regs, numel(Range), Neurons);
            for neur = 1:Neurons
                CPD = Matrices.(Regions{teil}).SingleUnit.("unit_" + num2str(neur)).(Types(ty)).CPD(1:Regs,:);
                sign = Matrices.(Regions{teil}).BLcompare(neur, Range);
                betas = Matrices.(Regions{teil}).SingleUnit.("unit_" + num2str(neur)).(Types(ty)).Betas(:, 2:end)';
                Positive.(Types(ty)).index(:, :, neur) = betas.*sign > 0;
                Negative.(Types(ty)).index(:, :, neur) = betas.*~sign < 0;
                CPDplus(:, :, neur) = CPD .* Positive.(Types(ty)).index(:, :, neur);
                CPDminus(:, :, neur) = CPD .* Negative.(Types(ty)).index(:, :, neur);
            end
            CPDplus(CPDplus == 0) = NaN; CPDminus(CPDminus == 0) = NaN;
            Positive.(Types(ty)).index(Positive.(Types(ty)).index == 0) = NaN;
            Negative.(Types(ty)).index(Negative.(Types(ty)).index == 0) = NaN;
            ByBeta.(Types(ty)).CPDplus(:, :, 1) = mean(CPDplus, 3, "omitnan");
            ByBeta.(Types(ty)).CPDminus(:, :, 1) = mean(CPDminus, 3, "omitnan");
            for r = 1:Regs
                ByBeta.(Types(ty)).CPDplus(r, :, 2) = StdError(squeeze(CPDplus(r, :, :))');
                ByBeta.(Types(ty)).CPDplus(r, :, 3) = sum(~isnan(squeeze(CPDplus(r, :, :))'),1);
                ByBeta.(Types(ty)).CPDminus(r, :, 2) = StdError(squeeze(CPDminus(r, :, :))');
                ByBeta.(Types(ty)).CPDminus(r, :, 3) = sum(~isnan(squeeze(CPDminus(r, :, :))'),1);
            end
            ByBeta.(Types(ty)).CPDplus(:, :, 4) = 0; ByBeta.(Types(ty)).CPDminus(:, :, 4) = 0;
        end
        for bst = 1:nboot
            RUN = [];
            for neur = 1:Neurons
                TM = TrialMatrix(neur,:,:); keep = ~isnan(squeeze(TM(1,1,:))); TM = TM(:,:,keep);
                Matrix = M(neur, :, :); keep = ~isnan(squeeze(Matrix(1, 1, :))); Matrix = Matrix(:, :, keep);
                DM = GenXD(TM, Types, Jitter(neur, keep)', Ranges);
                Trials = sum(keep);
                if Trials == 50; K = K50; Batches = Batches50; elseif Trials == 100; K = K100; Batches = Batches100;elseif Trials == 150; K = K150; Batches = Batches150;end
                BstIndex = []; for i = K(bst, :); BstIndex = cat(2, BstIndex, Batches(i, 1):Batches(i, 2)); end
                for ty = 1:numel(Types)
                    X = DM.(Types(ty)).DMatrix;
                    R = DM.(Types(ty)).Range; 
                    Design = DM.(Types(ty)).Design;
                    Resid = NaN(2, R(2)-R(1)+1); CPD = NaN(numel(Design), R(2)-R(1)+1);
                    [~, residual] = OLS(X,permute(Matrix(:, R(1):R(2), BstIndex), [3,2,1]), 1);
                    Resid(1, :) = sum(residual.^2, 1);
                    for reg = 1:numel(Design)
                        [~, residual] = OLS(X(:, setdiff(1:end,reg+1)),permute(Matrix(:, R(1):R(2), BstIndex), [3,2,1]), 1);
                        Resid(2, :) = sum(residual.^2, 1);
                        CPD(reg, :) = (Resid(2, :) - Resid(1, :))./Resid(2, :);
                    end
                    RUN.(Types(ty)).CPD(:, :, neur) = CPD;
                end      
            end
            for ty = 1:numel(Types)
                CPD = RUN.(Types(ty)).CPD;
                PosAvg = mean(CPD .* Positive.(Types(ty)).index, 3, "omitnan"); 
                NegAvg = mean(CPD .* Negative.(Types(ty)).index, 3, "omitnan");
                ByBeta.(Types(ty)).CPDplus(:, :, 4) = ByBeta.(Types(ty)).CPDplus(:, :, 4) + (ByBeta.(Types(ty)).CPDplus(:, :, 1) > PosAvg);
                ByBeta.(Types(ty)).CPDminus(:, :, 4) = ByBeta.(Types(ty)).CPDminus(:, :, 4) + (ByBeta.(Types(ty)).CPDminus(:, :, 1) > NegAvg);
            end
        end
        for ty = 1:numel(Types)
             ByBeta.(Types(ty)).CPDplus(:, :, 4) = ByBeta.(Types(ty)).CPDplus(:, :, 4) ./ nboot;
             ByBeta.(Types(ty)).CPDminus(:, :, 4) = ByBeta.(Types(ty)).CPDminus(:, :, 4) ./ nboot;
        end
        Matrices.(Regions{teil}).ByBeta = ByBeta;
        clear ByBeta;
    end
end
    