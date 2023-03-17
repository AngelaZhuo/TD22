function [M, Adjusted] = AplanePikes(M, TM, Events, IfPlot)
Original = M; Nanner = ones(size(M)); Nanner(isnan(M)) = NaN;
for tr = 1:size(M, 3)
    for b = 1:size(M, 2)-1
        val = M(1, b, tr);
        if isnan(val); continue; end
        if isnan(M(1, b+1, tr))
            M(1, b+1, tr) = val;
        end
    end
end
delta = M(1, 2:end, :) - M(1, 1:end-1, :);
STD = std(delta, 0, "all", "omitnan"); AVG = mean(delta, "all", "omitnan");

OL = zeros(size(delta));
OL(delta<AVG-3*STD) = -1; OL(delta>AVG+3*STD) = 2; 
OL(:, Events(3)-1, :) = 0; % Remove the jitter delta. 
Adjusted = 0; 
for tr = 1:150
    if OL(1, 1, tr) == -1
        M(1, b, tr) = M(1, b+1, tr);
        Adjusted = Adjusted +1;
    end
    for b = 1:167
        if OL(1, 1, tr) == -1
            continue
        end
        if OL(1, b, tr) ~= 0
            M(1, b+1:end, tr) = M(1, b+1:end, tr) - M(1, b+1, tr) + M(1, b, tr);
            Adjusted = Adjusted + +1;
        end
    end
end
M = M.*Nanner;
if IfPlot
    figure % Delta histogram
    histogram(delta)
    xline([AVG+3*STD, AVG-3*STD])
    fig = figure; % Trials and PSTH
    fig.Units = "centimeter";
    fig.Position = [10, 10, 40, 20];
    tiledlayout(2, 2)
    nexttile
        plot(squeeze(Original));
        title(["Old data"; "Trials"])
    nexttile
        plot(squeeze(M));
        title(["Corrected data, " + num2str(Adjusted) + " adjustments"; "Trials"])
    nexttile
        Mirko(Original, TM, Events, "diam. (a.u.)", 0, 0)
        title(["PSTH"])
    nexttile
        Mirko(M, TM, Events, "diam. (a.u.)", 0, 0)
        title(["PSTH"])
    Samax = {[1, 2]; [3, 4]}; 
    SameYLim(gcf, Samax);
end
end




