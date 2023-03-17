function SameYLim(fig, Samax)
    for S = 1:size(Samax,1)
        MaxY = 0; MinY = inf;
        for A = 1:numel(Samax{S})
            nexttile(Samax{S}(A))
            ax = gca;
            MaxY = max(MaxY, ax.YLim(2));
            MinY = min(MinY, ax.YLim(1));
        end
        for A = 1:numel(Samax{S})
            nexttile(Samax{S}(A))
            ax = gca;
            ax.YLim(2) = MaxY;
            ax.YLim(1) = MinY;
        end
    end
end