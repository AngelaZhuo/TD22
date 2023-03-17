function SEM = StdError(Data)
Valids = ~isnan(Data); Valids = sum(Valids, 1);
SEM = std(Data, 1, 1, "omitnan")./sqrt(Valids);
end