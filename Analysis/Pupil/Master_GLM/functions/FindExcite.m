function Array = FindExcite(Region, Events)
    Neurons = size(Region.matrix, 1);
    Array = zeros(Neurons, 3);
    for u = 1:Neurons
        Baseline = mean(Region.matrix(u, 1:12, :), "all", "omitnan");
        CS1 = mean(Region.matrix(u, Events(1):Events(1)+11, :), "all", "omitnan");
        CS2 = mean(Region.matrix(u, Events(4):Events(4)+11, :), "all", "omitnan");
        US = mean(Region.matrix(u, Events(6):Events(6)+11, :), "all", "omitnan");
        if CS1 > Baseline 
            Array(u, 1) = 1;
        elseif CS1 < Baseline
            Array(u, 1) = -1;
        end
        if CS2 > Baseline 
            Array(u, 2) = 1;
        elseif CS2 < Baseline
            Array(u, 2) = -1;
        end
        if US > Baseline 
            Array(u, 3) = 1;
        elseif US < Baseline
            Array(u, 3) = -1;
        end
    end
end

