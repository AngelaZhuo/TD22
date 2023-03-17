function [M, Adjusted] = AplanePikes_jitter(M, TM, Events, IfPlot)
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
delta = M(1, 2:end, :) - M(1, 1:end-1, :); deltaj = delta(:, Events(3)-1, :);
delta(:, Events(3)-1, :) = 0;
STD1 = std(delta(:, 1:Events(4)-1, :), 0, "all", "omitnan"); AVG1 = mean(delta(:, 1:Events(4)-1, :), "all", "omitnan");
STD2 = std(delta(:, Events(4):Events(6)-1, :), 0, "all", "omitnan"); AVG2 = mean(delta(:, Events(4):Events(6)-1, :), "all", "omitnan");
STD3 = std(delta(:, Events(6):end, :), 0, "all", "omitnan"); AVG3 = mean(delta(:, Events(6):end, :), "all", "omitnan");
STDj = std(deltaj, 0, "omitnan"); AVGj = mean(deltaj, "all", "omitnan");
% histogram(delta(:, Events(3)-1, :))
% xline([AVGj+1*STDj, AVGj-1*STDj])


OL = zeros(size(delta));
OL(delta<AVG-3*STD) = -1; OL(delta>AVG+3*STD) = 2; 
OLj(deltaj<AVGj-3*STDj) = -1; OLj(deltaj>AVGj+3*STDj) = 2; 
OL(:, Events(3)-1, :) = deltaj; % Remove the jitter delta. 
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
    fig = figure; % Histograms
    fig.Units = "centimeter";
    fig.Position = [50, 10, 10, 10];
    tiledlayout(2, 2)
    nexttile
        histogram(delta(:, 1:Events(4)-1, :))
        title("CS1 part")
        xline([AVG1+3*STD1, AVG1-3*STD1])
    nexttile
        histogram(delta(:, Events(4):Events(6)-1, :))
        title("CS2 part")
        xline([AVG2+3*STD2, AVG2-3*STD2])
    nexttile
        histogram(delta(:, Events(6):end, :))
        title("US part")
        xline([AVG3+3*STD3, AVG3-3*STD3])
    nexttile
        histogram(deltaj)
        title("jitter")
        xline([AVGj+3*STDj, AVGj-3*STDj])
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




