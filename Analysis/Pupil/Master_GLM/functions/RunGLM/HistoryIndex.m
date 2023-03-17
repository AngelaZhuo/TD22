function  DesiredIndex = HistoryIndex(TrialMatrix, Current, Compare)

    C = IndexGenerator(Current);
    
    SwitchMatrix = zeros(size(Compare,1), 6);
    for prev = 1:size(Compare, 1)
        SwitchMatrix(prev, :) = IndexGenerator(Compare(prev, :));
    end

    [Neurons, ~, Trials] = size(TrialMatrix);
    DesiredIndex = zeros(Neurons, size(Compare,1), Trials);
    
    for u = 1:Neurons
        LastSeen = 0;
        for t = 2:Trials
            for comp = 1:size(Compare, 1)
                check4 = SwitchMatrix(comp, 1) == TrialMatrix(u, 1, t-1) || SwitchMatrix(comp, 2) == TrialMatrix(u, 1, t-1);
                check5 = SwitchMatrix(comp, 3) == TrialMatrix(u, 2, t-1) || SwitchMatrix(comp, 4) == TrialMatrix(u, 2, t-1);
                check6 = SwitchMatrix(comp, 5) == TrialMatrix(u, 3, t-1) || SwitchMatrix(comp, 6) == TrialMatrix(u, 3, t-1);        
                if check4 && check5 && check6
                    LastSeen = uint64(comp);
                    break
                end
            end
            
            check1 = C(1) == TrialMatrix(u, 1, t) || C(2) == TrialMatrix(u, 1, t) ;
            check2 = C(3) == TrialMatrix(u, 2, t) || C(4) == TrialMatrix(u, 2, t) ;
            check3 = C(5) == TrialMatrix(u, 3, t) || C(6) == TrialMatrix(u, 3, t) ;
            
            if LastSeen ~= 0
                DesiredIndex(u, LastSeen, t) = check1 & check2 & check3;
            end
            
            
        end
    end
    DesiredIndex = logical(DesiredIndex);
end
    