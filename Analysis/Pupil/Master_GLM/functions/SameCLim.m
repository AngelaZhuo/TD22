function SameCLim(fig, Samax)
    for S = 1:numel(Samax)
        MaxC = 0; MinC = inf;
        for A = 1:numel(Samax{S})
            nexttile(Samax{S}(A))
            ax = gca;
            lims = caxis;
            MaxC = max(MaxC, lims(2));
            MinC = min(MinC, lims(1));
        end
        for A = 1:numel(Samax{S})
            nexttile(Samax{S}(A))
            set(gca, 'clim', [MinC, MaxC]);
        end
    end
end