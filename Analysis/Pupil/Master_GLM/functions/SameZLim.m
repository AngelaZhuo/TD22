function SameZLim(fig, Samax)
    for S = 1:size(Samax,1)
        MaxZ = 0; MinZ = inf;
        for A = 1:numel(Samax{S})
            nexttile(Samax{S}(A))
            ax = gca;
            MaxZ = max(MaxZ, ax.ZLim(2));
            MinZ = min(MinZ, ax.ZLim(1));
        end
        for A = 1:numel(Samax{S})
            nexttile(Samax{S}(A))
            ax = gca;
            ax.ZLim(2) = MaxZ;
            ax.ZLim(1) = MinZ;
        end
    end
end