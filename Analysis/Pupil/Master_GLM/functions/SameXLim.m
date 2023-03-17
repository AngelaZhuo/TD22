function SameYLim(fig, Samax)
    for S = 1:size(Samax,1)
        MaxX = 0; MinX = inf;
        for A = 1:numel(Samax{S})
            nexttile(Samax{S}(A))
            ax = gca;
            MaxX = max(MaxX, ax.XLim(2));
            MinX = min(MinX, ax.XLim(1));
        end
        for A = 1:numel(Samax{S})
            nexttile(Samax{S}(A))
            ax = gca;
            ax.XLim(2) = MaxX;
            ax.XLim(1) = MinX;
        end
    end
end