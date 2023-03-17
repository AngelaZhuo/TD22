function Array = FindExcite_allbins(Region, window)
    Neurons = size(Region.matrix, 1);
    Array = zeros(Neurons, size(Region.matrix, 2));
    for u = 1:Neurons
        Baseline = mean(Region.matrix(u, 1:19, :), "all", "omitnan");
        Compare = mean(Region.matrix(u, window, :), 3, "omitnan");
        Array(u, :) = Compare > Baseline;
    end
end

