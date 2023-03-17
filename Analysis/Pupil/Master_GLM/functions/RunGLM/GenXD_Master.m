function [DM] = GenXD_Master(TM, Types, Jitter, Ranges)
    
    %Stimuli
    TM(TM == 5) = 1; TM(TM == 6) = -1;
    TM(TM == 7) = 1; TM(TM == 8) = -1;
    TM(TM == 0) = -1;

    %Satiety
    Reward = squeeze(TM(:, 3, :));
    Sat = zeros(size(Reward)); Sat(2:end) = Reward(1:end-1);
    
    %Time
    Time = ones(size(Sat));
    Time(:,1) =  (1:size(Time,1)) / size(Time, 1);
    
    % TM
    TM = permute(TM, [3, 2, 1]);
    
    % DESIGN MATRIX
    X = cat(2, TM, Time, Sat);
    X = cat(2, X, Jitter);
    Original = ["CS1", "CS2", "US", "Time", "Sat"];
    Original = cat(2, Original, "Jitter");
    Jitter = numel(Original);
    
    for ty = 1:numel(Types)
        NewDesign = []; R = []; Unite = []; UN= []; 
        Type = Types(ty);
        switch Type 
            case "CS1final"
            NewDesign = {1, 4, 5};
            R = Ranges(1, :);
            Unite = {}; UN = "";
            case "CS2final"
            NewDesign = {1, 2, [1, 2], 4, 5, Jitter};
            R = Ranges(2, :);
            Unite = {[1, 3]}; UN = ["surCS2"];
            case "USfinal"
            NewDesign = {1, 2, 3, [1, 2], [1, 3], [2, 3], 4, 5};
            R = Ranges(3, :);
            Unite = {[1, 5], [2, 6]}; UN = ["sur1US", "sur2US"];

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
        Xnew = Xnew - mean(Xnew,1);
        newM = cat(2, ones(Rows, 1), Xnew); % Constant column in the beginning
        DM.(Type).DMatrix = newM;
        DM.(Type).Design = D;
        DM.(Type).Range = R;
        DM.(Type).Unite = Unite;
        DM.(Type).UniteName = UN;
    end
end