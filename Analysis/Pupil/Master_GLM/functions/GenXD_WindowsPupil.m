function [DM] = GenXD_WindowsPupil(TM, Types, Jitter, Ranges)

    % Laurence history
    Index = [];
    Numbers = [1, 5, 9, 10];
    for nr = Numbers
        [Current, Compare] = FindTrial(nr);
        Idx = HistoryIndex(TM, Current, Compare);
        Index =  cat(2, Index, Idx); % Index will have size(Numbers, 2)*2 columns
    end
    Index = squeeze(Index)';
    L1 = sum(Index(:,[1,3]), 2) - sum(Index(:,[2, 4]),2);
    L2 = sum(Index(:,[5, 7]), 2) - sum(Index(:,[6, 8]),2);
    
    % Model history
    ModA = HistoryIndex(TM, [5, 99, 99], [[6, 7, 1]; [6, 7, 0]; [5, 99, 99]]);
    ModB = HistoryIndex(TM, [6, 99, 99], [[5, 8, 1]; [5, 8, 0]; [6, 99, 99]]);
    M1(:,1) = ModA(1, 1, :) + ModB(1, 1, :) - (ModA(1, 2, :) + ModB(1, 2, :));
    Ma(:,1) = ModA(1, 1, :) - ModA(1,2,:);
    Mb(:,1) = ModB(1, 1, :) - ModB(1,2,:);
    
    ModC = HistoryIndex(TM, [99, 7, 99], [[5, 8, 1]; [5, 8, 0]; [5, 7, 99]]);
    ModD = HistoryIndex(TM, [99, 8, 99], [[6, 7, 1]; [6, 7, 0]; [6, 8, 99]]);
    M2(:,1) = ModC(1,1,:) + ModD(1,1,:) - (ModC(1,2,:) + ModD(1,2,:));
    
    %Stimuli
    TM(TM == 5) = 1; TM(TM == 6) = -1;
    TM(TM == 7) = 1; TM(TM == 8) = -1;
    TM(TM == 0) = -1;
    
    % TM
    TM = permute(TM, [3, 2, 1]);
    
    %Saliency
    CS1 = squeeze(TM(:,1,:)); CS2 = squeeze(TM(:,2,:)); US = squeeze(TM(:,3,:));
    S2 = zeros(size(CS2)); S2(2:end) = CS2(1:end-1);
    S1 = zeros(size(CS1)); S1(2:end) = CS1(1:end-1);
    
    % CS2 surprise
    posCS2 = -ones(size(CS2)); posCS2(CS1 == -1 & CS2 == 1) = 1;
    [~, posCS2] = OLS(CS1, posCS2, 1);
    negCS2 = ones(size(CS2)); negCS2(CS1 == 1 & CS2 == -1) = -1; 
    [~, negCS2] = OLS(CS1, negCS2, 1);

    % US surprise
    pos2US = -ones(size(US)); pos2US(CS2 == -1 & US == 1) = 1;
    [~, pos2US] = OLS(CS2, pos2US, 1);
    neg2US = ones(size(US)); neg2US(CS2 == 1 & US == -1) = -1; 
    [~, neg2US] = OLS(CS2, neg2US, 1);
    pos1US = -ones(size(US)); pos1US(CS1 == -1 & US == 1) = 1;
    [~, pos1US] = OLS(CS1, pos1US, 1);
    neg1US = ones(size(US)); neg1US(CS1 == 1 & US == -1) = -1; 
    [~, neg1US] = OLS(CS1, neg1US, 1);
    sur1CR = zeros(size(US)); sur1CR(CS1 == 1 & CS2 == 1 & US == 1) = -1; sur1CR(CS1 == -1 & CS2 == 1 & US == 1) = 1;
    sur1DN = zeros(size(US)); sur1DN(CS1 == 1 & CS2 == -1 & US == -1) = -1; sur1DN(CS1 == -1 & CS2 == -1 & US == -1) = 1;
    
    % SequenceProb
    probR = zeros(size(US)); probR(CS1 == 1 & CS2 == 1 & US == 1) = .64; probR(CS1 == 1 & CS2 == -1 & US == 1) = .04; probR(CS1 == -1 & CS2 == 1 & US == 1) = .16; probR(CS1 == -1 & CS2 == -1 & US == 1) = .16;
    probN = zeros(size(US)); probN(CS1 == -1 & CS2 == -1 & US == -1) = .64; probN(CS1 == 1 & CS2 == -1 & US == -1) = .16; probN(CS1 == -1 & CS2 == 1 & US == -1) = .04; probN(CS1 == 1 & CS2 == 1 & US == -1) = .16;
    Prob = probR + probN;
    
    %Satiety
    Reward = squeeze(TM(:, 3, :));
    Sat = zeros(size(Reward)); Sat(2:end) = Reward(1:end-1);
    
    %Time
    Time = ones(size(Sat));
    Time(:,1) =  (1:size(Time,1)) / size(Time, 1);

    
    % DESIGN MATRIX
    X = cat(2, Time, TM, S1, S2, Sat, L1, L2, M1, M2, Ma, Mb, posCS2, negCS2, pos2US, neg2US, pos1US, neg1US, sur1CR, sur1DN, Prob);
    X = cat(2, X, Jitter);
    Original = ["Time", "CS1", "CS2", "US", "S1", "S2", "Sat", "L1", "L2", "M1", "M2", "M_A", "M_B", "posCS2", "negCS2", "pos2US", "neg2US", "pos1US", "neg1US", "sur1CR", "sur1DN", "Prob"];
    Original = cat(2, Original, "Jitter");
    Jitter = numel(Original);
    
    for ty = 1:numel(Types)
        NewDesign = []; R = []; Unite = []; UN= []; 
        Type = Types(ty);
        switch Type 
            case "PupilMain"
            NewDesign = {2, 3, 4, [2, 3], [2, 4], [3, 4], 8, [2, 8], 9, [9, 3], 1, 7, Jitter};
            R = Ranges(1, :);
            Unite = {[7, 8]; [9, 10]}; UN = ["L1-tgr", "L2-tgr"];

            case "CS1final"
            NewDesign = {2, 8, [2, 8], 1, 7};
            R = Ranges(1, :);
            Unite = {[2, 3]}; UN = "L1-tgr";
            case "CS2final"
            NewDesign = {2, 3, [2,3], 8, [2, 8], 9, [9, 3], 1, 7, Jitter};
            R = Ranges(2, :);
            Unite = {[4, 5]; [6, 7]}; UN = ["L1-tgr", "L2-tgr"];
            case "USfinal"
            NewDesign = {2, 3, 4, [2, 3], [2,4], [3,4], 1, 7};
            R = Ranges(3, :);
            Unite = {[4, 5, 6]}; UN = "Interactions";


            case "CS1use"
            NewDesign = {2, 1, 7};
            R = Ranges(1, :);
            Unite = {}; UN = [];
            case "CS2use"
            NewDesign = {2, 3, [2,3], 1, 7, Jitter};
            R = Ranges(2, :);
            Unite = {}; UN = "";
            case "USuse"
            NewDesign = {2, 3, 4, [2, 3], [2,4], [3,4], 1, 7};
            R = Ranges(3, :);
            Unite = {[4, 5, 6]}; UN = "Interactions";


            case "CS1ext" % This one will not be used because M is never observed.
            NewDesign = {2, 8, [8, 2], 12, 13, 7, 1};
            R = Ranges(1, :);
            Unite = {[2, 3]; [4, 5]}; UN = ["L1-tgr", "MAB-tgr"];            
            case "CS2ext"
            NewDesign = {2, 3, [2,3], 9, [9,3], 7, 1, Jitter};
            R = Ranges(2, :);
            Unite = {[4, 5]}; UN = "L2-tgr";
            case "USext"
            NewDesign = {2, 3, 4, [2,4], [3,4], 7, 1};
            R = Ranges(3, :);
            
            case "surCS2"
            NewDesign = {3, 14, 15, 1, 7, Jitter};
            Unite = {[2, 3]}; UN = ["surCS2-tgr"];
            R = Ranges(2, :);
            case "sur2US"    
            NewDesign = {2, 4, 16, 17, [2,4], 1, 7};
            R = Ranges(3, :);
            Unite = {[3, 4]}; UN = ["sur2US-tgr"];
            case "sur1US"    
            NewDesign = {3, 4, 18, 19, [3, 4], 1, 7};
            R = Ranges(3, :);
            Unite = {[3, 4]}; UN = ["sur1US-tgr"];
            case "sur12US"    
            NewDesign = {3, 4, 20, 21, [3,4], 1,7};
            R = Ranges(3, :);
            Unite = {[3, 4]}; UN = ["sur12US-tgr"];

            case "seqProb"    
            NewDesign = {2, 3, 4, 22, 1, 7};
            R = Ranges(3, :);
            Unite = {[]}; UN = [""];

        end
    
        Xnew = zeros(size(X, 1), 1);
        D = [""];
        
        for de = 1:numel(NewDesign)
            val = 1;
            str = "";
            Cell = NewDesign{de};
            for i = 1:numel(Cell)
                val = val.*X(:,Cell(i));
                if i == 1
                    str = Original(Cell(i));
                else
                    str = str + " * " + Original(Cell(i));
                end
            end
            Xnew(:, de) = val;
            D(de) = str;
        end
        Rows = size(Xnew, 1);
        newM = cat(2, ones(Rows, 1), Xnew); % Constant column in the beginning
        DM.(Type).DMatrix = newM;
        DM.(Type).Design = D;
        DM.(Type).Range = R;
        DM.(Type).Unite = Unite;
        DM.(Type).UniteName = UN;
    end
end