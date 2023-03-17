function [M, Adjusted] = AplanePikes_single(M, TM, Events, IfPlot)
Original = M; Nanner = ones(size(M)); Nanner(isnan(M)) = NaN; Plo = NaN(size(M));
% for tr = 1:size(M, 3)
%     for b = 1:size(M, 2)-1
%         val = M(1, b, tr);
%         if isnan(val); continue; end
%         if isnan(M(1, b+1, tr))
%             M(1, b+1, tr) = val;
%         end
%     end
% end
delta = M(1, 2:end, :) - M(1, 1:end-1, :);
OL = zeros(size(delta));
for b = 1:167
    D = delta(:, b, :);
    AVG = mean(delta(:, b, :), "omitnan");
    STD = std(delta(:, b, :), 0, "omitnan");
    OL(:, b, squeeze(D > AVG + 4*STD)) = 2;
    OL(:, b, squeeze(D < AVG - 4*STD)) = -1;
end

Adjusted = 0;
for tr = 1:150
    win = 0;
    ver = 0; nichte = 0;
    fra = 0; til = 0;
    for b = 1:167
        if OL(1, b, tr) == 0
            continue
        elseif OL(1, b, tr) == 2
            win = OL(1, b, tr);
            ver = b+1;
            fra = Original(1, b, tr);
        elseif OL(1, b, tr) == -1 && win == 2
            nichte = b+1;
            til = Original(1, b, tr);
            repla = linspace(fra, til, numel(ver:nichte));
            M(1, ver:nichte, tr) = repla;
            Adjusted = Adjusted + numel(ver:nichte);
            win = 0; ver = 0; nichte = 0; fra = 0; til = 0;
        end
    end
    if OL(1, end, tr) == 2
        M(1, end, tr) = NaN;
        Adjusted = Adjusted +1;
    end
end
% % % % for tr = 1:150
% % % %     if OL(1, 1, tr) == -1
% % % %         M(1, 1, tr) = M(1, 2, tr);
% % % %         Adjusted = Adjusted +1;
% % % %     elseif OL(1, 1, tr) == 2
% % % %         M(1, 2:end, tr) = M(1, 2:end, tr) - M(1, 2, tr) + M(1, 1, tr);
% % % %         Adjusted = Adjusted + +1;
% % % %     end
% % % %     for b = 2:167
% % % %         if OL(1, b, tr) ~= 0
% % % %             M(1, b+1:end, tr) = M(1, b+1:end, tr) - M(1, b+1, tr) + M(1, b, tr);
% % % %             Adjusted = Adjusted + +1;
% % % %         end
% % % %     end
% % % % end
M = M.*Nanner;
if IfPlot
    fig = figure; % Trials and PSTH
    fig.Units = "centimeter";
    fig.Position = [10, 10, 40, 20];
    tiledlayout(2, 2)
    nexttile
        plot(squeeze(Original));
        xline([Events(1), Events(4), Events(6)], "k", "LineWidth", 2, "Alpha", 1)
        xline([Events(2), Events(5)], "--k", "LineWidth", 2, "Alpha", 1)
        hold on
        for tr = 1:150
            for b = 1:167
                if OL(:, b, tr) ~= 0
                    plot(b:b+1, Original(1, b:b+1, tr), "-r", "LineWidth", 2)
                end
                
            end
        end
        title(["Old data"; "Trials"])
    nexttile
        plot(squeeze(M));
        title(["Corrected data, " + num2str(Adjusted) + " adjustments"; "Trials"])
        xline([Events(1), Events(4), Events(6)], "k", "LineWidth", 2, "Alpha", 1)
        xline([Events(2), Events(5)], "--k", "LineWidth", 2, "Alpha", 1)
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




