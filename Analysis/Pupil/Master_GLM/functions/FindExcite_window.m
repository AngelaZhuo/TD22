function Array = FindExcite_window(Region, win)
    Neurons = size(Region.matrix, 1);
    Array = zeros(Neurons, 1);
    for u = 1:Neurons
        Baseline = mean(Region.matrix(u, 1:19, :), "all", "omitnan");
        Compare = mean(Region.matrix(u, win, :), "all", "omitnan");
        Array(u, :) = Compare - Baseline;
    end
end

