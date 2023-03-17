function [M, Removed] = RemovePikes(M, TM, Events, Thresh, IfPlot)
Mask = ones(size(M)); Mask(isnan(M)) = NaN;
Plo = NaN(size(M));
delta = M(1, 2:end, :) - M(1, 1:end-1, :);
STD = std(delta(:, setdiff(1:size(delta,2), Events(3)-1), :), 0, "all", "omitnan"); AVG = mean(delta(:, setdiff(1:size(delta,2), Events(3)-1), :), "all", "omitnan");

OL = zeros(size(delta));
OL(delta<AVG-5*STD) = -1; OL(delta>AVG+5*STD) = 2; 
Removed = 0; 
for tr = 1:150
    win = 0; cou = 0;
    ver = 0; nichte = 0;
    for b = 1:167
        if cou == Thresh || b == Events(3)-1
            win = 0; cou = 0;
            ver = 0; nichte = 0;
            continue
        end
        if OL(1, b, tr) == 0
            if win ~= 0
                cou = cou+1;
                continue
            end
        elseif OL(1, b, tr) == 2
            if win == 0
                ver = b+1;
                win = 2;
            elseif win == -1
                nichte = b;
                win = 1;
            elseif win == 2
%                 ver = 0;
%                 win = 0; 
%                 for bin = b-1:165
%                     OL(1, bin, tr) = 0;
%                     OL(1, bin+1, tr) = 0;
%                     if OL(1, bin+2, tr) == 2
%                         OL(1, bin+2, tr) = 0;
%                     elseif OL(1, bin+2, tr) ~= 2
%                         break
%                     end
%                 end
            end
        elseif OL(1, b, tr) == -1
            if win == 0
                ver = b+1;
                win = -1;
            elseif win == 2
                nichte = b;
                win = 1;
            elseif win == -1
%                 ver = 0;
%                 win = 0; 
%                 for bin = b-1:165
%                     OL(1, bin, tr) = 0;
%                     OL(1, bin+1, tr) = 0;
%                     if OL(1, bin+2, tr) == -1
%                         OL(1, bin+2, tr) = 0;
%                     elseif OL(1, bin+2, tr) ~= -1
%                         break
%                     end
%                 end
            end
        end
        if win == 1
            Mask(1, ver:nichte, tr) = NaN;
            Plo(1, ver-1:nichte+1, tr) = M(1, ver-1:nichte+1, tr);
            Removed = Removed + 1;
            win = 0; cou = 0;
            ver = 0; nichte = 0;
        end
    end
end
if IfPlot
%     fig = figure;
%     fig.Units = "centimeter";
%     fig.Position = [10, 10, 40, 20];
    clf
    tiledlayout(2, 2)
    nexttile
        plot(squeeze(M));
        hold on
        plot(squeeze(Plo), "-r", "LineWidth", 2)
        title(["Original data"; "Trials"])
        xline([Events(1), Events(4), Events(6)], "k", "LineWidth", 2, "Alpha", 1)
        xline([Events(2), Events(5)], "--k", "LineWidth", 2, "Alpha", 1)
    nexttile
        plot(squeeze(M.*Mask));
        title(["Corrected data, " + num2str(Removed) + " spikes removed"; "Trials"])
        xline([Events(1), Events(4), Events(6)], "k", "LineWidth", 2, "Alpha", 1)
        xline([Events(2), Events(5)], "--k", "LineWidth", 2, "Alpha", 1)    
%     nexttile
%        Mirko(M, TM, Events, "diam. (a.u.)", 0, 0)
%         title(["Original data"; "PSTH"])
    nexttile
        histogram(delta(:, setdiff(1:size(delta,2), Events(3)-1), :))
        xline([AVG+5*STD, AVG-5*STD], "label", "5 std")
        title("Delta in original data")
        ylim([0, 15])
    nexttile
        Mirko(M.*Mask, TM, Events, "diam. (a.u.)", 0, 0)
        title(["Corrected data"; "PSTH"])
    Samax = {[1, 2]}; 
    SameYLim(gcf, Samax);
end
M = M.*Mask;
end




